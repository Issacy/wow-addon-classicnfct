function ClassicNFCT:CreatePool(create)
    local pool = {}
    local inner = {}
    function pool:get() return #inner > 0 and table.remove(inner) or create() end
    function pool:release(e) table.insert(inner, e) end
    return pool
end
