local LibEasing = LibStub("LibEasing-1.0")

local ANIMATION_HORIZONTAL_PADDING = 10
local ANIMATION_VERTICAL_PADDING = 10
local ANIMATION_VERTICAL_OFFSET_PERCENT = -0.5
local ANIMATION_ALPHA_OUT_PERCENT = 0.5
local ANIMATION_CRIT_SCALE = 1.5
local ANIMATION_CRIT_SCALE_PERCENT = 0.1
local ANIMATION_CRIT_MAX_SCALE = 3
local ANIMATION_CRIT_MIN_SCALE = 2.5
local ANIMATION_CRIT_SCALE_UP_PERCENT = 0.2

local FRAME_STRATA = "BACKGROUND"
local FRAME_LEVEL = 0
local LAYER = "BACKGROUND"
local LAYER_SUBLEVEL_PET = -8
local LAYER_SUBLEVEL_PET_CRIT = -7
local LAYER_SUBLEVEL_MELEE = -6
local LAYER_SUBLEVEL_MELEE_CRIT = -5
local LAYER_SUBLEVEL = -4
local LAYER_SUBLEVEL_CRIT = -3

local screenHeight
local animCache, lineCache
local wildAnim, wildFrame
local guidToAnim, animUpdateFunc
local wilds, refs, frame

local function FontStringSorter(fontStringA, fontStringB)
    return fontStringA.ClassicNFCT.sortIndex:compare(fontStringB.ClassicNFCT.sortIndex) < 0 
end

function ClassicNFCT:CreateAnimation()
    animCache = self:CreatePool(function() return self:CreateAnimationGroup() end)
    guidToAnim = self:CreateMap()
    wilds = {}
    refs = self:CreateMap()
    frame = CreateFrame("Frame", nil, UIParent)
    wildAnim = self:CreateAnimationGroup()
    wildFrame = CreateFrame("Frame", nil, UIParent)
    wildFrame:SetPoint("CENTER")
    wildFrame:SetFrameStrata(FRAME_STRATA)
    wildFrame:SetFrameLevel(FRAME_LEVEL)
    animUpdateFunc = function() self:AnimateUpdate() end
end

function ClassicNFCT:ClearAnimation()
    for _, anim in guidToAnim:iter() do
        anim:clear(self.RecycleFontString)
        animCache:release(anim)
    end
    guidToAnim:clear()
    wildAnim:clear(self.RecycleFontString)
end

function ClassicNFCT:WildFontString(fontString)
    table.insert(wilds, fontString)
end

function ClassicNFCT:RefFontString(fontString)
    local guid = fontString.ClassicNFCT.guid
    local fontStrings = refs:at(guid)
    if not fontStrings then
        fontStrings = {}
        refs:emplace(guid, fontStrings)
    end
    table.insert(fontStrings, fontString)
end


function ClassicNFCT:CreateAnimationGroup()
    local this = self

    if not lineCache then lineCache = this:CreatePool(function() return {left = {}, right = {}} end) end
    
    local anim = {}
    local inner = {
        version = 1,
        middle = lineCache:get(),
        up = {}, down = {},
        countMap = this:CreateMap(), count = 0,
    }

    function anim:count(guid)
        if not guid then return inner.count end
        return inner.countMap:at(guid) or 0
    end

    function anim:iterCountMap() return inner.countMap:iter() end

    function anim:add(fontString)
        local record = fontString.ClassicNFCT
        
        inner.countMap:emplace(record.guid, self:count(record.guid) + 1)
        inner.count = inner.count + 1
        record.width = record.textWidth * record.scale
        
        local move = inner.middle.center
        inner.middle.center = fontString
        if not move then return end

        local x, y = inner:pos()

        local dy, iy, line, pop = 0, 0, inner.middle
        local wy = y > 0 and 1 or -1
        local ud = y > 0 and inner.up or inner.down
        local n = #ud
        while dy ~= y and iy < n do
            dy = dy + wy
            iy = dy * wy
            line = ud[iy]
            pop = line.center
            line.center = move
            move = pop
        end
        if dy ~= y then
            line = lineCache:get()
            line.center = move
            table.insert(ud, line)
        else
            -- for optimize, insert at behind, layout need reverse
            table.insert(x > 0 and line.left or line.right, move)
        end
    end

    function inner:pos()
        local un, dn = #self.up, #self.down
        local line = self.middle

        local tx, ty, tr, tySqr

        -- up most
        x, y = 0, un + 1
        local r = y ^ 2
        -- local r = y

        -- left most
        tx, ty = #line.left + 1, 0
        tr = tx ^ 2
        -- tr = tx
        if tr < r then
            x, y, r = tx, ty, tr
        end
        
        -- down most
        tx, ty = 0, -(dn + 1)
        tr = ty ^ 2
        -- tr = -ty
        if tr < r then
            x, y, r = tx, ty, tr
        end

        -- right most
        tx, ty = -(#line.right + 1), 0
        tr = tx ^ 2
        -- tr = -tx
        if tr < r then
            x, y, r = tx, ty, tr
        end
        
        -- prev: up side bottom -> top left & right most
        -- now: top left & right most -> up side bottom
        -- for i = un, 1, -1 do
        for i = 1, un do
            line = self.up[i]
            tx, ty = #line.left + 1, i
            tySqr = ty ^ 2
            tr = tx ^ 2 + tySqr
            -- tr = tx + ty
            if tr < r then
                x, y, r = tx, ty, tr
            end
            tx = -(#line.right + 1)
            tr = tx ^ 2 + tySqr
            -- tr = -tx + ty
            if tr < r then
                x, y, r = tx, ty, tr
            end
        end
        
        -- prev: down side top -> bottom left & right most
        -- now: bottom left & right most -> down side top 
        -- for i = dn, 1, -1 do
        for i = 1, dn do
            line = self.down[i]
            tx, ty = #line.left + 1, -i
            tySqr = ty ^ 2
            tr = tx ^ 2 + tySqr
            -- tr = tx - ty
            if tr < r then
                x, y, r = tx, ty, tr
            end
            tx = -(#line.right + 1)
            tr = tx ^ 2 + tySqr
            -- tr = -tx - ty
            if tr < r then
                x, y, r = tx, ty, tr
            end
        end

        return x, y
    end

    function inner:animAlpha(elapsed, duration, startAlpha)
        local alpha = startAlpha
        local sep = duration * ANIMATION_ALPHA_OUT_PERCENT
        if elapsed >= sep then
            alpha = LibEasing.Linear(elapsed - sep, startAlpha, -startAlpha, duration - sep)
        end
        return math.max(0, math.min(1, alpha))
    end

    function inner:animCrit(elapsed, duration)
        duration = duration * ANIMATION_CRIT_SCALE_PERCENT
        local start, middle, finish = ANIMATION_CRIT_MIN_SCALE, ANIMATION_CRIT_MAX_SCALE, ANIMATION_CRIT_SCALE
        if elapsed < duration then
            local sep = duration * ANIMATION_CRIT_SCALE_UP_PERCENT
            if elapsed < sep then
                return LibEasing.OutCubic(elapsed, start, middle - start, sep)
            else
                return LibEasing.InCubic(elapsed - sep, middle, finish - middle, duration - sep)
            end
        end
        return finish
    end

    function inner:animate(record, elapsed, targetGUID, onScreen)
        local duration = this.db.global.animations.animationDuration
        if elapsed > duration then return false end
    
        local targetStyle = 0
        if not onScreen then
            if (targetGUID ~= record.guid and this.db.global.style.useOffTarget) then
                targetStyle = 1
            end
        else
            targetStyle = 2
        end
    
        -- alpha
        local startAlpha = this.db.global.style.alpha
        if targetStyle == 1 then
            startAlpha = this.db.global.style.offTarget.alpha
        elseif targetStyle == 2 then
            startAlpha = this.db.global.style.onScreen.alpha
        end
    
        if record.crit then
            record.alpha = startAlpha
        else
            record.alpha = self:animAlpha(elapsed, duration, startAlpha)
        end
    
        -- scale
        record.targetScale = this.db.global.style.scale
        if targetStyle == 1 then
            record.targetScale = this.db.global.style.offTarget.scale
        elseif targetStyle == 2 then
            record.targetScale = this.db.global.style.onScreen.scale
        end
        
        local critScale = 1
        record.critScale = 1
        if record.crit then
            critScale = self:animCrit(elapsed, duration)
            record.critScale = ANIMATION_CRIT_SCALE
        end
        
        record.finalScale = record.scale * critScale
        
        record.offsetY = 0
        if not record.crit then
            local moveUp = this.db.global.layout.lineHeight
            record.offsetY = LibEasing.Linear(elapsed, moveUp * ANIMATION_VERTICAL_OFFSET_PERCENT, moveUp, duration)
        end
        
        return true
    end

    function inner:updateLR(lr, now, targetGUID, onScreen)
        for i = #lr, 1, -1 do
            local fontString = lr[i]
            local record = fontString.ClassicNFCT
            local elapsed = now - record.startTime
            if not self:animate(record, elapsed, targetGUID, onScreen) then
                table.remove(lr, i)
                self:removeOne(fontString, this.RecycleFontString)
            end
        end
    end

    function inner:updateLine(line, now, targetGUID, onScreen)
        self:updateLR(line.left, now, targetGUID, onScreen)
        self:updateLR(line.right, now, targetGUID, onScreen)

        local fontString = line.center
        if not fontString then return end
        
        local record = fontString.ClassicNFCT
        local elapsed = now - record.startTime
        if self:animate(record, elapsed, targetGUID, onScreen) then
            return
        end

        self:removeOne(fontString, this.RecycleFontString)
        local ln, rn = #line.left, #line.right
        if ln == 0 and rn == 0 then
            line.center = nil
        else
            line.center = table.remove(ln >= rn and line.left or line.right, 1)
        end
    end

    function inner:updateMiddle(now, targetGUID, onScreen)
        self:updateLine(self.middle, now, targetGUID, onScreen)
        if self.middle.center then return end
        local un, dn = #self.up, #self.down
        if un == 0 and dn == 0 then return end
        lineCache:release(self.middle)
        self.middle = table.remove(un > dn and self.up or self.down, 1)
    end

    function inner:updateUD(lines, now, targetGUID, onScreen)
        for i = #lines, 1, -1 do
            local line = lines[i]
            self:updateLine(line, now, targetGUID, onScreen)
            if not line.center then
                lineCache:release(table.remove(lines, i))
            end
        end
    end

    function inner:layoutOne(fontString, record, nameplate, onScreen)
        fontString:ClearAllPoints()
        fontString:SetParent(nameplate)
        local layerSubLevel
        if record.crit then
            layerSubLevel = LAYER_SUBLEVEL
            if record.melee then layerSubLevel = LAYER_SUBLEVEL_MELEE end
            if record.pet then layerSubLevel = LAYER_SUBLEVEL_PET end
        else
            layerSubLevel = LAYER_SUBLEVEL_CRIT
            if record.melee then layerSubLevel = LAYER_SUBLEVEL_MELEE_CRIT end
            if record.pet then layerSubLevel = LAYER_SUBLEVEL_PET_CRIT end
        end
        fontString:SetDrawLayer(LAYER, layerSubLevel)
        fontString:SetAlpha(record.alpha)
        fontString:SetScale(record.finalScale * record.targetScale)
        
        local offsetX, offsetY = record.x, (this.db.global.layout.distance / record.targetScale + record.y + record.offsetY)
    
        if onScreen then
            offsetX = offsetX + this.db.global.layout.onScreenPos.centerOffsetX
            offsetY = offsetY + this.db.global.layout.onScreenPos.centerOffsetY
        end
    
        fontString:SetPoint("BOTTOM", nameplate, "CENTER", offsetX / record.finalScale, offsetY / record.finalScale)
    end

    function inner:layoutLine(line, y, nameplate, onScreen)
        local x, half = 0, 0
        local fontString, record = line.center
        if not fontString then return end
        
        record = fontString.ClassicNFCT
        record.x, record.y = x, y
        self:layoutOne(fontString, record, nameplate, onScreen)
        half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
        local xl, xr = -half, half
        -- for insert optimize, reverse layout
        local ln, rn = #line.left, #line.right
        for i = ln, 1, -1 do
            fontString = line.left[i]
            record = fontString.ClassicNFCT
            half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
            xl = xl - half
            record.x, record.y = xl, y
            self:layoutOne(fontString, record, nameplate, onScreen)
            xl = xl - half
        end
        for i = rn, 1, -1 do
            fontString = line.right[i]
            record = fontString.ClassicNFCT
            half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
            xr = xr + half
            record.x, record.y = xr, y
            self:layoutOne(fontString, record, nameplate, onScreen)
            xr = xr + half
        end
    end

    function anim:update(nameplate, now, targetGUID, onScreen)
        inner:updateUD(inner.up, now, targetGUID, onScreen)
        inner:updateUD(inner.down, now, targetGUID, onScreen)
        inner:updateMiddle(now, targetGUID, onScreen)
        
        inner:layoutLine(inner.middle, 0, nameplate, onScreen)
        local lineHeight = this.db.global.layout.lineHeight + ANIMATION_VERTICAL_PADDING
        for i = #inner.up, 1, -1 do
            inner:layoutLine(inner.up[i], lineHeight * i, nameplate, onScreen)
        end
        for i = #inner.down, 1, -1 do
            inner:layoutLine(inner.down[i], -lineHeight * i, nameplate, onScreen)
        end
    end

    function inner:removeOne(fontString, func, clear)
        local record = fontString.ClassicNFCT
        if not clear then
            self.countMap:emplace(record.guid, anim:count(record.guid) - 1)
            self.count = self.count - 1
        end
        func(this, fontString)
    end

    function inner:clearLine(line, func)
        local fontString
        if line.center then
            self:removeOne(line.center, func, true)
            line.center = nil
        end
        for i, fontString in ipairs(line.left) do
            self:removeOne(fontString, func, true)
            line.left[i] = nil
        end
        for i, fontString in ipairs(line.right) do
            self:removeOne(fontString, func, true)
            line.right[i] = nil
        end
    end

    function anim:clear(func)
        inner:clearLine(inner.middle, func)
        for i, line in ipairs(inner.up) do
            inner:clearLine(line, func)
            lineCache:release(line)
            inner.up[i] = nil
        end
        for i, line in ipairs(inner.down) do
            inner:clearLine(line, func)
            lineCache:release(line)
            inner.down[i] = nil
        end
        inner.count = 0
        inner.countMap:clear()
    end

    return anim
end

function ClassicNFCT:DisplayText(guid, text, crit, pet, melee)
    local fontString = self:GetFontString(guid, text)
    if not fontString then return end

    local record = fontString.ClassicNFCT

    record.crit = crit
    record.pet = pet
    record.melee = melee

    record.scale = pet and self.db.global.style.pet.scale
        or (melee and self.db.global.style.autoAttack.scale)
        or 1

    if self.db.global.layout.alwaysOnScreen then
        self:WildFontString(fontString)
    else
        local anim = guidToAnim:at(guid)
        if not anim then
            anim = animCache:get()
            guidToAnim:emplace(guid, anim)
        end
        anim:add(fontString)
    end

    self:AnimateUpdate()
end

function ClassicNFCT:AnimateUpdate_OnScreenOnly()
    local needClear = false
    for guid, anim in guidToAnim:iter() do
        needClear = needClear or anim:count() > 0
        anim:clear(self.WildFontString)
    end
    guidToAnim:clear()
    if #(wilds) > 0 then
        if needClear then
            wildAnim:clear(self.WildFontString)
            table.sort(wilds, self.fontStringSorter)
        end
        for i, fontString in ipairs(wilds) do
            wildAnim:add(fontString)
            wilds[i] = nil
        end
    end
end

function ClassicNFCT:AnimateUpdate_NameplateBased()
    -- local attackableTargetGUID = self:GetAttackableNamePlateTargetGUID()
    local attackableTargetAnim -- = attackableTargetGUID and guidToAnim:at(attackableTargetGUID)
    
    for guid, anim in guidToAnim:iter() do
        local _, nameplate = self:GetNamePlateForGUID(guid)
        if not nameplate then
            anim:clear(self.RefFontString)
            animCache:release(guidToAnim:remove(guid, false))
        else
            if wildAnim:count(guid) > 0 then
                wildAnim:clear(self.RefFontString)
            end
        end
    end
    guidToAnim:trim()

    for guid, anim in guidToAnim:iter() do
        if anim:count() ~= anim:count(guid) then
            local needReRef = false
            for guid2, count in anim:iterCountMap() do
                if count > 0 and guid2 ~= guid and guidToAnim:at(guid2) then
                    needReRef = true
                    break
                end
            end
            if needReRef then anim:clear(self.RefFontString) end
        end
    end

    for guid, fontStrings in refs:iter() do
        local anim = guidToAnim:at(guid)
        if anim then
            anim:clear(self.RefFontString)
        end
    end

    for guid, fontStrings in refs:iter() do
        local anim
        if guid ~= attackableTargetGUID then
            anim = guidToAnim:at(guid)
        end
        if anim then
            table.sort(fontStrings, FontStringSorter)
            for _, fontString in ipairs(fontStrings) do anim:add(fontString) end
        else
            for _, fontString in ipairs(fontStrings) do self:WildFontString(fontString) end
        end
    end
    refs:clear()

    if #(wilds) > 0 then
        local anim = wildAnim
        if attackableTargetAnim then
            attackableTargetAnim:clear(self.WildFontString)
            anim = attackableTargetAnim
        end
        table.sort(wilds, FontStringSorter)
        for i, fontString in ipairs(wilds) do
            anim:add(fontString)
            wilds[i] = nil
        end
    end
end

function ClassicNFCT:AnimateUpdate()
    local currentScreenHeight = GetScreenHeight()
    if screenHeight ~= currentScreenHeight then
        screenHeight = currentScreenHeight
        wildFrame:SetSize(GetScreenWidth(), currentScreenHeight)
    end

    if self.db.global.layout.alwaysOnScreen then
        self:AnimateUpdate_OnScreenOnly()
    else
        self:AnimateUpdate_NameplateBased()
    end

    local now, targetGUID = GetTime(), UnitGUID("target")
    
    for guid, anim in guidToAnim:iter() do
        local _, nameplate = self:GetNamePlateForGUID(guid)
        anim:update(nameplate, now, targetGUID, false)
    end
    wildAnim:update(wildFrame, now, nil, true)
    
    local stopUpdate = guidToAnim:count() == 0
    if not stopUpdate then
        stopUpdate = true
        for _, anim in guidToAnim:iter() do
            stopUpdate = stopUpdate and anim:count() == 0
            if not stopUpdate then break end
        end
    end
    if stopUpdate then stopUpdate = wildAnim:count() == 0 end

    local func = frame:GetScript("OnUpdate")
    if stopUpdate then
        if func then
            -- nothing in the animation list, so just kill the OnUpdate
            frame:SetScript("OnUpdate", nil)
        end
        return
    end

    -- start OnUpdate if it's not already running
    if not func then
        frame:SetScript("OnUpdate", animUpdateFunc)
    end
end
