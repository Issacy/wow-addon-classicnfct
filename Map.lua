function ClassicNFCT:CreateMap()
    local inner = {len = 0, cnt = 0, index = {}, container = {}}
    local map = {__inner = inner}
    function map:count()
        return inner.cnt
    end
    function map:iter()
        local i = 1
        local ret
        return function()
            while true do
                if i > inner.len then
                    return
                end
                ret = inner.container[i]
                if ret then break end
                i = i + 1
            end
            i = i + 1
            return ret[1], ret[2]
        end
    end
    function map:emplace(key, val)
        if key == nil then return end
        local idx = inner.index[key]
        if idx then
            inner.container[idx][2] = val
            return
        end
        inner.len = inner.len + 1
        inner.container[inner.len] = {key, val}
        inner.index[key] = inner.len
        inner.cnt = inner.cnt + 1
    end
    function map:remove(key)
        local idx = inner.index[key]
        if not idx then return end
        local ret = inner.container[idx]
        inner.container[idx] = nil
        inner.index[key] = nil
        inner.cnt = inner.cnt - 1
        return ret[2]
    end
    function map:at(key)
        local idx = inner.index[key]
        if not idx then return end
        return inner.container[idx][2]
    end
    function map:clear()
        if inner.cnt > 0 then
            inner.container = {}
            inner.cnt = 0
            inner.len = 0
            inner.index = {}
        end
    end
    function map:gc()
        if inner.len == 0 then return end
        local container = {}
        local len = 0
        if inner.cnt > 0 then
            for i = 1, inner.len do
                local ret = inner.container[i]
                if ret then
                    len = len + 1
                    container[len] = ret
                    inner.index[ret[1]] = len
                end
            end
        end
        inner.container = container
        inner.len = len
    end
    return map
end