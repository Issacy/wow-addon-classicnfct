--[[
	Chinese Traditional Localization
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'zhTW')
if not L then return end

L.fmtStyles = {
    ["truncate"] = "縮短",
    ["commaSep"] = "分隔符",
    ["disable"] = "無",
}

L.iconValues = {
    ["none"] = "無圖標",
    ["left"] = "左側圖標",
    ["right"] = "右側圖標",
    ["both"] = "兩側圖標",
    ["only"] = "只有圖標(無數字)",
};

L.fontFlags = {
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
	["Animation Speed"] = "動畫速度",
    ["Default speed: 1"] = "默認速度: 1",
    ["Animation Max Lines"] = "動畫最大行數",
    ["Animation Count"] = "動畫數量",
    ["Crit Animation Duration Ratio"] = "致命一擊動畫時長佔比",
    ["The ratio of crit animation duration to the entire animation duration when make crit damage\nDefault: 0.2"] = "當致命一擊時, 致命一擊動畫時長相對於整個動畫時長的比例\nm默認: 0.2",
	["Appearance"] = "表現",
	["Font"] = "字體",
	["Font Flags"] = "字體樣式",
	["Text Shadow"] = "字體陰影",
	["Use Damage Type Color"] = "根據傷害類型著色",
	["Vertical Distance"] = "垂直距離",
	["Vertical Distance of Text Starting from NamePlate"] = "文字開始時距離姓名版的垂直距離",
	["Text Formatting"] = "文字格式化",
    ["Format Style"] = "格式化樣式",
    ["Target Text Appearance"] = "目標文字表現",
	["Icon"] = "圖標",
	["Scale"] = "縮放",
    ["Alpha"] = "透明度",
    ["Pet Text Scale (Based on Target)"] = "寵物文字縮放(基於目標)",
    ["Auto-Attack Text Scale (Based on Target)"] = "自動攻擊文字縮放(基於目標)",
	["Use Seperate Off-Target Text Appearance"] = "使用分離的副目標文字表現",
	["Off-Target Text Appearance"] = "副目標文字表現",
}
