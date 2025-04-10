--[[
	English Localization (default)
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'enUS', true, 'raw')

L.numStyles = {
    ["truncate"] = "Truncate",
    ["commaSep"] = "Thousands Separator",
    ["disable"] = "Disable",
}

L.iconStyles = {
    ["none"] = "No Icons",
    ["left"] = "Left Side",
    ["right"] = "Right Side",
    ["both"] = "Both Sides",
    ["only"] = "Icons Only (No Text)",
};

L.fontStyles = {
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
