--[[
    English Localization (default)
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'enUS', true, true)

L.NUM_TRUNCATION = {
    divider = 1000,
    words = {"", "K", "M", "B", "T"}
}

L.NUM_STYLES = {
    ["truncate"] = "Truncate",
    ["commaSep"] = "Thousands Separator",
    ["disable"] = "Disable",
}

L.ICON_STYLES = {
    ["none"] = "No Icons",
    ["left"] = "Left Side",
    ["right"] = "Right Side",
    ["both"] = "Both Sides",
};

L.FONT_STYLES = {
    [""] = "None",
    ["OUTLINE"] = "Outline",
    ["THICKOUTLINE"] = "Thick Outline",
    ["nil, MONOCHROME"] = "Monochrome",
    ["OUTLINE , MONOCHROME"] = "Monochrome Outline",
    ["THICKOUTLINE , MONOCHROME"] = "Monochrome Thick Outline",
};

L.MISS_EVENT_STRINGS = {
    ["ABSORB"] = "Absorb",
    ["BLOCK"] = "Block",
    ["DEFLECT"] = "Deflect",
    ["DODGE"] = "Dodge",
    ["EVADE"] = "Evade",
    ["IMMUNE"] = "Immune",
    ["MISS"] = "Miss",
    ["PARRY"] = "Parry",
    ["REFLECT"] = "Reflect",
    ["RESIST"] = "Resist",
};
