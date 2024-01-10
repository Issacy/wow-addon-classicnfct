local max = 9007199254740991 -- 2 ^ 53 - 1

function ClassicNFCT:CreateBigInt()
    local bi = {vals = {0}}
    function bi:copy(other)
        wipe(self.vals)
        for i, v in ipairs(other.vals) do
            self.vals[i] = v
        end
    end
    function bi:increment()
        local carry = false
        for i, v in ipairs(self.vals) do
            if carry then
                if v == max then
                    self.vals[i] = 0
                else
                    self.vals[i] = v + 1
                    carry = false
                    break
                end
            else
                if v == max then
                    self.vals[i] = 0
                    carry = true
                else
                    self.vals[i] = v + 1
                    break
                end
            end
        end
        if carry then table.insert(self.vals, 1) end
    end
    function bi:compare(other)
        local vs1, vs2 = self.vals, other.vals
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
    return bi
end
