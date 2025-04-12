local _

function ClassicNFCT:CreateCmd()
    local L = self.L

    local cmds
    cmds = {
        {
            cmd = '',
            desc = L.CMD['Open option'],
            func = function() self:OpenMenu() end,
        },
        {
            cmd = 'on',
            desc = L.CMD['Enable addon'],
            func = function() self:SetEnableToDB(true) end,
        },
        {
            cmd = 'off',
            desc = L.CMD['Disable addon'],
            func = function() self:SetEnableToDB(false) end,
        },
        {
            cmd = 'onscreen',
            desc = L.CMD['Show text on screen'],
            func = function() self.db.global.layout.alwaysOnScreen = true end,
        },
        {
            cmd = 'nameplate',
            desc = L.CMD['Show text on nameplate'],
            func = function() self.db.global.layout.alwaysOnScreen = false end,
        },
        {
            cmd = 'help',
            func = function()
                local l = {}
                for _, v in ipairs(cmds) do
                    if v.desc then table.insert(l, v.order, '/cnfct ' .. v.cmd .. ': ' .. v.desc) end
                end
                for _, v in ipairs(l) do print(v) end
            end,
        },
    }

    self.cmds = {}
    for _, v in ipairs(cmds) do self.cmds[v.cmd] = v.func end

    print(L.CMD["Classic Nameplate Floating Combat Text Command Help: /cnfct help"])

    -- setup chat commands
    self:RegisterChatCommand("cnfct", "OnCommand")
end

function ClassicNFCT:OnCommand(subCmd)
    local func = self.cmds[subCmd:lower()]
    if func then func() end
end
