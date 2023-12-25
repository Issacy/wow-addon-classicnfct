local SharedMedia = LibStub("LibSharedMedia-3.0")

local defaultFont = SharedMedia:GetDefault("font")

local defaults = {
    global = {
        enabled = true,
        blzDisabled = true,

        
        font = {
            choice = defaultFont,
            flag = "",
            size = 30,
            shadow = true,
        },
        
        animations = {
            animationDuration = 1.5,
            -- critpercent = 0.15,
            -- animMaxLines = 5,
            -- animationCount = 80,
        },
        
        layout = {
            distance = 25,
            lineHeight = 45,
            onScreenPos = {
                centerOffsetX = 0,
                centerOffsetY = 200,
            }
        },
        
        style = {
            numStyle = "commaSep",
            iconStyle = "none",
            dmgTypeColor = false,
            spellBlacklist = {},
            scale = 1,
            alpha = 1,
            pet = { scale = 0.7, },
            autoAttack = { scale = 0.7, },
            
            useOffTarget = true,
            offTarget = {
                scale = 0.75,
                alpha = 0.5,
            },
    
            useOnScreen = false,
            onScreen = {
                scale = 1,
                alpha = 1,
            },
        },
    },
}

function ClassicNFCT:CreateDB()
    self.db = LibStub("AceDB-3.0"):New("ClassicNFCTDB", defaults, true)
    self.spellBlacklist = {}
    for _, v in ipairs(self.db.global.style.spellBlacklist) do
        self.spellBlacklist[v] = true
    end
    self:GenerateSpellBlacklistForMenu()
end

function ClassicNFCT:GenerateSpellBlacklistForMenu()
    self.spellBlacklistForMenu = table.concat(self.db.global.style.spellBlacklist, '|')
end

function ClassicNFCT:UpdateSpellBlacklistForDB(newValueString)
    local t = {}
    for spellID in self:SplitString(newValue, '|+') do
        table.insert(t, spellID:lower(spellID))
    end
    self.db.global.style.spellBlacklist = t
    self:GenerateSpellBlacklistForMenu()
end

