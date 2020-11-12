local SharedMedia = LibStub("LibSharedMedia-3.0")

local FONT_SIZE = 30

function ClassicNFCT:CreateText()
    self.cache = {}
    self.frame = CreateFrame("Frame", nil, UIParent)
end

function ClassicNFCT:GetFontPath(fontName)
    local fontPath = SharedMedia:Fetch("font", fontName)

    if (fontPath == nil) then
        fontPath = "Fonts\\FRIZQT__.TTF"
    end

    return fontPath
end

function ClassicNFCT:GetFontString()
    local fontString, record

    if (next(self.cache)) then
        fontString = table.remove(self.cache)
    else
        fontString = self.frame:CreateFontString()
        fontString:SetFont(self:GetFontPath(self.db.global.font), FONT_SIZE, self.db.global.fontFlag)
        fontString:SetParent(self.frame)
        -- fontString:SetIgnoreParentScale(false)
        fontString:SetIgnoreParentAlpha(true)
        fontString:SetDrawLayer("BACKGROUND")
        fontString.ClassicNFCT = {}
    end

    record = fontString.ClassicNFCT
    record.fontSize = FONT_SIZE
    record.fontFlag = self.db.global.fontFlag
    fontString:SetText("")
    fontString:SetAlpha(1)
    fontString:SetScale(1)
    if self.db.global.textShadow then
        fontString:SetShadowOffset(1, -1)
    else
        fontString:SetShadowOffset(0, 0)
    end
    fontString:Show()

    return fontString
end

function ClassicNFCT:RecycleFontString(fontString)
    fontString.ClassicNFCT = {}
    
    fontString:SetAlpha(0)
    fontString:ClearAllPoints()
    fontString:SetParent(self.frame)
    fontString:Hide()

    table.insert(self.cache, fontString)
end

local DAMAGE_TYPE_COLORS = {
    [SCHOOL_MASK_PHYSICAL] = "FFFF00",
    [SCHOOL_MASK_HOLY] = "FFE680",
    [SCHOOL_MASK_FIRE] = "FF8000",
    [SCHOOL_MASK_NATURE] = "4DFF4D",
    [SCHOOL_MASK_FROST] = "80FFFF",
    [SCHOOL_MASK_SHADOW] = "8080FF",
    [SCHOOL_MASK_ARCANE] = "FF80FF",
}

local DAMAGE_TYPE_COLORS_SIMPLE = {
	["melee"] = "FFFFFF",
    ["pet"] = "CC8400",
    ["spell"] = "FFFF00",
}

function ClassicNFCT:TextWithColor(text, school, isPet, isMelee)
    -- color text
    local textColor
    if isMelee then
        textColor = DAMAGE_TYPE_COLORS_SIMPLE["melee"]
    elseif isPet then
        textColor = DAMAGE_TYPE_COLORS_SIMPLE["pet"]
    else
        if not self.db.global.damageColor then
            textColor = DAMAGE_TYPE_COLORS_SIMPLE["spell"]
        else
            local c, r, g, b = 0, 0, 0, 0
            for k, v in pairs(DAMAGE_TYPE_COLORS) do
                if bit.band(k, school) ~= 0 then
                    c = c + 1
                    r = r + tonumber(string.sub(v, 1, 2), 16)
                    g = g + tonumber(string.sub(v, 3, 4), 16)
                    b = b + tonumber(string.sub(v, 5, 6), 16)
                end
            end
            if c == 0 then
                textColor = DAMAGE_TYPE_COLORS_SIMPLE["spell"]
            else
                textColor = string.format("%02x%02x%02x", r / c, g / c, b / c)
            end
        end
    end
    return "|Cff".. textColor .. text .. "|r"
end

function ClassicNFCT:GetNamePlateForGUID(guid)
    local unit, nameplate
    repeat
        if not guid then break end
        unit = self.guidToUnit[guid]
        if not unit or UnitIsDead(unit) then break end
        nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        if not nameplate or not nameplate:IsShown() then
            nameplate = nil
        end
    until true
    return unit, nameplate
end

function ClassicNFCT:DisplayText(guid, nameplate, text, crit, pet, melee)
    local anim = self.guidToAnim:at(guid)
    if not anim then
        anim = self:CreateAnimationGroup()
        self.guidToAnim:emplace(guid, anim)
    end

    local fontString = self:GetFontString()
    local record = fontString.ClassicNFCT

    record.text = text
    fontString:SetText(text)

    record.crit = crit
    record.pet = pet
    record.melee = melee

    record.scale = pet and self.db.global.petFormatting.scale
        or (melee and self.db.global.autoAttackFormatting.scale)
        or 1
    
    record.animatingStartTime = GetTime()
    anim:add(fontString, record)

    self:AnimateUpdate()
end
