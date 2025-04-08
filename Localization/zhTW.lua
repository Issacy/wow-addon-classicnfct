--[[
	Chinese Traditional Localization
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'zhTW')
if not L then return end

L.numStyles = {
    ["truncate"] = "縮短",
    ["commaSep"] = "分隔符",
    ["disable"] = "無",
}

L.iconStyles = {
    ["none"] = "無圖標",
    ["left"] = "左側圖標",
    ["right"] = "右側圖標",
    ["both"] = "兩側圖標",
    ["only"] = "只有圖標(無數字)",
};

L.fontStyles = {
    [""] = "無",
    ["OUTLINE"] = "描邊",
    ["THICKOUTLINE"] = "粗描邊",
    ["nil, MONOCHROME"] = "等寬",
    ["OUTLINE , MONOCHROME"] = "等寬+描邊",
    ["THICKOUTLINE , MONOCHROME"] = "等寬+粗描邊",
};

L.MISS_EVENT_STRINGS = {
    ["ABSORB"] = "吸收",
    ["BLOCK"] = "格擋",
    ["DEFLECT"] = "偏轉",
    ["DODGE"] = "閃躲",
    ["EVADE"] = "閃避",
    ["IMMUNE"] = "免疫",
    ["MISS"] = "未擊中",
    ["PARRY"] = "招架",
    ["REFLECT"] = "反射",
    ["RESIST"] = "抵抗",
};

L.UI = {
	["Enable"] = "啟用",
	["If the addon is enabled"] = "是否啟用插件",
	["Disable Blizzard FCT"] = "禁用暴雪浮動戰鬥數字",
	["Animations"] = "動畫",
	["Animation Duration"] = "動畫持續時間",
	["Font"] = "字體",
	["Style"] = "樣式",
	["Size"] = "大小",
	["Shadow"] = "陰影",
	["Layout"] = "佈局",
	["Vertical Distance"] = "垂直距離",
	["Vertical Distance of Text Starting from NamePlate"] = "文字開始時距離姓名版的垂直距離",
    ["Line Height"] = "行高",
    ["On-Screen Text Position"] = "屏上文字位置",
    ["Center Offset X"] = "中心偏移量X",
    ["Center Offset Y"] = "中心偏移量Y",
    ["Always Show Text on Screen"] = "總是在屏上顯示文字",
    ["Filter"] = "過濾",
	["Spell Blacklist"] = "法術黑名單",
    ["Min Damage"] = "最小傷害",
    ["Ignore No Damage"] = "忽略無傷害",
    ["Limit Damage Numbers"] = "傷害數量限制",
    ["Total"] = "總限制",
    ["Except for current target, 0 means no limit"] = "當前目標除外，0代表不限制",
    ["Per Non-Target"] = "每個非目標",
    ["0 means no limit"] = "0代表不限制",
	["Number Style"] = "數字樣式",
	["Icon Style"] = "圖標樣式",
	["Color by Damage Type"] = "根據傷害類型著色",
	["Spell ID or Name Seperated by Vertical bar (|)\nSpecial tags: spell|melee|pet|pet_spell|pet_melee"] = "法術ID或名稱 豎線分隔（|）\n特殊標簽: spell|melee|pet|pet_spell|pet_melee",
	["Scale"] = "縮放",
    ["Alpha"] = "透明度",
    ["Pet Text Scale"] = "寵物文字縮放",
    ["Auto-Attack Text Scale"] = "自動攻擊文字縮放",
    ["Scale based on Target"] = "縮放基於目標",
	["Use Seperate Non-Target Text Style"] = "使用獨立的非目標文字樣式",
	["Non-Target Text Style"] = "非目標文字樣式",
	["On-Screen Text Style"] = "屏上文字樣式",
}

L.CMD = {
    ["Classic Nameplate-based Floating Combat Text Command Help: /cnfct help"] = "Classic Nameplate-based Floating Combat Text命令幫助: /cnfct help",
    
    ["Open option"] = "打開選項",
    ["Enable addon"] = "啓用插件",
    ["Disable addon"] = "禁用插件",
    ["Show text on screen"] = "在屏上顯示文字",
    ["Show text on nameplate"] = "在姓名版上顯示文字",
}

L.DIALOG = {
    ["ClassicNFCT: Font is invalid, please select another one"] = "ClassicNFCT: 字體無效, 請選擇另一種字體"
}
