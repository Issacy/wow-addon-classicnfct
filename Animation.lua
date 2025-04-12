local _

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

local LibEasing = LibStub("LibEasing-1.0")

local sortIndex
local screenHeight
local animCache, lineCache, refCache, recordCache
local wildAnim, wildFrame
local guidToAnim, animUpdateFunc
local wilds, refs, frame
local now = 0

local function RecordSorter(a, b) return a.sortIndex:compare(b.sortIndex) < 0 end

function ClassicNFCT:CreateAnimation()
    sortIndex = self:CreateBigInt()
    animCache = self:CreatePool(function() return self:CreateAnimationGroup() end)
    refCache = self:CreatePool(function() return { map = {}, sorted = {} } end)
    recordCache = self:CreatePool(function() return { fontVersion = self:CreateBigInt(), sortIndex = self:CreateBigInt() } end)
    guidToAnim = self:CreateMap()
    wilds = refCache:get()
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
        anim:clear()
        animCache:release(anim)
    end
    guidToAnim:clear()
    for _, ref in refs:iter() do
        for _, record in ipairs(ref.sorted) do self:RecycleRecord(record) end
        wipe(ref.map)
        wipe(ref.sorted)
        refCache:release(ref)
    end
    refs:clear()
    self:ClearWilds()
end

function ClassicNFCT:CreateAnimationGroup()
    local this = self

    if not lineCache then lineCache = this:CreatePool(function() return {left = {}, right = {}} end) end

    local anim = {}
    local inner = {
        middle = lineCache:get(),
        up = {}, down = {},
        count = 0,
    }

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
        local critDuration = duration * ANIMATION_CRIT_SCALE_PERCENT
        local start, middle, finish = ANIMATION_CRIT_MIN_SCALE, ANIMATION_CRIT_MAX_SCALE, ANIMATION_CRIT_SCALE
        if elapsed < critDuration then
            local sep = critDuration * ANIMATION_CRIT_SCALE_UP_PERCENT
            if elapsed < sep then
                return LibEasing.OutCubic(elapsed, start, middle - start, sep)
            else
                return LibEasing.InCubic(elapsed - sep, middle, finish - middle, critDuration - sep)
            end
        end
        return finish
    end

    function inner:animate(record, targetGUID, onScreen)
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

        if record.crits > 0 and record.critElapsed <= record.duration then
            record.alpha = startAlpha
        else
            record.alpha = self:animAlpha(record.elapsed, record.duration, startAlpha)
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
        if record.crits > 0 then
            critScale = self:animCrit(record.critElapsed, record.duration)
            record.critScale = ANIMATION_CRIT_SCALE
        end

        record.finalScale = record.scale * critScale

        record.offsetY = 0
        if record.crits == 0 or record.critElapsed > record.duration then
            local moveUp = this.db.global.layout.lineHeight
            record.offsetY = LibEasing.Linear(record.elapsed, moveUp * ANIMATION_VERTICAL_OFFSET_PERCENT, moveUp, record.duration)
        end
    end

    function inner:updateLR(lr, targetGUID, onScreen)
        for i = #lr, 1, -1 do
            local record = lr[i]
            self:animate(record, targetGUID, onScreen)
        end
    end

    function inner:updateLine(line, targetGUID, onScreen)
        self:updateLR(line.left, targetGUID, onScreen)
        self:updateLR(line.right, targetGUID, onScreen)

        local record = line.center
        if not record then return end
        self:animate(record, targetGUID, onScreen)
    end

    function inner:updateUD(lines, targetGUID, onScreen)
        for i = #lines, 1, -1 do
            local line = lines[i]
            self:updateLine(line, targetGUID, onScreen)
        end
    end

    function inner:layoutOne(record, nameplate, onScreen)
        local fontString = record.fontString

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
        fontString:Show()

        local offsetX, offsetY = record.x, (this.db.global.layout.distance / record.targetScale + record.y + record.offsetY)

        if onScreen then
            offsetX = offsetX + this.db.global.layout.onScreenPos.centerOffsetX
            offsetY = offsetY + this.db.global.layout.onScreenPos.centerOffsetY
        end

        fontString:SetPoint("BOTTOM", nameplate, "CENTER", offsetX / record.finalScale, offsetY / record.finalScale)
    end

    function inner:layoutLine(line, y, nameplate, onScreen)
        local record = line.center
        if not record then return end

        record.x, record.y = 0, y
        self:layoutOne(record, nameplate, onScreen)
        local half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
        local xl, xr = -half, half
        -- for insert optimize, reverse layout
        local ln, rn = #line.left, #line.right
        for i = ln, 1, -1 do
            record = line.left[i]
            half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
            xl = xl - half
            record.x, record.y = xl, y
            self:layoutOne(record, nameplate, onScreen)
            xl = xl - half
        end
        for i = rn, 1, -1 do
            record = line.right[i]
            half = record.width * record.critScale * 0.5 + ANIMATION_HORIZONTAL_PADDING
            xr = xr + half
            record.x, record.y = xr, y
            self:layoutOne(record, nameplate, onScreen)
            xr = xr + half
        end
    end

    function inner:clearLine(line)
        line.center = nil
        wipe(line.left)
        wipe(line.right)
    end

    function anim:update(nameplate, targetGUID, onScreen)
        inner:updateUD(inner.up, targetGUID, onScreen)
        inner:updateUD(inner.down, targetGUID, onScreen)
        inner:updateLine(inner.middle, targetGUID, onScreen)

        inner:layoutLine(inner.middle, 0, nameplate, onScreen)
        local lineHeight = this.db.global.layout.lineHeight + ANIMATION_VERTICAL_PADDING
        for i = #inner.up, 1, -1 do
            inner:layoutLine(inner.up[i], lineHeight * i, nameplate, onScreen)
        end
        for i = #inner.down, 1, -1 do
            inner:layoutLine(inner.down[i], -lineHeight * i, nameplate, onScreen)
        end
    end

    function anim:add(record)
        if not this:GenerateText(record) then return end
        
        inner.count = inner.count + 1
        record.width = record.textWidth * record.scale

        local move = inner.middle.center
        inner.middle.center = record
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

    function anim:clear()
        inner:clearLine(inner.middle)
        for i, line in ipairs(inner.up) do
            inner:clearLine(line)
            lineCache:release(line)
            inner.up[i] = nil
        end
        for i, line in ipairs(inner.down) do
            inner:clearLine(line)
            lineCache:release(line)
            inner.down[i] = nil
        end
        inner.count = 0
    end

    function anim:count() return inner.count end

    return anim
end

function ClassicNFCT:GetRecord()
    local record = recordCache:get()
    sortIndex:increment()
    record.sortIndex:copy(sortIndex)
    return record
end

function ClassicNFCT:RecycleRecord(record)
    record.key = nil
    record.text = nil
    self:RecycleFontString(record)
    recordCache:release(record)
end

function ClassicNFCT:UpdateRecord(record, amount, missType, school, crit)
    record.school = school
    record.eventTime = now
    record.hits = record.hits + 1
    record.amount = record.amount + amount
    if record.missType then
        if missType then
            record.missType = missType
        else
            record.missType = nil
        end
    end
    record.school = school
    if crit then
        record.crits = record.crits + 1
        record.critTime = now
    end
    record.text = nil
end

function ClassicNFCT:InitRecord(record, guid, spellID, amount, missType, school, crit, isPet, isMelee)
    record.guid = guid
    record.spellID = spellID
    record.school = school
    record.eventTime = now
    record.hits = 1
    record.amount = amount
    record.missType = missType
    record.critTime = now
    record.crits = crit and 1 or 0
    record.pet = isPet
    record.melee = isMelee
    record.scale = (isPet and self.db.global.style.pet.scale)
        or (isMelee and self.db.global.style.autoAttack.scale)
        or 1
    record.duration = self.db.global.animations.animationDuration
end

function ClassicNFCT:MergeRecord(recordA, recordB)
    local later = recordA.eventTime < recordB.eventTime
    if later then
        recordA.school = recordB.school
        recordA.eventTime = recordB.eventTime
        recordA.elapsed = now - recordA.eventTime
        recordA.crit = recordB.crit
        recordA.critTime = recordB.critTime
        recordA.critElapsed = now - recordA.critTime
        if recordA.missType and recordB.missType then
            recordA.missType = recordB.missType
        end
    end
    recordA.hits = recordA.hits + recordB.hits
    recordA.amount = recordA.amount + recordB.amount
    recordA.crits = recordA.crits + recordB.crits
    recordA.text = nil

    self:RecycleFontString(recordB)
    recordB.fontString = nil
end

function ClassicNFCT:CopyRecord(recordA, recordB)
    recordA.sortIndex:copy(recordB.sortIndex)
    recordA.guid = recordB.guid
    recordA.spellID = recordB.spellID
    recordA.school = recordB.school
    recordA.eventTime = recordB.eventTime
    recordA.elapsed = now - recordA.eventTime
    recordA.hits = recordB.hits
    recordA.amount = recordB.amount
    recordA.missType = recordB.missType
    recordA.critTime = recordB.critTime
    recordA.critElapsed = now - recordA.critTime
    recordA.crits = recordB.crits
    recordA.pet = recordB.pet
    recordA.melee = recordB.melee
    recordA.scale = recordB.scale
    recordA.duration = recordB.duration
    recordA.text = recordB.text

    self:RecycleFontString(recordB)
    recordB.fontString = nil
end

function ClassicNFCT:DamageText(guid, spellID, amount, missType, school, crit, isPet, isMelee)
    now = GetTime()

    local ref = refs:at(guid)
    if not ref then
        ref = refCache:get()
        refs:emplace(guid, ref)
    end
    ref.dirty = true

    local record
    if self.db.global.filter.sumSameSpell then
        local key = spellID or 0
        if isPet then key = 'P@' .. key end
        record = ref.map[key]
        if not record then
            record = self:GetRecord()
            record.key = key
            ref.map[key] = record
            self:InitRecord(record, guid, spellID, amount, missType, school, crit, isPet, isMelee)
            table.insert(ref.sorted, record)
        else
            self:UpdateRecord(record, amount, missType, school, crit)
        end
    else
        record = self:GetRecord()
        self:InitRecord(record, guid, spellID, amount, missType, school, crit, isPet, isMelee)
        table.insert(ref.sorted, record)
    end

    local func = frame:GetScript("OnUpdate")
    -- start OnUpdate if it's not already running
    if not func then
        frame:SetScript("OnUpdate", animUpdateFunc)
    end
end

function ClassicNFCT:GenerateText(record)
    local dirty = false
    if not record.text then
        local text = record.missType and self.L.MISS_EVENT_STRINGS[record.missType] or self:FormatNumber(record.amount)
        if record.hits > 1 then text = text .. ' (' .. record.hits .. ')' end
        text = self:TextWithColor(text, record.school, record.pet, record.melee)

        local icon = self.db.global.style.iconStyle
        if icon ~= "none" then
            local iconText = "|T"..C_Spell.GetSpellTexture(record.spellID)..":0|t"
            if (icon == "both") then
                text = iconText..text..iconText
            elseif (icon == "left") then
                text = iconText..text
            else -- if (icon == "right") then
                text = text..iconText
            end
        end
        record.text = text
        dirty = true
    end

    if not record.fontString then
        self:GetFontString(record)
        if not record.fontString then return false end
        dirty = true
    end

    if dirty then
        local fontString = record.fontString
        fontString:SetText(record.text)
        record.textWidth = fontString:GetUnboundedStringWidth()
    end
    return true
end

function ClassicNFCT:ClearWilds()
    for _, record in ipairs(wilds.sorted) do
        self:RecycleRecord(record)
    end
    wipe(wilds.map)
    wipe(wilds.sorted)
    wilds.dirty = false
    wildAnim:clear()
end

function ClassicNFCT:UpdateWilds()
    if not wilds.dirty then return end
    table.sort(wilds.sorted, RecordSorter)
    for _, record in ipairs(wilds.sorted) do wildAnim:add(record) end
    wildAnim:update(wildFrame, nil, true)
    wilds.dirty = false
end

function ClassicNFCT:AddWild(record)
    if self.db.global.filter.sumSameSpell then
        local key = record.key
        if not key then
            key = record.spellID or 0
            if record.pet then key = 'P@' .. key end
        end
        local wildRecord = wilds.map[key]
        if not wildRecord then
            wildRecord = self:GetRecord()
            wildRecord.key = key
            wilds.map[key] = wildRecord
            self:CopyRecord(wildRecord, record)
            table.insert(wilds.sorted, wildRecord)
        else
            self:MergeRecord(wildRecord, record)
        end
    else
        local wildRecord = self:GetRecord()
        self:CopyRecord(wildRecord, record)
        table.insert(wilds.sorted, wildRecord)
    end
    wilds.dirty = true
end

function ClassicNFCT:AnimateUpdate_OnScreenOnly()
    self:ClearWilds()

    for guid, anim in guidToAnim:iter() do
        animCache:release(guidToAnim:remove(guid, false))
    end
    guidToAnim:trim()

    for guid, ref in refs:iter() do
        for i = #ref.sorted, 1, -1 do
            local record = ref.sorted[i]
            record.elapsed = now - record.eventTime
            record.critElapsed = now - record.critTime
            if record.elapsed > self.db.global.animations.animationDuration then
                table.remove(ref.sorted, i)
                if record.key then ref.map[record.key] = nil end
                self:RecycleRecord(record)
            else
                self:AddWild(record)
            end
        end
        if #ref.sorted == 0 then
            refCache:release(refs:remove(guid, false))
        end
    end
    refs:trim()

    self:UpdateWilds()
end

function ClassicNFCT:AnimateUpdate_NameplateBased()
    self:ClearWilds()

    for guid, anim in guidToAnim:iter() do
        anim:clear()
        local _, nameplate = self:GetNamePlateForGUID(guid)
        if not nameplate then
            animCache:release(guidToAnim:remove(guid, false))
        end
    end
    guidToAnim:trim()

    for guid, ref in refs:iter() do
        for i = #ref.sorted, 1, -1 do
            local record = ref.sorted[i]
            record.elapsed = now - record.eventTime
            record.critElapsed = now - record.critTime
            if record.elapsed > self.db.global.animations.animationDuration then
                table.remove(ref.sorted, i)
                if record.key then ref.map[record.key] = nil end
                self:RecycleRecord(record)
            end
        end
        if #ref.sorted == 0 then
            refCache:release(refs:remove(guid, false))
        elseif ref.dirty then
            table.sort(ref.sorted, RecordSorter)
            ref.dirty = false
        end
    end
    refs:trim()

    local targetGUID = UnitGUID('target')

    for guid, ref in refs:iter() do
        local anim
        local _, nameplate = self:GetNamePlateForGUID(guid)
        if nameplate then
            anim = guidToAnim:at(guid)
            if not anim then
                anim = self:CreateAnimationGroup()
                guidToAnim:emplace(guid, anim)
            end
        end

        if not anim then
            for _, record in ipairs(ref.sorted) do self:AddWild(record) end
        else
            for _, record in ipairs(ref.sorted) do anim:add(record) end
            anim:update(nameplate, targetGUID, false)
        end
    end

    self:UpdateWilds()
end

function ClassicNFCT:AnimateUpdate()
    now = GetTime()

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

    if guidToAnim:count() == 0 and wildAnim:count() == 0 then
        frame:SetScript("OnUpdate", nil)
    end
end
