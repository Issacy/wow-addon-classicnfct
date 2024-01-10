local cache

function ClassicNFCT:CreateMap()
    if not cache then cache = self:CreatePool(function() return {} end) end
    
    local inner = {len = 0, cnt = 0, index = {}, container = {}, version = 0}
    local map = {}

    function map:trim(force)
        if not force and (inner.len == 0 or inner.len - inner.cnt < inner.cnt) then return end
        local len = 0
        for i = 1, inner.len do
            local kv = inner.container[i]
            if kv then
                len = len + 1
                inner.container[i] = nil
                inner.container[len] = kv
                inner.index[kv[1]] = len
            end
        end
        inner.len = len
        inner.version = inner.version + 1
    end
    function map:count() return inner.cnt end
    function map:iter()
        local i = 1
        local kv
        local version = inner.version
        return function()
            if inner.version ~= version then error("gc triggered during iter") end
            while true do
                if i > inner.len then
                    return
                end
                kv = inner.container[i]
                if kv then break end
                i = i + 1
            end
            i = i + 1
            return kv[1], kv[2]
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
        local kv = cache:get()
        kv[1] = key
        kv[2] = val
        inner.container[inner.len] = kv
        inner.index[key] = inner.len
        inner.cnt = inner.cnt + 1
    end
    function map:remove(key, trim)
        local idx = inner.index[key]
        if not idx then return end
        local kv = inner.container[idx]
        cache:release(kv)
        inner.container[idx] = nil
        inner.index[key] = nil
        inner.cnt = inner.cnt - 1
        if trim == nil or trim then self:trim() end
        return kv[2]
    end
    function map:at(key)
        local idx = inner.index[key]
        if not idx then return end
        return inner.container[idx][2]
    end
    function map:clear()
        if inner.cnt > 0 then
            for i = 1, inner.len do
                local kv = inner.container[i]
                if kv then
                    cache:release(kv)
                    inner.container[i] = nil
                end
            end
            wipe(inner.index)
            inner.cnt = 0
            inner.len = 0
        end
    end
    return map
end
