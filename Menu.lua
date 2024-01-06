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
        disableBlizzardFCT = {
            type = 'toggle',
            name = L.UI["Disable Blizzard FCT"],
            desc = "",
            get = function() return self.db.global.blzDisabled end,
            set = function(_, newValue)
                self.db.global.blzDisabled = newValue
                self:ChangeBlizzardFCT()
            end,
            order = 2,
            width = "half",
        },
    }

    menu.args.total = {
        type = 'group',
        name = '',
        order = 3,
        inline = true,
        width = 'full',
        disabled = function() return not self.db.global.enabled end,
    }

    menu.args.total.args = {}

    menu.args.total.args.animation = {
        type = 'group',
        name = L.UI["Animations"],
        order = 4,
        inline = true,
        args = {
            speed = {
                type = 'range',
                name = L.UI["Animation Duration"],
                desc = "",
                min = 0.5,
                max = 3,
                step = .01,
                get = function() return self.db.global.animations.animationDuration end,
                set = function(_, newValue) self.db.global.animations.animationDuration = newValue end,
                order = 1,
                width = "full",
            },
        },
    }

    menu.args.total.args.font = {
        type = 'group',
        name = L.UI["Font"],
        order = 5,
        inline = true,
        args = {
            font = {
                type = "select",
                dialogControl = "LSM30_Font",
                name = L.UI["Font"],
                order = 1,
                values = AceGUIWidgetLSMlists.font,
                get = function() return self.db.global.font.choice end,
                set = function(_, newValue) self.db.global.font.choice = newValue end,
            },
            flag = {
                type = 'select',
                name = L.UI["Style"],
                desc = "",
                get = function() return self.db.global.font.flag end,
                set = function(_, newValue) self.db.global.font.flag = newValue end,
                values = L.fontStyles,
                order = 2,
            },
            size = {
                type = 'range',
                name = L.UI["Size"],
                desc = "",
                min = 1,
                max = 144,
                step = 1,
                get = function() return self.db.global.font.size end,
                set = function(_, newValue) self.db.global.font.size = newValue end,
                order = 3,
            },
            shadow = {
                type = 'toggle',
                name = L.UI["Shadow"],
                get = function() return self.db.global.font.shadow end,
                set = function(_, newValue) self.db.global.font.hadow = newValue end,
                order = 4,
            },
        },
    }

    menu.args.total.args.layout = {
        type = 'group',
        name = L.UI["Layout"],
        order = 6,
        inline = true,
        args = {
            distance = {
                type = 'range',
                name = L.UI["Vertical Distance"],
                desc = L.UI["Vertical Distance of Text Starting from NamePlate"],
                min = -100,
                max = 100,
                step = .01,
                get = function() return self.db.global.layout.distance end,
                set = function(_, newValue) self.db.global.layout.distance = newValue end,
                order = 1,
            },
            lineHeight = {
                type = 'range',
                name = L.UI["Line Height"],
                desc = "",
                min = 0,
                max = 200,
                step = .01,
                get = function() return self.db.global.layout.lineHeight end,
                set = function(_, newValue) self.db.global.layout.lineHeight = newValue end,
                order = 2,
            },
            onScreenPos = {
                type = 'group',
                name = L.UI["On-Screen Text Position"],
                order = 3,
                inline = true,
                args = {
                    x = {
                        type = 'input',
                        name = L.UI["Center Offset X"],
                        desc = '',
                        get = function() return tostring(self.db.global.layout.onScreenPos.centerOffsetX) end,
                        set = function(_, newValue)
                            newValue = tonumber(newValue)
                            if newValue == nil then return end
                            self.db.global.layout.onScreenPos.centerOffsetX = newValue
                        end,
                        order = 1,
                    },
                    y = {
                        type = 'input',
                        name = L.UI["Center Offset Y"],
                        desc = '',
                        get = function() return tostring(self.db.global.layout.onScreenPos.centerOffsetY) end,
                        set = function(_, newValue)
                            newValue = tonumber(newValue)
                            if newValue == nil then return end
                            self.db.global.layout.onScreenPos.centerOffsetY = newValue
                        end,
                        order = 1,
                    },
                }
            }
        }
    }

    menu.args.total.args.style = {
        type = 'group',
        name = L.UI["Text Style"],
        order = 7,
        inline = true,
        args = {
            numStyle = {
                type = "select",
                name = L.UI["Number Style"],
                values = L.numStyles,
                get = function() return self.db.global.style.numStyle end,
                set = function(_, newValue) self.db.global.style.numStyle = newValue end,
                order = 1,
            },
            iconStyle = {
                type = 'select',
                name = L.UI["Icon Style"],
                desc = "",
                get = function() return self.db.global.style.iconStyle end,
                set = function(_, newValue) self.db.global.style.iconStyle = newValue end,
                values = L.iconStyles,
                order = 2,
            },
            dmgTypeColor = {
                type = 'toggle',
                name = L.UI["Color by Damage Type"],
                desc = "",
                get = function() return self.db.global.style.dmgTypeColor end,
                set = function(_, newValue) self.db.global.style.dmgTypeColor = newValue end,
                order = 3,
            },
            spellBlacklist = {
                type = 'input',
                name = L.UI["Spell Blacklist"],
                desc = L.UI["Spell ID or Name Seperated by Vertical bar (|)\nSpecial tags: spell|melee|pet|pet_spell|pet_melee"],
                multiline = 3,
                get = function() return self.spellBlacklistForMenu end,
                set = function(_, newValue) self:UpdateSpellBlacklistForDB(newValue) end,
                order = 4,
                width = 'full',
            },
            scale = {
                type = 'range',
                name = L.UI["Scale"],
                desc = "",
                min = .01,
                max = 5,
                step = .01,
                get = function() return self.db.global.style.scale end,
                set = function(_, newValue) self.db.global.style.scale = newValue end,
                order = 5,
            },
            alpha = {
                type = 'range',
                name = L.UI["Alpha"],
                desc = "",
                min = .01,
                max = 1,
                step = .01,
                get = function() return self.db.global.style.alpha end,
                set = function(_, newValue) self.db.global.style.alpha = newValue end,
                order = 6,
            },
            petScale = {
                type = 'range',
                name = L.UI["Pet Text Scale (Based on Target)"],
                desc = "",
                min = .01,
                max = 5,
                step = .01,
                get = function() return self.db.global.style.pet.scale end,
                set = function(_, newValue) self.db.global.style.pet.scale = newValue end,
                order = 7,
                width = "full",
            },

            autoAttackScale = {
                type = 'range',
                name = L.UI["Auto-Attack Text Scale (Based on Target)"],
                desc = "",
                min = .01,
                max = 5,
                step = .01,
                get = function() return self.db.global.style.autoAttack.scale end,
                set = function(_, newValue) self.db.global.style.autoAttack.scale = newValue end,
                order = 7,
                width = "full",
            },

            useOffTarget = {
                type = 'toggle',
                name = L.UI["Use Seperate Off-Target Text Style"],
                desc = "",
                get = function() return self.db.global.style.useOffTarget end,
                set = function(_, newValue) self.db.global.style.useOffTarget = newValue end,
                order = 8,
                width = "full",
            },
            offTarget = {
                type = 'group',
                name = L.UI["Off-Target Text Style"],
                hidden = function() return not self.db.global.style.useOffTarget end,
                order = 9,
                inline = true,
                args = {
                    scale = {
                        type = 'range',
                        name = L.UI["Scale"],
                        desc = "",
                        min = .01,
                        max = 5,
                        step = .01,
                        get = function() return self.db.global.style.offTarget.scale end,
                        set = function(_, newValue) self.db.global.style.offTarget.scale = newValue end,
                        order = 2,
                    },
                    alpha = {
                        type = 'range',
                        name = L.UI["Alpha"],
                        desc = "",
                        min = 0,
                        max = 1,
                        step = .01,
                        get = function() return self.db.global.style.offTarget.alpha end,
                        set = function(_, newValue) self.db.global.style.offTarget.alpha = newValue end,
                        order = 3,
                    },
                },
            },
            useOnScreen = {
                type = 'toggle',
                name = L.UI["Use Seperate On-Screen Text Style"],
                desc = "",
                get = function() return self.db.global.style.useOnScreen end,
                set = function(_, newValue) self.db.global.style.useOnScreen = newValue end,
                order = 10,
                width = "full",
            },
            onScreen = {
                type = 'group',
                name = L.UI["On-Screen Text Style"],
                hidden = function() return not self.db.global.style.useOnScreen end,
                order = 11,
                inline = true,
                args = {
                    scale = {
                        type = 'range',
                        name = L.UI["Scale"],
                        desc = "",
                        min = .01,
                        max = 5,
                        step = .01,
                        get = function() return self.db.global.style.onScreen.scale end,
                        set = function(_, newValue) self.db.global.style.onScreen.scale = newValue end,
                        order = 2,
                    },
                    alpha = {
                        type = 'range',
                        name = L.UI["Alpha"],
                        desc = "",
                        min = 0,
                        max = 1,
                        step = .01,
                        get = function() return self.db.global.style.onScreen.alpha end,
                        set = function(_, newValue) self.db.global.style.onScreen.alpha = newValue end,
                        order = 3,
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
