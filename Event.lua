local _

function ClassicNFCT:OnInitialize()
    self:CreateLocale()
    
    UIParent:SetFrameStrata("BACKGROUND")
    UIParent:SetFrameLevel(0)
    
    self.unitToGuid = self:CreateMap()
    self.guidToUnit = self:CreateMap()
    self.playerGUID = UnitGUID("player")
    
    -- setup db
    self:CreateDB()
    
    self:CreateText()
    self:CreateAnimation()
    
    self:CreateCmd()

    -- setup menu
    self:CreateMenu()

    self.dynamicEvents = {"COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_TARGET_CHANGED"}

    self:UpdateEnable(self.db.global.enabled)
    
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

    self:ChangeBlizzardFCT()
end

function ClassicNFCT:OnEnable()
    for _, event in pairs(self.dynamicEvents) do
        self:RegisterEvent(event)
    end
end

function ClassicNFCT:OnDisable()
    for _, event in pairs(self.dynamicEvents) do
        self:UnregisterEvent(event)
    end
    self:ClearAnimation()
end

function ClassicNFCT:NAME_PLATE_UNIT_ADDED(event, unitID)
    if not unitID then return end
    local guid = UnitGUID(unitID)
    if not guid then return end

    self.unitToGuid:emplace(unitID, guid)
    self.guidToUnit:emplace(guid, unitID)
end

function ClassicNFCT:NAME_PLATE_UNIT_REMOVED(event, unitID)
    if not unitID then return end
    local guid = self.unitToGuid:at(unitID)
    if not guid then return end
    
    self.unitToGuid:remove(unitID)
    self.guidToUnit:remove(guid)
end

function ClassicNFCT:PLAYER_TARGET_CHANGED(event, unitID)
    self:AnimateUpdate()
end

function ClassicNFCT:COMBAT_LOG_EVENT_UNFILTERED()
    return self:CombatFilter(CombatLogGetCurrentEventInfo())
end

function ClassicNFCT:CombatFilter(_, clue, _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, ...)
    local isMelee
	if self.playerGUID == sourceGUID then -- Player events
        if (clue:find("_DAMAGE")) then
            return self:CombatFilter_Damage(clue, destGUID, false, ...)
        elseif (clue:find("_MISSED")) then
            return self:CombatFilter_Miss(clue, destGUID, false, ...)
        end
    elseif (bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 or bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0)
        and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
    then -- Pet/Guardian events
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
    if self.spellBlacklist[tostring(spellID)] or self.spellBlacklist[tostring(spellName)] then return end
    self:DamageEvent(destGUID, spellID, amount, school, critical, isPet, isMelee)
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
    if self.spellBlacklist[tostring(spellID)] or self.spellBlacklist[tostring(spellName)] then return end
    self:MissEvent(destGUID, spellID, spellSchool, missType, isPet, isMelee)
end

function ClassicNFCT:DamageEvent(guid, spellID, amount, school, crit, isPet, isMelee)
    local minDmg = self.db.global.filter.minDmg
    if minDmg > 0 and amount < minDmg then return end

    local text
    
    local icon = self.db.global.style.iconStyle

    if (icon ~= "only") then
        -- color text
        text = self:TextWithColor(self:FormatNumber(amount), school, isPet, isMelee)

        -- add icons
        if (icon ~= "none" and spellID) then
			local iconText = "|T"..GetSpellTexture(spellID)..":0|t"

			if (icon == "both") then
				text = iconText..text..iconText
			elseif (icon == "left") then
				text = iconText..text
			else -- if (icon == "right") then
				text = text..iconText
			end
        end
    else
        -- showing only icons
        if (not spellID) then
            return
        end

        text = "|T"..GetSpellTexture(spellID)..":0|t"
    end

    self:DisplayText(guid, text, crit, isPet, isMelee)
end

function ClassicNFCT:MissEvent(guid, spellID, spellSchool, missType, isPet, isMelee)
    if self.db.global.filter.ignoreNoDmg then return end
    
    local icon = self.db.global.style.iconStyle
    
    if (icon == "only") then
        return
    end
    
    local text = self:TextWithColor(self.L.MISS_EVENT_STRINGS[missType], spellSchool, isPet, isMelee)

    -- add icons
    if (icon ~= "none" and spellID) then
        local iconText = "|T"..GetSpellTexture(spellID)..":0|t"

        if (icon == "both") then
            text = iconText..text..iconText
        elseif (icon == "left") then
            text = iconText..text
        else -- if (icon == "right") then
            text = text..iconText
        end
    end

    self:DisplayText(guid, text, false, isPet, isMelee)
end

function ClassicNFCT:GetNamePlateForGUID(guid)
    local unit, nameplate
    repeat
        if not guid then break end
        unit = self.guidToUnit:at(guid)
        if not unit or UnitIsDead(unit) then break end
        nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        if not nameplate or not nameplate:IsShown() then
            nameplate = nil
        end
    until true
    return unit, nameplate
end

function ClassicNFCT:GetAttackableNamePlateTargetGUID()
    local targetGUID = UnitGUID("target")
    for unit, guid in self.unitToGuid:iter() do
        if guid == targetGUID then
            if UnitIsDead(unit) or not UnitCanAttack("player", "target") then return end
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if not nameplate or not nameplate:IsShown() then return end
            return guid
        end
    end
end

function ClassicNFCT:ChangeBlizzardFCT(enabled)
    SetCVar("floatingCombatTextCombatDamage", self.db.global.blzDisabled and "0" or "1")
end
