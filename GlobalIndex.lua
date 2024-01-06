local maxIndex = 9007199254740991 -- 2 ^ 53 - 1

local function Create()
    local index = {_vals = {0}}
    function index:increment()
        local carry = false
        for _, v in ipairs(self._vals) do
            if add then
                if v == maxIndex then
                    v = 0
                else
                    v = v + 1
                    carry = false
                    break
                end
            else
                if v == maxIndex then
                    v = 0
                    carry = true
                else
                    v = v + 1
                    break
                end
            end
        end
        if carry then table.insert(self._vals, 1) end
    end
    function index:compare(other)
        local vs1, vs2 = self._vals, other._vals
        local l1, l2 = #vs1, #vs2
        if l1 < l2 then return -1 end
        if l1 > l2 then return 1 end
        for i = l1, 1, -1 do
            local v1, v2 = vs1[i], vs2[i]
            if v1 < v2 then return -1 end
            if v1 > v2 then return 1 end
        end
        return 0
    end
    function index:copy()
        local new = Create()
        for _, v in ipairs(self._vals) do
            table.insert(new._vals, v)
        end
        return new
    end
    return index
end

local gIndex = Create()

function ClassicNFCT:NewGlobalIndex()
    local index = gIndex:copy()
    index:increment()
    return index
end
