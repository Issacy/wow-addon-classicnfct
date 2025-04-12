local SharedMedia = LibStub("LibSharedMedia-3.0")

local TRUNCATE_WORDS = {"", "K", "M", "B"}

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

local fontPath, fontName, fontFlag, fontSize
local fontVersion, fontTest
local cache, frame

local fmtConcat = {}

function ClassicNFCT:CreateText()
    frame = CreateFrame("Frame", nil, UIParent)
    cache = self:CreatePool(function()
        local fontString = frame:CreateFontString()
        fontString:SetParent(frame)
        -- fontString:SetIgnoreParentScale(false)
        fontString:SetIgnoreParentAlpha(true)
        return fontString
    end)
    fontVersion = self:CreateBigInt()
    fontTest = cache:get()
    fontTest:SetAlpha(0)
    fontTest:Hide()
end

function ClassicNFCT:GetFontString(record)
    local newFontName, newFontFlag, newFontSize = self.db.global.font.choice, self.db.global.font.flag, self.db.global.font.size
    if (newFontName ~= fontName or newFontFlag ~= fontFlag or newFontSize ~= fontSize) then
        local newFontPath = SharedMedia:Fetch("font", newFontName)
        local succ1, succ2 = pcall(fontTest.SetFont, fontTest, newFontPath, newFontSize, newFontFlag)
        if not succ1 or not succ2 then return self:ShowDialog("FONT_INVALID") end
        fontPath, fontName, fontFlag, fontSize = newFontPath, newFontName, newFontFlag, newFontSize
        fontVersion:increment()
    end

    local fontString = cache:get()
    if record.fontVersion:compare(fontVersion) ~= 0 then
        fontString:SetFont(fontPath, fontSize, fontFlag)
        record.fontVersion:copy(fontVersion)
    end

    fontString:SetAlpha(1)
    fontString:SetScale(1)
    if self.db.global.font.shadow then
        fontString:SetShadowOffset(1, -1)
    else
        fontString:SetShadowOffset(0, 0)
    end

    record.fontString = fontString
end

function ClassicNFCT:RecycleFontString(record)
    local fontString = record.fontString
    if not fontString then return end
    fontString:SetAlpha(0)
    fontString:ClearAllPoints()
    fontString:SetParent(frame)
    fontString:Hide()
    cache:release(fontString)
    record.fontString = nil
    record.fontVersion:reset()
end

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
                r = r + tonumber(v:sub(1, 2), 16)
                g = g + tonumber(v:sub(3, 4), 16)
                b = b + tonumber(v:sub(5, 6), 16)
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

function ClassicNFCT:FormatNumber(amount)
    local fmtStyle = self.db.global.style.numStyle

    if fmtStyle == "disable" then return tostring(amount) end

    local abs = math.abs(amount)
    local sym = amount >= 0 and "" or "-"

    if fmtStyle == "truncate" then
        local idx = 1
        local truncLen = #TRUNCATE_WORDS
        while abs >= 1000 do
            idx = idx + 1
            if idx < truncLen and abs >= 1000 then
                abs = abs / 1000
            else
                break
            end
        end
        local word = TRUNCATE_WORDS[idx]
        local text
        if idx == 1 then
            text = tostring(abs)
        else
            text = string.format("%.2f", abs)
            local textLen = text:len()
            if textLen >= 6 then
                text = text:sub(1, -4)
            elseif textLen == 5 then
                text = text:sub(1, -2)
            end
        end
        return sym .. text .. word
    end

    -- if fmtStyle == "commaSep" then
        local remain = abs % 1000
        wipe(fmtConcat)
        fmtConcat[1] = sym
        fmtConcat[2] = abs >= 1000 and string.format("%03d", remain) or remain
        while abs >= 1000 do
            abs = (abs - remain) / 1000
            remain = abs % 1000
            table.insert(fmtConcat, 2, ",")
            table.insert(fmtConcat, 2, abs >= 1000 and string.format("%03d", remain) or remain)
        end
        return table.concat(fmtConcat)
    -- end
end
