local defaultFont = "Friz Quadrata TT"
if (LibStub("LibSharedMedia-3.0"):IsValid("font", "Bazooka")) then
    defaultFont = "Bazooka"
end

local defaults = {
    global = {
        enabled = true,
        blzDisabled = true,

        font = defaultFont,
        fontFlag = "",
        textShadow = true,
        damageColor = false,

        fmtStyle = "commaSep",

        animations = {
            animationspeed = 1,
            critpercent = .2,
            -- animMaxLines = 5,
            -- animationCount = 80,
        },

        distance = 25,

        formatting = {
            icon = "none",
            scale = 1,
            alpha = 1,
        },

        petFormatting = { scale = 0.7, },
        autoAttackFormatting = { scale = 0.7, },

        useOffTarget = true,
        offTargetFormatting = {
            scale = 0.5,
            alpha = 0.33,
        },
    },
}

function ClassicNFCT:CreateDB()
    self.db = LibStub("AceDB-3.0"):New("ClassicNFCTDB", defaults, true)
end