--[[
	Chinese Simplified Localization
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'zhCN')
if not L then return end

L.fmtStyles = {
    ["truncate"] = "缩短",
    ["commaSep"] = "分隔符",
    ["disable"] = "无",
}

L.iconValues = {
    ["none"] = "无图标",
    ["left"] = "左侧图标",
    ["right"] = "右侧图标",
    ["both"] = "两侧图标",
    ["only"] = "只有图标(无数字)",
};

L.fontFlags = {
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
	["Animation Speed"] = "动画速度",
    ["Default speed: 1"] = "默认速度: 1",
    ["Animation Max Lines"] = "动画最大行数",
    ["Animation Count"] = "动画数量",
    ["Crit Animation Duration Ratio"] = "暴击动画时长占比",
    ["The ratio of crit animation duration to the entire animation duration when make crit damage\nDefault: 0.2"] = "当暴击时, 暴击动画时长相对于整个动画时长中的比例\nm默认: 0.2",
	["Appearance"] = "表现",
	["Font"] = "字体",
	["Font Flags"] = "字体样式",
	["Text Shadow"] = "字体阴影",
	["Use Damage Type Color"] = "根据伤害类型着色",
	["Vertical Distance"] = "垂直距离",
	["Vertical Distance of Text Starting from NamePlate"] = "文字开始时距离姓名版的垂直距离",
	["Text Formatting"] = "文字格式化",
    ["Format Style"] = "格式化样式",
    ["Target Text Appearance"] = "目标文字表现",
	["Icon"] = "图标",
	["Scale"] = "缩放",
    ["Alpha"] = "透明度",
    ["Pet Text Scale (Based on Target)"] = "宠物文字缩放(基于目标)",
    ["Auto-Attack Text Scale (Based on Target)"] = "自动攻击文字缩放(基于目标)",
	["Use Seperate Off-Target Text Appearance"] = "使用分离的副目标文字表现",
	["Off-Target Text Appearance"] = "副目标文字表现",
}
