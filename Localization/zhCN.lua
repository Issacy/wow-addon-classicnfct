--[[
	Chinese Simplified Localization
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'zhCN')
if not L then return end

L.numStyles = {
    ["truncate"] = "缩短",
    ["commaSep"] = "分隔符",
    ["disable"] = "无",
}

L.iconStyles = {
    ["none"] = "无图标",
    ["left"] = "左侧图标",
    ["right"] = "右侧图标",
    ["both"] = "两侧图标",
    ["only"] = "只有图标(无数字)",
};

L.fontStyles = {
    [""] = "无",
    ["OUTLINE"] = "描边",
    ["THICKOUTLINE"] = "粗描边",
    ["MONOCHROME"] = "等宽",
    ["OUTLINE , MONOCHROME"] = "等宽+描边",
    ["THICKOUTLINE , MONOCHROME"] = "等宽+粗描边",
};

L.MISS_EVENT_STRINGS = {
    ["ABSORB"] = "吸收",
    ["BLOCK"] = "格挡",
    ["DEFLECT"] = "偏转",
    ["DODGE"] = "躲闪",
    ["EVADE"] = "闪避",
    ["IMMUNE"] = "免疫",
    ["MISS"] = "未命中",
    ["PARRY"] = "招架",
    ["REFLECT"] = "反射",
    ["RESIST"] = "抵抗",
};

L.UI = {
	["Enable"] = "启用",
	["If the addon is enabled"] = "是否启用插件",
	["Disable Blizzard FCT"] = "禁用暴雪浮动战斗数字",
	["Animations"] = "动画",
	["Animation Duration"] = "动画持续时间",
	["Font"] = "字体",
	["Style"] = "样式",
    ["Size"] = "大小",
	["Shadow"] = "阴影",
    ["Layout"] = "布局",
	["Vertical Distance"] = "垂直距离",
	["Vertical Distance of Text Starting from NamePlate"] = "文字开始时距离姓名版的垂直距离",
    ["Line Height"] = "行高",
    ["On-Screen Text Position"] = "屏上文字位置",
    ["Center Offset X"] = "中心偏移量X",
    ["Center Offset Y"] = "中心偏移量Y",
	["Number Style"] = "数字样式",
	["Icon Style"] = "图标样式",
	["Color by Damage Type"] = "根据伤害类型着色",
	["Scale"] = "缩放",
    ["Alpha"] = "透明度",
    ["Pet Text Scale (Based on Target)"] = "宠物文字缩放(基于目标)",
    ["Auto-Attack Text Scale (Based on Target)"] = "自动攻击文字缩放(基于目标)",
	["Use Seperate Off-Target Text Style"] = "使用独立的副目标文字样式",
	["Off-Target Text Style"] = "副目标文字样式",
    ["Use Seperate On-Screen Text Style"] = "使用独立的屏上文字样式",
	["On-Screen Text Style"] = "屏上文字样式",
}
