function ClassicNFCT:CreateMenu()
    local L = self.L

    local menu = {
        name = "ClassicNFCT",
        handler = self,
        type = 'group',
    }

    menu.args = {
        enable = {
            type = 'toggle',
            name = L.UI["Enable"],
            desc = L.UI["If the addon is enabled"],
            get = "IsEnabled",
            set = function(_, newValue) if (not newValue) then self:Disable() else self:Enable() end end,
            order = 1,
            width = "half",
        },
    }

    menu.args.total = {
        type = 'group',
        name = '',
        order = 2,
        inline = true,
        width = 'full',
        disabled = function() return not self.db.global.enabled end,
    }

    menu.args.total.args = {
        disableBlizzardFCT = {
            type = 'toggle',
            name = L.UI["Disable Blizzard FCT"],
            desc = "",
            get = function() return self.db.global.blzDisabled end,
            set = function(_, newValue)
                self.db.global.blzDisabled = newValue
                SetCVar("floatingCombatTextCombatDamage", self.db.global.blzDisabled and  "0" or "1")
            end,
            order = 10,
            width = "full",
        },

        animations = {
            type = 'group',
            name = L.UI["Animations"],
            order = 30,
            inline = true,
            args = {
                speed = {
                    type = 'range',
                    name = L.UI["Animation Speed"],
                    desc = L.UI["Default speed: 1"],
                    min = 0.5,
                    max = 3,
                    step = .01,
                    get = function() return self.db.global.animations.animationspeed end,
                    set = function(_, newValue) self.db.global.animations.animationspeed = newValue end,
                    order = 1,
                    width = "full",
                },
                critpercent = {
                    type = 'range',
                    name = L.UI["Crit Animation Duration Ratio"],
                    desc = L.UI["The ratio of crit animation duration to the entire animation duration when make crit damage\nDefault: 0.2"],
                    min = 0.1,
                    max = 1,
                    step = .01,
                    get = function() return self.db.global.animations.critpercent end,
                    set = function(_, newValue) self.db.global.animations.critpercent = newValue end,
                    order = 4,
                    width = "full",
                },
                -- lines = {
                --     type = 'range',
                --     name = L.UI["Animation Max Lines"],
                --     desc = "",
                --     min = 3,
                --     max = 11,
                --     step = 2,
                --     get = function() return self.db.global.animations.animMaxLines end,
                --     set = function(_, newValue) self.db.global.animations.animMaxLines = newValue end,
                --     order = 2,
                --     width = "full",
                -- },
                -- animationCount = {
                --     type = 'range',
                --     name = L.UI["Animation Count"],
                --     desc = "",
                --     min = 1,
                --     max = 100,
                --     step = 1,
                --     get = function() return self.db.global.animations.animationCount end,
                --     set = function(_, newValue) self.db.global.animations.animationCount = newValue end,
                --     order = 3,
                --     width = "full",
                -- },
            },
        },

        appearance = {
            type = 'group',
            name = L.UI["Appearance"],
            order = 50,
            inline = true,
            args = {
                font = {
                    type = "select",
                    dialogControl = "LSM30_Font",
                    name = L.UI["Font"],
                    order = 1,
                    values = AceGUIWidgetLSMlists.font,
                    get = function() return self.db.global.font end,
                    set = function(_, newValue) self.db.global.font = newValue end,
                },
                fontFlag = {
                    type = 'select',
                    name = L.UI["Font Flags"],
                    desc = "",
                    get = function() return self.db.global.fontFlag end,
                    set = function(_, newValue) self.db.global.fontFlag = newValue end,
                    values = L.fontFlags,
                    order = 2,
                    width = "double",
                },
                fontShadow = {
                    type = 'toggle',
                    name = L.UI["Text Shadow"],
                    get = function() return self.db.global.textShadow end,
                    set = function(_, newValue) self.db.global.textShadow = newValue end,
                    order = 3,
                },
                damageColor = {
                    type = 'toggle',
                    name = L.UI["Use Damage Type Color"],
                    desc = "",
                    get = function() return self.db.global.damageColor end,
                    set = function(_, newValue) self.db.global.damageColor = newValue end,
                    order = 4,
                },
            },
        },

        distance = {
            type = 'group',
            name = L.UI["Vertical Distance"],
            order = 70,
            inline = true,
            args = {
                scale = {
                    type = 'range',
                    name = "",
                    desc = L.UI["Vertical Distance of Text Starting from NamePlate"],
                    min = -100,
                    max = 100,
                    step = .01,
                    get = function() return self.db.global.distance end,
                    set = function(_, newValue) self.db.global.distance = newValue end,
                    order = 1,
                    width = "full",
                },
            }
        },

        formatting = {
            type = 'group',
            name = L.UI["Text Formatting"],
            order = 90,
            inline = true,
            args = {
                fmtStyle = {
                    type = "select",
                    name = L.UI["Format Style"],
                    values = L.fmtStyles,
                    get = function() return self.db.global.fmtStyle end,
                    set = function(_, newValue) self.db.global.fmtStyle = newValue end,
                    order = 1,
                    width = "double",
                },
                target = {
                    type = 'group',
                    name = L.UI["Target Text Appearance"],
                    order = 2,
                    inline = true,
                    args = {
                        icon = {
                            type = 'select',
                            name = L.UI["Icon"],
                            desc = "",
                            get = function() return self.db.global.formatting.icon end,
                            set = function(_, newValue) self.db.global.formatting.icon = newValue end,
                            values = L.iconValues,
                            order = 51,
                        },
                        scale = {
                            type = 'range',
                            name = L.UI["Scale"],
                            desc = "",
                            min = .01,
                            max = 5,
                            step = .01,
                            get = function() return self.db.global.formatting.scale end,
                            set = function(_, newValue) self.db.global.formatting.scale = newValue end,
                            order = 52,
                        },
                        alpha = {
                            type = 'range',
                            name = L.UI["Alpha"],
                            desc = "",
                            min = .01,
                            max = 1,
                            step = .01,
                            get = function() return self.db.global.formatting.alpha end,
                            set = function(_, newValue) self.db.global.formatting.alpha = newValue end,
                            order = 53,
                        },
                    },
                },
                petScale = {
                    type = 'range',
                    name = L.UI["Pet Text Scale (Based on Target)"],
                    desc = "",
                    min = .01,
                    max = 5,
                    step = .01,
                    get = function() return self.db.global.petFormatting.scale end,
                    set = function(_, newValue) self.db.global.petFormatting.scale = newValue end,
                    order = 4,
                    width = "full",
                },

                autoAttackScale = {
                    type = 'range',
                    name = L.UI["Auto-Attack Text Scale (Based on Target)"],
                    desc = "",
                    min = .01,
                    max = 5,
                    step = .01,
                    get = function() return self.db.global.autoAttackFormatting.scale end,
                    set = function(_, newValue) self.db.global.autoAttackFormatting.scale = newValue end,
                    order = 5,
                    width = "full",
                },

                useOffTarget = {
                    type = 'toggle',
                    name = L.UI["Use Seperate Off-Target Text Appearance"],
                    desc = "",
                    get = function() return self.db.global.useOffTarget end,
                    set = function(_, newValue) self.db.global.useOffTarget = newValue end,
                    order = 100,
                    width = "full",
                },
                offTarget = {
                    type = 'group',
                    name = L.UI["Off-Target Text Appearance"],
                    hidden = function() return not self.db.global.useOffTarget end,
                    order = 101,
                    inline = true,
                    args = {
                        scale = {
                            type = 'range',
                            name = L.UI["Scale"],
                            desc = "",
                            min = .01,
                            max = 5,
                            step = .01,
                            get = function() return self.db.global.offTargetFormatting.scale end,
                            set = function(_, newValue) self.db.global.offTargetFormatting.scale = newValue end,
                            order = 2,
                            width = "full",
                        },
                        alpha = {
                            type = 'range',
                            name = L.UI["Alpha"],
                            desc = "",
                            min = 0,
                            max = 1,
                            step = .01,
                            get = function() return self.db.global.offTargetFormatting.alpha end,
                            set = function(_, newValue) self.db.global.offTargetFormatting.alpha = newValue end,
                            order = 3,
                            width = "full",
                        },
                    },
                },
            },
        },
    }

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ClassicNFCT", menu)
    self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ClassicNFCT", "ClassicNFCT")
end

function ClassicNFCT:OpenMenu()
    -- just open to the frame, double call because blizz bug
    InterfaceOptionsFrame_OpenToCategory(self.menu)
    InterfaceOptionsFrame_OpenToCategory(self.menu)
end
