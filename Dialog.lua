local _

local dialogs = {}
local inCombat = false

function ClassicNFCT:CreateDialog()
    local L = self.L

    dialogs["FONT_INVALID"] = {
        hideInCombat = true,
        dialog = {
            text = L.DIALOG["ClassicNFCT: Font is invalid, please select another one"],
            button1 = L.DIALOG["OK"],
            showAlert = true,
            hideOnEscape = true,
            enterClicksFirstButton = true,
        }
    }

    for key, dialog in pairs(dialogs) do
        dialog.show = 0
        dialog.key = "ClassicNFCT_" .. key
        dialog.dialog.OnShow = function() dialog.show = 1 end
        dialog.dialog.OnHide = function() dialog.show = 0 end
        StaticPopupDialogs[dialog.key] = dialog.dialog
    end
end

function ClassicNFCT:ShowDialog(key)
    local dialog = dialogs[key]
    if not dialog or dialog.show == 1 then return end
    if inCombat and dialog.hideInCombat then
        dialog.show = 2
    else
        StaticPopup_Show(dialog.key)
    end
end

function ClassicNFCT:HideInCombatDialog()
    inCombat = true
    for _, dialog in pairs(dialogs) do
        if dialog.hideInCombat and dialog.show == 1 then
            StaticPopup_Hide(dialog.key)
            dialog.show = 2
        end
    end
end

function ClassicNFCT:ShowInCombatDialog()
    inCombat = false
    for _, dialog in pairs(dialogs) do
        if dialog.show == 2 then
            dialog.show = 0
            StaticPopup_Show(dialog.key)
        end
    end
end
