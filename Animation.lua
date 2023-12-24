local LibEasing = LibStub("LibEasing-1.0")

local ANIMATION_HORIZONTAL_PADDING = 10
local ANIMATION_VERTICAL_PADDING = 10
local ANIMATION_VERTICAL_OFFSET_PERCENT = -0.4
local ANIMATION_ALPHA_OUT_PERCENT = 0.5
local ANIMATION_CRIT_SCALE = 1.5
local ANIMATION_CRIT_SCALE_PERCENT = 0.1
local ANIMATION_CRIT_MAX_SCALE = 3
local ANIMATION_CRIT_MIN_SCALE = 2.5
local ANIMATION_CRIT_SCALE_UP_PERCENT = 0.2
local LAYER = "BACKGROUND"
local LAYER_SUBLEVEL_PET = -8
local LAYER_SUBLEVEL_PET_CRIT = -7
local LAYER_SUBLEVEL_MELEE = -6
local LAYER_SUBLEVEL_MELEE_CRIT = -5
local LAYER_SUBLEVEL = -4
local LAYER_SUBLEVEL_CRIT = -3

local screenHeight

local function FontStringSorter(fontStringA, fontStringB)
    return fontStringA.ClassicNFCT.startTime < fontStringB.ClassicNFCT.startTime
end

function ClassicNFCT:CreateAnimation()
    self.guidToAnim = self:CreateMap()
    self.wilds = {}
    self.refs = self:CreateMap()
    self.wildAnim = self:CreateAnimationGroup()
    self.wildFrame = CreateFrame("Frame", nil, UIParent)
    self.wildFrame:SetPoint("CENTER")
    self.animUpdateFunc = function() self:AnimateUpdate() end
end

function ClassicNFCT:WildFontString(fontString)
    table.insert(self.wilds, fontString)
end

function ClassicNFCT:RefFontString(fontString)
    local guid = fontString.ClassicNFCT.guid
    local fontStrings = self.refs:at(guid)
    if not fontStrings then
        fontStrings = {}
        self.refs:emplace(guid, fontStrings)
    end
    table.insert(fontStrings, fontString)
end


function ClassicNFCT:CreateAnimationGroup()
    local this = self
    local anim = {
        _version = 1,
        _middle = {left = {}, right = {}},
        _up = {}, _down = {},
        _countMap = this:CreateMap(), _count = 0,
    }

    function anim:count(guid)
        if not guid then return self._count end
        return self._countMap:at(guid) or 0
    end

    function anim:iterCountMap() return self._countMap:iter() end

    function anim:add(fontString)
        local record = fontString.ClassicNFCT
        
        self._countMap:emplace(record.guid, self:count(record.guid) + 1)
        self._count = self._count + 1
        record.width = fontString:GetUnboundedStringWidth() * record.scale
        
        local move = self._middle.center
        self._middle.center = fontString
        if not move then return end

        local x, y = self:_pos()
        if y == 0 then
            table.insert(x > 0 and self._middle.left or self._middle.right, 1, move)
            return
        end

        local dx, dy, pop = 0, 0
        local wx = x > 0 and 1 or -1
        local wy = y > 0 and 1 or -1
        local ud = wy > 0 and self._up or self._down
        local n = #ud
        while true do
            if dy ~= y then
                dy = dy + wy
            elseif dx ~= x then
                dx = dx + wx
            end
            if dy == y and dx == x then break end
            local line = ud[n - dy * wy + 1]
            if dx == 0 then
                pop = line.center
                line.center = move
                move = pop
            else
                local ix = dx * wx
                local side = wx > 0 and line.left or line.right
                pop = side[ix]
                side[ix] = move
                move = pop
            end
        end
        local iy = n - dy * wy + 1
        if iy == 0 then
            table.insert(ud, 1, {center = move, left = {}, right = {}})
        else
            (wx > 0 and ud[iy].left or ud[iy].right)[dx * wx] = move
        end
    end

    function anim:_pos()
        local un, dn = #self._up, #self._down

        -- up most
        local x, y = 0, un + 1
        local r = y ^ 2
        
        -- down most
        local tx, ty = 0, -(dn + 1)
        local tr = ty ^ 2
        if tr < r then
            x, y, r = tx, ty, tr
        end

        -- left most
        local line = self._middle
        tx, ty = #line.left + 1, 0
        tr = tx ^ 2
        if tr < r then
            x, y, r = tx, ty, tr
        end

        -- right most
        tx = -(#line.right + 1)
        tr = tx ^ 2
        if tr < r then
            x, y, r = tx, ty, tr
        end
        
        -- up side bottom -> top left & right most
        for i = un, 1, -1 do
            line = self._up[i]
            tx, ty = #line.left + 1, un - i + 1
            local tySqr = ty ^ 2
            tr = tx ^ 2 + tySqr
            if tr < r then
                x, y, r = tx, ty, tr
            end
            tx = -(#line.right + 1)
            tr = tx ^ 2 + tySqr
            if tr < r then
                x, y, r = tx, ty, tr
            end
        end
        -- down side top -> bottom left & right most
        for i = dn, 1, -1 do
            line = self._down[i]
            tx, ty = #line.left + 1, -(dn - i + 1)
            local tySqr = ty ^ 2
            tr = tx ^ 2 + tySqr
            if tr < r then
                x, y, r = tx, ty, tr
            end
            tx = -(#line.right + 1)
            tr = tx ^ 2 + tySqr
            if tr < r then
                x, y, r = tx, ty, tr
            end
        end

        return x, y
    end

    function anim:_updateOneLR(lr, now, targetGUID, onScreen)
        for i = #lr, 1, -1 do
            local fontString = lr[i]
            local record = fontString.ClassicNFCT
            local elapsed = now - record.startTime
            if not this:DoAnimate(record, elapsed, targetGUID, onScreen) then
                table.remove(lr, i)
                self:_removeOne(fontString, this.RecycleFontString)
            end
        end
    end

    function anim:_updateOne(line, now, targetGUID, onScreen)
        self:_updateOneLR(line.left, now, targetGUID, onScreen)
        self:_updateOneLR(line.right, now, targetGUID, onScreen)

        local fontString = line.center
        if not fontString then return end
        
        local record = fontString.ClassicNFCT
        local elapsed = now - record.startTime
        if this:DoAnimate(record, elapsed, targetGUID, onScreen) then
            return
        end

        self:_removeOne(fontString, this.RecycleFontString)
        local ln, rn = #line.left, #line.right
        if ln == 0 and rn == 0 then
            line.center = nil
        else
            line.center = table.remove(ln > rn and line.left or line.right, 1)
        end
    end

    function anim:_updateLR(line, now, targetGUID, onScreen)
        self:_updateOne(line, now, targetGUID, onScreen)
        if line.center then return end
        local un, dn = #self._up, #self._down
        if un == 0 and dn == 0 then return end
        self._middle = table.remove(un > dn and self._up or self._down)
    end

    function anim:_updateUD(lines, now, targetGUID, onScreen)
        for i = #lines, 1, -1 do
            local line = lines[i]
            self:_updateOne(line, now, targetGUID, onScreen)
            if not line.center then
                table.remove(lines, i)
            end
        end
    end

    function anim:_layout(line, y, nameplate, onScreen)
        local x, half = 0, 0
        local fontString, record = line.center
        if not fontString then return end
        
        record = fontString.ClassicNFCT
        record.x, record.y = x, y
        this:DoLayout(fontString, record, nameplate, onScreen)
        half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
        local xl, xr = half, -half
        for _, fontString in ipairs(line.left) do
            record = fontString.ClassicNFCT
            half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
            xl = xl + half
            record.x, record.y = xl, y
            this:DoLayout(fontString, record, nameplate, onScreen)
            xl = xl + half
        end
        for _, fontString in ipairs(line.right) do
            record = fontString.ClassicNFCT
            half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
            xr = xr - half
            record.x, record.y = xr, y
            this:DoLayout(fontString, record, nameplate, onScreen)
            xr = xr - half
        end
    end

    function anim:update(nameplate, now, targetGUID, onScreen)
        self:_updateUD(self._up, now, targetGUID, onScreen)
        self:_updateUD(self._down, now, targetGUID, onScreen)
        self:_updateLR(self._middle, now, targetGUID, onScreen)
        
        self:_layout(self._middle, 0, nameplate, onScreen)
        local lineHeight = this.db.global.layout.lineHeight + ANIMATION_VERTICAL_PADDING
        for i = #self._up, 1, -1 do
            self:_layout(self._up[i], lineHeight * (#self._up - i + 1), nameplate, onScreen)
        end
        for i = #self._down, 1, -1 do
            self:_layout(self._down[i], lineHeight * -(#self._down - i + 1), nameplate, onScreen)
        end
    end

    function anim:_removeOne(fontString, func)
        local record = fontString.ClassicNFCT
        self._countMap:emplace(record.guid, self:count(record.guid) - 1)
        self._count = self._count - 1
        func(this, fontString)
    end

    function anim:_clear(line, func)
        local fontString
        if line.center then
            self:_removeOne(line.center, func)
        end
        for _, fontString in ipairs(line.left) do
            self:_removeOne(fontString, func)
        end
        for _, fontString in ipairs(line.right) do
            self:_removeOne(fontString, func)
        end
    end

    function anim:clear(func)
        self:_clear(self._middle, func)
        for _, line in ipairs(self._up) do
            self:_clear(line, func)
        end
        for _, line in ipairs(self._down) do
            self:_clear(line, func)
        end
        self._middle, self._up, self._down =
            {left = {}, right = {}}, {}, {}
    end

    return anim
end

function ClassicNFCT:DoAlpha(elapsed, duration, startAlpha)
    local alpha = startAlpha
    local sep = duration * ANIMATION_ALPHA_OUT_PERCENT
    if elapsed >= sep then
        alpha = LibEasing.Linear(elapsed - sep, startAlpha, -startAlpha, duration - sep)
    end
    return math.max(0, math.min(1, alpha))
end

function ClassicNFCT:DoCritScale(elapsed, duration)
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

function ClassicNFCT:DoAnimate(record, elapsed, targetGUID, onScreen)
    local duration = self.db.global.animations.animationDuration
    if elapsed > duration then return false end

    local targetStyle = 0
    if not onScreen then
        if (targetGUID ~= record.guid and self.db.global.style.useOffTarget) then
            targetStyle = 1
        end
    elseif (self.db.global.style.useOnScreen) then
        targetStyle = 2
    end

    -- alpha
    local startAlpha = self.db.global.style.alpha
    if targetStyle == 1 then
        startAlpha = self.db.global.style.offTarget.alpha
    elseif targetStyle == 2 then
        startAlpha = self.db.global.style.onScreen.alpha
    end

    if record.crit then
        record.alpha = startAlpha
    else
        record.alpha = self:DoAlpha(elapsed, duration, startAlpha)
    end

    -- scale
    record.targetScale = self.db.global.style.scale
    if targetStyle == 1 then
        record.targetScale = self.db.global.style.offTarget.scale
    elseif targetStyle == 2 then
        record.targetScale = self.db.global.style.onScreen.scale
    end
    
    local critScale = 1
    record.critScale = 1
    if record.crit then
        critScale = self:DoCritScale(elapsed, duration)
        record.critScale = ANIMATION_CRIT_SCALE
    end
    
    record.finalScale = record.scale * critScale
    
    record.offsetY = 0
    if not record.crit then
        local moveUp = self.db.global.layout.lineHeight
        record.offsetY = LibEasing.Linear(elapsed, moveUp * ANIMATION_VERTICAL_OFFSET_PERCENT, moveUp, duration)
    end
    
    return true
end

function ClassicNFCT:DoLayout(fontString, record, nameplate, onScreen)
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
    
    local offsetX, offsetY = record.x, (self.db.global.layout.distance / record.targetScale + record.y + record.offsetY)

    if onScreen then
        offsetX = offsetX + self.db.global.layout.onScreenPos.centerOffsetX
        offsetY = offsetY + self.db.global.layout.onScreenPos.centerOffsetY
    end

    fontString:SetPoint("BOTTOM", nameplate, "CENTER", offsetX / record.finalScale, offsetY / record.finalScale)
end

function ClassicNFCT:AnimateUpdate()
    local currentScreenHeight = GetScreenHeight()
    if screenHeight ~= currentScreenHeight then
        screenHeight = currentScreenHeight
        self.wildFrame:SetSize(GetScreenWidth(), currentScreenHeight)
    end

    local now, targetGUID, attackableTargetGUID = GetTime(), UnitGUID("target"), self:GetAttackableNamePlateTargetGUID()
    local attackableTargetAnim = attackableTargetGUID and self.guidToAnim:at(attackableTargetGUID)
    
    for guid, anim in self.guidToAnim:iter() do
        local _, nameplate = self:GetNamePlateForGUID(guid)
        if not nameplate then
            anim:clear(self.RefFontString)
            self.guidToAnim:remove(guid, true)
        else
            if self.wildAnim:count(guid) > 0 then
                self.wildAnim:clear(self.RefFontString)
            end
        end
    end
    self.guidToAnim:gc()

    for guid, anim in self.guidToAnim:iter() do
        if anim:count() ~= anim:count(guid) then
            local needReRef = false
            for animGUID, count in anim:iterCountMap() do
                if count > 0 and animGUID ~= guid and self.guidToAnim:at(animGUID) then
                    needReRef = true
                    break
                end
            end
            if needReRef then anim:clear(self.RefFontString) end
        end
    end

    for guid, fontStrings in self.refs:iter() do
        local anim = self.guidToAnim:at(guid)
        if anim then
            anim:clear(self.RefFontString)
        end
    end

    for guid, fontStrings in self.refs:iter() do
        local anim
        if guid ~= attackableTargetGUID then
            anim = self.guidToAnim:at(guid)
        end
        if anim then
            table.sort(fontStrings, FontStringSorter)
            for _, fontString in ipairs(fontStrings) do anim:add(fontString) end
        else
            for _, fontString in ipairs(fontStrings) do self:WildFontString(fontString) end
        end
    end
    self.refs:clear()

    if #(self.wilds) > 0 then
        table.sort(self.wilds, FontStringSorter)
        local anim = attackableTargetAnim or self.wildAnim
        for _, fontString in ipairs(self.wilds) do anim:add(fontString) end
        self.wilds = {}
    end
    
    for guid, anim in self.guidToAnim:iter() do
        local _, nameplate = self:GetNamePlateForGUID(guid)
        anim:update(nameplate, now, targetGUID, false)
    end
    self.wildAnim:update(self.wildFrame, now, nil, true)
    
    local stopUpdate = self.guidToAnim:count() == 0
    if not stopUpdate then
        stopUpdate = true
        for _, anim in self.guidToAnim:iter() do
            stopUpdate = stopUpdate and anim:count() == 0
            if not stopUpdate then break end
        end
    end
    if stopUpdate then stopUpdate = self.wildAnim:count() == 0 end

    local animUpdateFunc = self.frame:GetScript("OnUpdate")
    if stopUpdate then
        if animUpdateFunc then
            -- nothing in the animation list, so just kill the onupdate
            self.frame:SetScript("OnUpdate", nil)
        end
        return
    end

    -- start onupdate if it's not already running
    if not animUpdateFunc then
        self.frame:SetScript("OnUpdate", self.animUpdateFunc)
    end
end
