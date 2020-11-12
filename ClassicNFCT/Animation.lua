local LibEasing = LibStub("LibEasing-1.0")

local ANIMATION_HORIZONTAL_PADDING = 10
local ANIMATION_VERTICAL_DISTANCE = 10
local ANIMATION_CRIT_SCALE = 1.3
local ANIMATION_CRIT_MAX_SCALE = 1.7
local ANIMATION_CRIT_MIN_SCALE = 0.5
local ANIMATION_ALPHA_SEP = 0.667
local LINE_HEIGHT = 45

function ClassicNFCT:CreateAnimation()
    self.animating = self:CreateMap()
    self.guidToAnim = {}
    self.animUpdateFunc = function() self:AnimateUpdate() end
end


function ClassicNFCT:CreateAnimationGroup()
    local this = self
    local anim = {
        _version = 1,
        _middle = {left = {}, right = {}},
        _up = {}, _down = {},
    }

    function anim:add(fontString, record)
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
            local ty2 = ty ^ 2
            tr = tx ^ 2 + ty2
            if tr < r then
                x, y, r = tx, ty, tr
            end
            tx = -(#line.right + 1)
            tr = tx ^ 2 + ty2
            if tr < r then
                x, y, r = tx, ty, tr
            end
        end
        -- down side top -> bottom left & right most
        for i = dn, 1, -1 do
            line = self._down[i]
            tx, ty = #line.left + 1, -(dn - i + 1)
            local ty2 = ty ^ 2
            tr = tx ^ 2 + ty2
            if tr < r then
                x, y, r = tx, ty, tr
            end
            tx = -(#line.right + 1)
            tr = tx ^ 2 + ty2
            if tr < r then
                x, y, r = tx, ty, tr
            end
        end

        return x, y
    end

    function anim:_updateOneLR(lr, now, duration, critDuration)
        for i = #lr, 1, -1 do
            local fontString = lr[i]
            local record = fontString.ClassicNFCT
            local elapsed = now - record.animatingStartTime
            if elapsed <= duration then
                this:DoAnimate(fontString, record, elapsed, duration, critDuration)
            else
                table.remove(lr, i)
                this:RecycleFontString(fontString)
            end
        end
    end

    function anim:_updateOne(line, now, duration, critDuration)
        self:_updateOneLR(line.left, now, duration, critDuration)
        self:_updateOneLR(line.right, now, duration, critDuration)

        local fontString = line.center
        if not fontString then return end
        
        local record = fontString.ClassicNFCT
        local elapsed = now - record.animatingStartTime
        if elapsed <= duration then
            this:DoAnimate(fontString, record, elapsed, duration, critDuration)
            return
        end

        this:RecycleFontString(fontString)
        local ln, rn = #line.left, #line.right
        if ln == 0 and rn == 0 then
            line.center = nil
        else
            line.center = table.remove(ln > rn and line.left or line.right, 1)
        end
    end

    function anim:_updateLR(line, now, duration, critDuration)
        self:_updateOne(line, now, duration, critDuration)
        if line.center then return end
        local un, dn = #self._up, #self._down
        if un == 0 and dn == 0 then return end
        self._middle = table.remove(un > dn and self._up or self._down)
    end

    function anim:_updateUD(lines, now, duration, critDuration)
        for i = #lines, 1, -1 do
            local line = lines[i]
            self:_updateOne(line, now, duration, critDuration)
            if not line.center then
                table.remove(lines, i)
            end
        end
    end

    function anim:_layout(line, y)
        local x, half = 0, 0
        local fontString, record = line.center
        if not fontString then return end
        
        record = fontString.ClassicNFCT
        record.x, record.y = x, y
        this:DoLayout(fontString, record)
        half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
        local xl, xr = half, -half
        for _, fontString in ipairs(line.left) do
            record = fontString.ClassicNFCT
            half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
            xl = xl + half
            record.x, record.y = xl, y
            this:DoLayout(fontString, record)
            xl = xl + half
        end
        for _, fontString in ipairs(line.right) do
            record = fontString.ClassicNFCT
            half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
            xr = xr - half
            record.x, record.y = xr, y
            this:DoLayout(fontString, record)
            xr = xr - half
        end
    end

    function anim:update(now, duration, critDuration)
        self:_updateUD(self._up, now, duration, critDuration)
        self:_updateUD(self._down, now, duration, critDuration)
        self:_updateLR(self._middle, now, duration, critDuration)
        self:_layout(self._middle, 0)
        for i = #self._up, 1, -1 do
            self:_layout(self._up[i], LINE_HEIGHT * (#self._up - i + 1))
        end
        for i = #self._down, 1, -1 do
            self:_layout(self._down[i], LINE_HEIGHT * -(#self._down - i + 1))
        end
    end

    function anim:_clear(line)
        if line.center then
            this:RecycleFontString(line.center)
        end
        for _, fontString in ipairs(line.left) do
            this:RecycleFontString(fontString)
        end
        for _, fontString in ipairs(line.right) do
            this:RecycleFontString(fontString)
        end
    end

    function anim:clear()
        self:_clear(self._middle)
        for _, line in ipairs(self._up) do
            self:_clear(line)
        end
        for _, line in ipairs(self._down) do
            self:_clear(line)
        end
        self._middle, self._up, self._down =
            {left = {}, right = {}}, {}, {}
    end

    return anim
end

function ClassicNFCT:CritScale(elapsed, duration, start, middle, finish)
    if elapsed < duration then
        local sep = duration * 0.667
        if elapsed < sep then
            return LibEasing.OutQuad(elapsed, start, middle - start, sep)
        else
            return LibEasing.InQuad(elapsed - sep, middle, finish - middle, duration - sep)
        end
    end
    return finish
end

function ClassicNFCT:DoAnimate(fontString, record, elapsed, duration, critDuration)
    -- record.animatingDuration = self.db.global.animations.animationspeed
    -- record.animatingCritDuration = duration * 0.2
    local isTarget = UnitIsUnit(record.unit, "target")
    -- alpha
    local startAlpha = self.db.global.formatting.alpha
    if (self.db.global.useOffTarget and not isTarget) then
        startAlpha = self.db.global.offTargetFormatting.alpha
    end

    local alpha = startAlpha
    local alphaSep = duration * ANIMATION_ALPHA_SEP
    if elapsed > alphaSep then
        alpha = LibEasing.InExpo(elapsed - alphaSep, startAlpha, -startAlpha, duration - alphaSep)
    end
    fontString:SetAlpha(alpha)

    -- scale
    local targetScale = isTarget
        and self.db.global.formatting.scale
        or self.db.global.offTargetFormatting.scale
    record.critScale = 1
    if record.crit then
        if elapsed <= critDuration then
            record.critScale = self:CritScale(
                elapsed, critDuration,
                ANIMATION_CRIT_MIN_SCALE, ANIMATION_CRIT_MAX_SCALE, ANIMATION_CRIT_SCALE
            )
        else
            record.critScale = ANIMATION_CRIT_SCALE
        end
    end
    record.finalScale, record.targetScale, record.offsetY =
        record.scale * record.critScale,
        targetScale,
        LibEasing.OutSine(elapsed, 0, ANIMATION_VERTICAL_DISTANCE, duration)
end

function ClassicNFCT:DoLayout(fontString, record)
    fontString:ClearAllPoints()
    fontString:SetParent(record.anchorFrame)
    fontString:SetScale(record.finalScale * record.targetScale)

    fontString:SetPoint(
        "CENTER", record.anchorFrame, "CENTER",
        record.x / record.finalScale,
        (self.db.global.distance / record.targetScale + record.y + record.offsetY) / record.finalScale
    )
end

function ClassicNFCT:AnimateUpdate()
    SetCVar("floatingCombatTextCombatDamage", self.db.global.blzDisabled and  "0" or "1")

    local rems = {}
    for unit, guid in pairs(self.unitToGuid) do
        if UnitIsDead(unit) then
            table.insert(rems, unit)
        else
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if not nameplate or not nameplate:IsShown() then
                table.insert(rems, unit)
            end
        end
    end
    for _, unit in pairs(rems) do self:NAME_PLATE_UNIT_REMOVED(nil, unit) end
    
    if not next(self.guidToAnim) then
        -- nothing in the animation list, so just kill the onupdate
        self.frame:SetScript("OnUpdate", nil)
        return
    end

    -- start onupdate if it's not already running
    if (self.frame:GetScript("OnUpdate") == nil) then
        self.frame:SetScript("OnUpdate", self.animUpdateFunc)
    end

    local now, duration = GetTime(), 1 / self.db.global.animations.animationspeed
    local critDuration = duration * self.db.global.animations.critpercent

    for _, anim in pairs(self.guidToAnim) do
        anim:update(now, duration, critDuration)
    end
end
