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
            },
            alwaysOnScreen = false,
        },

        filter = {
            spellBlacklist = "",
            minDmg = 0,
            ignoreNoDmg = false,
        },
        
        style = {
            numStyle = "commaSep",
            iconStyle = "none",
            dmgTypeColor = false,
            scale = 1,
            alpha = 1,
            pet = { scale = 0.7, },
            autoAttack = { scale = 0.7, },
            
            useOffTarget = true,
            offTarget = {
                scale = 0.75,
                alpha = 0.5,
            },
    
            onScreen = {
                scale = 0.75,
                alpha = 0.5,
            },
        },
    },
}

local spellBlacklistConcat = {}

function ClassicNFCT:CreateDB()
    self.db = LibStub("AceDB-3.0"):New("ClassicNFCTDB", defaults, true)
    self:RestoreDBFromOldVersion()
    self.spellBlacklist = {}
    self:SetBlzFctToDB(self.db.global.blzDisabled)
    self:SetSpellBlacklistToDB(self.db.global.filter.spellBlacklist)
end

function ClassicNFCT:RestoreDBFromOldVersion()
    if self.db.global.style.spellBlacklist then
        self.db.global.filter.spellBlacklist = table.concat(self.db.global.style.spellBlacklist, '|')
        self.db.global.style.spellBlacklist = nil
    end
end

function ClassicNFCT:SetEnableToDB(enabled)
    self.db.global.enabled = enabled
    if enabled then
        self:RegisterDynamicEvents()
    else
        self:UnregisterDynamicEvents()
    end
end

function ClassicNFCT:SetBlzFctToDB(disabled)
    self.db.global.blzDisabled = disabled
    SetCVar("floatingCombatTextCombatDamage", disabled and "0" or "1")
end

function ClassicNFCT:SetSpellBlacklistToDB(newValue)
    wipe(spellBlacklistConcat)
    wipe(self.spellBlacklist)
    for v in self:SplitString(newValue, '|+') do
        v = v:lower()
        table.insert(spellBlacklistConcat, v)
        self.spellBlacklist[v] = true
    end
    self.db.global.filter.spellBlacklist = table.concat(spellBlacklistConcat, '|')
end
