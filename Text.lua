local SharedMedia = LibStub("LibSharedMedia-3.0")

local truncateWords = {"", "K", "M", "B"}

local fontName, fontFlag, fontSize
local fontPath

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

function ClassicNFCT:GetFontString(guid)
    local fontString, record
    local newFontName, newFontFlag, newFontSize = self.db.global.font.choice, self.db.global.font.flag, self.db.global.font.size
    if (newFontName ~= fontName or newFontFlag ~= fontFlag or newFontSize ~= fontSize) then
        fontName, fontFlag, fontSize = newFontName, newFontFlag, newFontSize
        fontPath = self:GetFontPath(fontName)
        for _, fontString in ipairs(self.cache) do
            fontString:SetFont(fontPath, fontSize, fontFlag)
        end
    end

    if (next(self.cache)) then
        fontString = table.remove(self.cache)
    else
        fontString = self.frame:CreateFontString()
        fontString:SetFont(fontPath, fontSize, fontFlag)
        fontString:SetParent(self.frame)
        -- fontString:SetIgnoreParentScale(false)
        fontString:SetIgnoreParentAlpha(true)
        fontString.ClassicNFCT = {}
    end

    record = fontString.ClassicNFCT
    record.guid = guid
    record.fontSize = FONT_SIZE
    record.fontFlag = self.db.global.font.flag
    fontString:SetText("")
    fontString:SetAlpha(1)
    fontString:SetScale(1)
    if self.db.global.font.shadow then
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

local SCHOOL_MASK_PHYSICAL = 2 ^ 0
local SCHOOL_MASK_HOLY = 2 ^ 1
local SCHOOL_MASK_FIRE = 2 ^ 2
local SCHOOL_MASK_NATURE = 2 ^ 3
local SCHOOL_MASK_FROST = 2 ^ 4
local SCHOOL_MASK_SHADOW = 2 ^ 5
local SCHOOL_MASK_ARCANE = 2 ^ 6

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
    ["spell"] = "FFFF00",
	["melee"] = "FFFFFF",
    ["pet_spell"] = "CC8400",
    ["pet_melee"] = "CCCCCC",
}

function ClassicNFCT:TextWithColor(text, school, isPet, isMelee)
    -- color text
    local textColor
    if not self.db.global.style.dmgTypeColor or not school then
        if not isPet then
            textColor = isMelee and DAMAGE_TYPE_COLORS_SIMPLE["melee"] or DAMAGE_TYPE_COLORS_SIMPLE["spell"]
        else
            textColor = isMelee and DAMAGE_TYPE_COLORS_SIMPLE["pet_melee"] or DAMAGE_TYPE_COLORS_SIMPLE["pet_spell"]
        end
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
    return "|Cff".. textColor .. text .. "|r"
end

function ClassicNFCT:DisplayText(guid, text, crit, pet, melee)
    local anim = self.guidToAnim:at(guid)
    if not anim then
        anim = self:CreateAnimationGroup()
        self.guidToAnim:emplace(guid, anim)
    end

    local fontString = self:GetFontString(guid)
    local record = fontString.ClassicNFCT

    record.text = text
    fontString:SetText(text)
    record.textWidth = fontString:GetUnboundedStringWidth()

    record.crit = crit
    record.pet = pet
    record.melee = melee

    record.scale = pet and self.db.global.style.pet.scale
        or (melee and self.db.global.style.autoAttack.scale)
        or 1
    
    record.startTime = GetTime()
    -- self:RefFontString(fontString)
    anim:add(fontString)

    self:AnimateUpdate()
end

function ClassicNFCT:FormatNumber(amount)
    local fmtStyle = self.db.global.style.numStyle
    
    if fmtStyle == "disable" then return tostring(amount) end
    
    local abs = math.abs(amount)
    local sym = amount >= 0 and "" or "-"
    
    if fmtStyle == "truncate" then
        local idx = 1
        local truncLen = #truncateWords
        while abs >= 1000 do
            idx = idx + 1
            if idx < truncLen and abs >= 1000 then
                abs = abs / 1000
            else
                break
            end
        end
        local word = truncateWords[idx]
        local text
        if idx == 1 then
            text = tostring(abs)
        else
            text = string.format("%.2f", abs)
            local textLen = string.len(text)
            if textLen >= 6 then
                text = string.sub(text, 1, -4)
            elseif textLen == 5 then
                text = string.sub(text, 1, -2)
            end
        end
        return sym .. text .. word
    end
    
    -- if fmtStyle == "commaSep" then
        local remain = abs % 1000
        local concat = {sym, abs >= 1000 and string.format("%03d", remain) or remain}
        while abs >= 1000 do
            abs = (abs - remain) / 1000
            remain = abs % 1000
            table.insert(concat, 2, ",")
            table.insert(concat, 2, abs >= 1000 and string.format("%03d", remain) or remain)
        end
        return table.concat(concat)
    -- end
end
