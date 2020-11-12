local self = ClassicNFCT

local L = LibStub('AceLocale-3.0'):GetLocale("ClassicNFCT")
L.UI = setmetatable(L.UI or {}, { __index = function(t, k) return k end, })
self.L = L

self.unitToGuid = {}
self.guidToUnit = {}

-- setup db
self:CreateDB()

self:CreateText()
self:CreateAnimation()

-- setup chat commands
self:RegisterChatCommand("cnfct", "OpenMenu")

-- setup menu
self:CreateMenu()
