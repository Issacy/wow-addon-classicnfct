local _

local DYNAMIC_EVENTS = {"COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_TARGET_CHANGED"}
local COMBAT_EVENT_RECORD_RESET_INTERVAL = 1.0 / (120 * 1.5)

local unitToGuid, guidToUnit, playerGUID
local combatEventRecord = {
    total = 0,
    offTargets = 0,
    perOffTarget = {}
}

function ClassicNFCT:OnInitialize()
    self:CreateLocale()

    unitToGuid = self:CreateMap()
    guidToUnit = self:CreateMap()
    playerGUID = UnitGUID("player")

    self:CreateDialog()

    -- setup db
    self:CreateDB()

    self:CreateText()
    self:CreateAnimation()

    self:CreateCmd()

    -- setup menu
    self:CreateMenu()

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    self:SetEnableToDB(self.db.global.enabled)
end

function ClassicNFCT:RegisterDynamicEvents()
    for _, event in pairs(DYNAMIC_EVENTS) do
        self:RegisterEvent(event)
    end
end

function ClassicNFCT:UnregisterDynamicEvents()
    for _, event in pairs(DYNAMIC_EVENTS) do
        self:UnregisterEvent(event)
    end
    self:ClearAnimation()
end

function ClassicNFCT:NAME_PLATE_UNIT_ADDED(event, unitID)
    if not unitID then return end
    local guid = UnitGUID(unitID)
    if not guid then return end

    unitToGuid:emplace(unitID, guid)
    guidToUnit:emplace(guid, unitID)
end

function ClassicNFCT:NAME_PLATE_UNIT_REMOVED(event, unitID)
    if not unitID then return end
    local guid = unitToGuid:at(unitID)
    if not guid then return end

    unitToGuid:remove(unitID)
    guidToUnit:remove(guid)
end

function ClassicNFCT:PLAYER_REGEN_DISABLED()
    self:HideInCombatDialog()
end

function ClassicNFCT:PLAYER_REGEN_ENABLED()
    self:ShowInCombatDialog()
end

function ClassicNFCT:PLAYER_TARGET_CHANGED(event, unitID)
    self:AnimateUpdate()
end

function ClassicNFCT:COMBAT_LOG_EVENT_UNFILTERED()
    return self:CombatFilter(CombatLogGetCurrentEventInfo())
end

function ClassicNFCT:CombatFilter(_, clue, _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, ...)
    local isMelee
    if playerGUID == sourceGUID then -- Player events
        if (clue:find("_DAMAGE")) then
            return self:CombatFilter_Damage(clue, destGUID, false, ...)
        elseif (clue:find("_MISSED")) then
            return self:CombatFilter_Miss(clue, destGUID, false, ...)
        end
    elseif
        -- bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 or bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0) and
        bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
    then -- Pet/Guardian/etc. events
        if (clue:find("_DAMAGE")) then
            return self:CombatFilter_Damage(clue, destGUID, true, ...)
        elseif (clue:find("_MISSED")) then
            -- Don't show pet MISS events for now.
            return self:CombatFilter_Miss(clue, destGUID, true, ...)
        end
    end
end

function ClassicNFCT:CombatFilter_Damage(clue, destGUID, isPet, ...)
    local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
    local isMelee
    if (clue:find("SWING")) then
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
        isMelee = true
    elseif (clue:find("ENVIRONMENTAL")) then
        -- spellName, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
        return
    else
        spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
    end
    if spellID == 75 then isMelee = true end
    if not isPet then
        if (isMelee and self.spellBlacklist.melee) or (not isMelee and self.spellBlacklist.spell) then return end
    else
        if (self.spellBlacklist.pet) or (isMelee and self.spellBlacklist.pet_melee) or (not isMelee and self.spellBlacklist.pet_spell) then return end
    end
    if (spellID and self.spellBlacklist[spellID]) or (spellName and self.spellBlacklist[spellName]) then return end
    local minDmg = self.db.global.filter.minDmg
    if minDmg > 0 and amount < minDmg then return end
    if self:SkipEvent(destGUID) then return end
    self:DamageText(destGUID, spellID, amount, nil, school, critical, isPet, isMelee)
end

function ClassicNFCT:CombatFilter_Miss(clue, destGUID, isPet, ...)
    local spellID, spellName, spellSchool, missType, isOffHand, amountMissed
    local isMelee
    if (clue:find("SWING")) then
        missType, isOffHand, amountMissed = ...
        isMelee = true
    elseif (clue:find("ENVIRONMENTAL")) then
        -- spellName, missType, isOffHand, amountMissed = ...
        return
    else
        spellID, spellName, spellSchool, missType, isOffHand, amountMissed = ...
    end
    if spellID == 75 then isMelee = true end
    if not isPet then
        if (isMelee and self.spellBlacklist.melee) or (not isMelee and self.spellBlacklist.spell) then return end
    else
        if (self.spellBlacklist.pet) or (isMelee and self.spellBlacklist.pet_melee) or (not isMelee and self.spellBlacklist.pet_spell) then return end
    end
    if (spellID and self.spellBlacklist[spellID]) or (spellName and self.spellBlacklist[spellName]) then return end
    if self.db.global.filter.ignoreNoDmg then return end
    if self:SkipEvent(destGUID) then return end
    self:DamageText(destGUID, spellID, 0, missType, spellSchool, false, isPet, isMelee)
end

function ClassicNFCT:SkipEvent(destGUID)
    local total = self.db.global.limit.total
    local offTargets = self.db.global.limit.offTargets
    local perOffTarget = self.db.global.limit.perOffTarget
    if total == 0 and offTargets == 0 and perOffTarget == 0 then return false end
    local now = GetTime()
    if not combatEventRecord.lastUpdateTime or (now - combatEventRecord.lastUpdateTime >= COMBAT_EVENT_RECORD_RESET_INTERVAL) then
        combatEventRecord.lastUpdateTime = now
        combatEventRecord.targetGUID = UnitGUID("target")
        combatEventRecord.total = 0
        combatEventRecord.offTargets = 0
        wipe(combatEventRecord.perOffTarget)
    end
    if destGUID == combatEventRecord.targetGUID then return false end
    if total > 0 and combatEventRecord.total >= total then return true end
    combatEventRecord.total = combatEventRecord.total + 1
    local theOffTarget = combatEventRecord.perOffTarget[destGUID]
    if not theOffTarget and offTargets > 0 and combatEventRecord.offTargets >= offTargets then return true end
    combatEventRecord.offTargets = combatEventRecord.offTargets + 1
    theOffTarget = theOffTarget or 0
    if perOffTarget > 0 and theOffTarget >= perOffTarget then return true end
    combatEventRecord.perOffTarget[destGUID] = theOffTarget + 1
    return false
end

function ClassicNFCT:GetNamePlateForGUID(guid)
    local unit, nameplate
    repeat
        if not guid then break end
        unit = guidToUnit:at(guid)
        if not unit or UnitIsDead(unit) then break end
        nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        if not nameplate or not nameplate:IsShown() then
            nameplate = nil
        end
    until true
    return nameplate
end
