local function Create(t)
    return setmetatable(type(t) == "table" and t or {}, { __index = function(t, k) return k end, })
end

function ClassicNFCT:CreateLocale()
    local L = LibStub('AceLocale-3.0'):GetLocale("ClassicNFCT")
    L.UI = Create(L.UI)
    L.CMD = Create(L.CMD)
    L.DIALOG = Create(L.DIALOG)
    self.L = L
end
