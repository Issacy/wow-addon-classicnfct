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
            get = function() return self.db.global.enabled end,
            set = function(_, newValue) self:SetEnableToDB(newValue) end,
            order = 1,
            width = "half",
        },
        disableBlizzardFCT = {
            type = 'toggle',
            name = L.UI["Disable Blizzard FCT"],
            desc = "",
            get = function() return self.db.global.blzDisabled end,
            set = function(_, newValue) self:SetBlzFctToDB(newValue) end,
            order = 2,
            width = "double",
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
                set = function(_, newValue) self.db.global.font.shadow = newValue end,
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
                        order = 2,
                    },
                }
            },
            alwaysOnScreen = {
                type = 'toggle',
                name = L.UI["Always Show Text on Screen"],
                desc = '',
                get = function() return self.db.global.layout.alwaysOnScreen end,
                set = function(_, newValue) self.db.global.layout.alwaysOnScreen = newValue end,
                order = 4,
            },
        }
    }

    menu.args.total.args.filter = {
        type = 'group',
        name = L.UI["Filter"],
        order = 7,
        args = {
            spellBlacklist = {
                type = 'input',
                name = L.UI["Spell Blacklist"],
                desc = L.UI["Spell ID or Name Seperated by Vertical bar (|)\nSpecial tags: spell|melee|pet|pet_spell|pet_melee"],
                multiline = 3,
                get = function() return self.db.global.filter.spellBlacklist end,
                set = function(_, newValue) self:SetSpellBlacklistToDB(newValue) end,
                order = 1,
                width = 'full',
            },
            minDmg = {
                type = 'input',
                name = L.UI["Min Damage"],
                desc = "",
                get = function() return tostring(self.db.global.filter.minDmg) end,
                set = function(_, newValue)
                    newValue = tonumber(newValue)
                    if newValue == nil then return end
                    self.db.global.filter.minDmg = math.max(math.floor(newValue), 0)
                end,
                order = 2,
            },
            ignoreNoDmg = {
                type = 'toggle',
                name = L.UI["Ignore No Damage"],
                desc = "",
                get = function() return self.db.global.filter.ignoreNoDmg end,
                set = function(_, newValue) self.db.global.filter.ignoreNoDmg = newValue end,
                order = 3,
            },
        }
    }

    menu.args.total.args.style = {
        type = 'group',
        name = L.UI["Style"],
        order = 8,
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
            scale = {
                type = 'range',
                name = L.UI["Scale"],
                desc = "",
                min = .01,
                max = 5,
                step = .01,
                get = function() return self.db.global.style.scale end,
                set = function(_, newValue) self.db.global.style.scale = newValue end,
                order = 4,
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
                order = 5,
            },
            petScale = {
                type = 'range',
                name = L.UI["Pet Text Scale"],
                desc = L.UI["Scale based on Target"],
                min = .01,
                max = 5,
                step = .01,
                get = function() return self.db.global.style.pet.scale end,
                set = function(_, newValue) self.db.global.style.pet.scale = newValue end,
                order = 6,
            },

            autoAttackScale = {
                type = 'range',
                name = L.UI["Auto-Attack Text Scale"],
                desc = L.UI["Scale based on Target"],
                min = .01,
                max = 5,
                step = .01,
                get = function() return self.db.global.style.autoAttack.scale end,
                set = function(_, newValue) self.db.global.style.autoAttack.scale = newValue end,
                order = 7,
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
            onScreen = {
                type = 'group',
                name = L.UI["On-Screen Text Style"],
                order = 10,
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
    InterfaceOptionsFrame_OpenToCategory(self.menu)
end
