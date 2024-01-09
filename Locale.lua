local function Create(t)
    return setmetatable(t or {}, { __index = function(t, k) return k end, })
end

function ClassicNFCT:CreateLocale()
    local L = LibStub('AceLocale-3.0'):GetLocale("ClassicNFCT")
    L.UI = Create(L.UI)
    L.CMD = Create(L.CMD)
    self.L = L
end
