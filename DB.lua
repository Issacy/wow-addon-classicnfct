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
end
