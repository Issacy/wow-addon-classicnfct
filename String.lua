function ClassicNFCT:SplitString(src, sep, ret, from, to, plain)
    local len = src and src:len() or 0
    from = tonumber(from)
    if not from then
        from = 1
    elseif from < 0 then
        from = len + to + 1
    end
    to = tonumber(to)
    if not to then
        to = len
    elseif to < 0 then
        to = len + to + 1
    end
    local function iter()
        if from > to then return end
        local i, j = src:find(sep, from, plain)
        if not i then
            local sub = src:sub(from, to)
            from = to + 1
            return sub
        end
        i = i - 1
        if i > to then i = to end
        local sub = src:sub(from, i)
        from = j + 1
        return sub
    end
    return function()
        local succ, ret = pcall(iter)
        if not succ then return end
        return ret
    end
end
