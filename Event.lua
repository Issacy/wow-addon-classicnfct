local _

function ClassicNFCT:OnInitialize()
    local L = LibStub('AceLocale-3.0'):GetLocale("ClassicNFCT")
    L.UI = setmetatable(L.UI or {}, { __index = function(t, k) return k end, })
    self.L = L

    self.unitToGuid = {}
    self.guidToUnit = {}
    self.dynamicEvents = {"COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_TARGET_CHANGED"}
    self.playerGUID = UnitGUID("player")

    -- setup db
    self:CreateDB()

    self:CreateText()
    self:CreateAnimation()

    -- setup chat commands
    self:RegisterChatCommand("cnfct", "OpenMenu")

    -- setup menu
    self:CreateMenu()

    self.dynamicEvents = {"COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_TARGET_CHANGED"}

    -- if the addon is turned off in db, turn it off
    if not self.db.global.enabled then
        self:Disable()
    else
        self:Enable()
    end
    
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

    SetCVar("floatingCombatTextCombatDamage", self.db.global.blzDisabled and  "0" or "1")
end

function ClassicNFCT:OnEnable()
    for _, event in pairs(self.dynamicEvents) do
        self:RegisterEvent(event)
    end
    self.db.global.enabled = true
end

function ClassicNFCT:OnDisable()
    for _, event in pairs(self.dynamicEvents) do
        self:UnregisterEvent(event)
    end
    for _, anim in self.guidToAnim:iter() do
        anim:clear()
    end
    self.guidToAnim:clear()
    self.db.global.enabled = false
end

function ClassicNFCT:NAME_PLATE_UNIT_ADDED(event, unitID)
    if not unitID then return end
    local guid = UnitGUID(unitID)
    if not guid then return end

    self.unitToGuid[unitID] = guid
    self.guidToUnit[guid] = unitID
end

function ClassicNFCT:NAME_PLATE_UNIT_REMOVED(event, unitID)
    if not unitID then return end
    local guid = self.unitToGuid[unitID]
    if not guid then return end
    
    local anim = self.guidToAnim[guid]

    self.unitToGuid[unitID] = nil
    self.guidToUnit[guid] = nil

    if anim then anim:clear() end
end

function ClassicNFCT:PLAYER_TARGET_CHANGED(event, unitID)
    self:AnimateUpdate()
end

function ClassicNFCT:COMBAT_LOG_EVENT_UNFILTERED()
    return self:CombatFilter(CombatLogGetCurrentEventInfo())
end

function ClassicNFCT:CombatFilter(_, clue, _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, ...)
    local destUnit = self.guidToUnit[destGUID]
    local nameplate = self:GetNamePlateForGUID(destGUID)
    if not destUnit or not nameplate then return end

	if self.playerGUID == sourceGUID then -- Player events
        if (string.find(clue, "_DAMAGE")) then
            local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
            if (string.find(clue, "SWING")) then
                spellName, amount, overkill, _, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = "melee", ...
            elseif (string.find(clue, "ENVIRONMENTAL")) then
                spellName, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
            else
                spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
            end
            if spellID == 75 then spellName = "melee" end
            self:DamageEvent(destGUID, nameplate, spellID, amount, school, critical, spellName)
        elseif(string.find(clue, "_MISSED")) then
            local spellID, spellName, spellSchool, missType, isOffHand, amountMissed

            if (string.find(clue, "SWING")) then
                spellName, missType, isOffHand, amountMissed = "melee", ...
            else
                spellID, spellName, spellSchool, missType, isOffHand, amountMissed = ...
            end
            if spellID == 75 then spellName = "melee" end
            self:MissEvent(destGUID, nameplate, spellID, spellSchool, missType, spellName)
        end
    elseif (bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0
        or bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0)
        and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
    then -- Pet/Guardian events
        if (string.find(clue, "_DAMAGE")) then
            local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
            if (string.find(clue, "SWING")) then
                spellName, amount, overkill, _, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = "pet", ...
            elseif (string.find(clue, "ENVIRONMENTAL")) then
                spellName, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
            else
                spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
            end
            self:DamageEvent(destGUID, nameplate, spellID, amount, "pet", critical, spellName)
        -- elseif(string.find(clue, "_MISSED")) then -- Don't show pet MISS events for now.
            -- local spellID, spellName, spellSchool, missType, isOffHand, amountMissed

            -- if (string.find(clue, "SWING")) then
                -- if destGUID == self.playerGUID then
                    -- missType, isOffHand, amountMissed = ...
                -- else
                    -- missType, isOffHand, amountMissed = "pet", ...
                -- end
            -- else
                -- spellID, spellName, spellSchool, missType, isOffHand, amountMissed = ...
            -- end
            -- self:MissEvent(destGUID, nameplate, spellID, missType)
        end
    end
end

local truncateWords = {"", "K", "M", "B"}

function ClassicNFCT:DamageEvent(guid, nameplate, spellID, amount, school, crit, spellName)
    local text
    
    local icon = self.db.global.formatting.icon
    local isMelee = spellName == "melee"
    local isPet = school == "pet"

    if (icon ~= "only") then
        local fmtStyle = self.db.global.fmtStyle
        if fmtStyle == "disable" then
            text = tostring(amount)
        else
            local abs = math.abs(amount)
            local sym = amount >= 0 and "" or "-"
            if fmtStyle == "truncate" then
                local idx = 1
                local truncLen = #truncateWords
                while amount >= 1000 do
                    idx = idx + 1
                    if idx < truncLen and amount >= 1000 then
                        amount = amount / 1000
                    else
                        break
                    end
                end
                local word = truncateWords[idx]
                if idx == 1 then
                    text = tostring(amount)
                else
                    text = string.format("%.2f", amount)
                    local textLen = string.len(text)
                    if textLen >= 6 then
                        text = string.sub(text, 1, -4)
                    elseif textLen == 5 then
                        text = string.sub(text, 1, -2)
                    end
                    if string.find(text, "%.00$") then
                        text = string.sub(text, 1, -4)
                    elseif string.find(text, "%.%d0$") then
                        text = string.sub(text, 1, -2)
                    end
                end
                text = text .. word
            elseif fmtStyle == "commaSep" then
                local abs = math.abs(amount)
                local remain = abs % 1000
                local concat = {amount >= 0 and "" or "-", abs >= 1000 and string.format("%03d", remain) or remain}
                while abs >= 1000 do
                    abs = (abs - remain) / 1000
                    remain = abs % 1000
                    table.insert(concat, 2, ",")
                    table.insert(concat, 2, abs >= 1000 and string.format("%03d", remain) or remain)
                end
                text = table.concat(concat)
            end
        end

        -- color text
        text = self:TextWithColor(text, school, isPet, isMelee)

        -- add icons
        if (icon ~= "none" and spellID) then
			local iconText = "|T"..GetSpellTexture(spellID)..":0|t"

			if (icon == "both") then
				text = iconText..text..iconText
			elseif (icon == "left") then
				text = iconText..text
			elseif (icon == "right") then
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

    self:DisplayText(guid, nameplate, text, crit, isPet, isMelee)
end

function ClassicNFCT:MissEvent(guid, nameplate, spellID, spellSchool, missType, spellName)
    local text
    local icon = self.db.global.formatting.icon

    if (icon == "only") then
        return
    end

    local isMelee = spellName == "melee"
    local isPet = spellSchool == "pet"
    text = self:TextWithColor(self.L.MISS_EVENT_STRINGS[missType], spellSchool, isPet, isMelee)

    -- add icons
    if (icon ~= "none" and spellID) then
        local iconText = "|T"..GetSpellTexture(spellID)..":0|t"

        if (icon == "both") then
            text = iconText..text..iconText
        elseif (icon == "left") then
            text = iconText..text
        elseif (icon == "right") then
            text = text..iconText
        end
    end

    self:DisplayText(guid, nameplate, text, false, isPet, isMelee)
end
