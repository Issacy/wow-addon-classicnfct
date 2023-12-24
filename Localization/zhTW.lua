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
	["Number Style"] = "數字樣式",
	["Icon Style"] = "圖標樣式",
	["Color by Damage Type"] = "根據傷害類型著色",
	["Scale"] = "縮放",
    ["Alpha"] = "透明度",
    ["Pet Text Scale (Based on Target)"] = "寵物文字縮放(基於目標)",
    ["Auto-Attack Text Scale (Based on Target)"] = "自動攻擊文字縮放(基於目標)",
	["Use Seperate Off-Target Text Style"] = "使用獨立的副目標文字樣式",
	["Off-Target Text Style"] = "副目標文字樣式",
    ["Use Seperate On-Screen Text Style"] = "使用獨立的屏上文字樣式",
	["On-Screen Text Style"] = "屏上文字樣式",
}
