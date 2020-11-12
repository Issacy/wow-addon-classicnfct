--[[
	English Localization (default)
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'enUS', true, 'raw')

L.fmtStyles = {
    ["truncate"] = "Truncate",
    ["commaSep"] = "Comma Seperate",
    ["disable"] = "Disable",
}

L.iconValues = {
    ["none"] = "No Icons",
    ["left"] = "Left Side",
    ["right"] = "Right Side",
    ["both"] = "Both Sides",
    ["only"] = "Icons Only (No Text)",
};

L.fontFlags = {
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
