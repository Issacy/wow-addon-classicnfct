--[[
	Chinese Simplified Localization
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'zhCN')
if not L then return end

L.numStyles = {
    ["truncate"] = "缩短",
    ["commaSep"] = "千分位",
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
    ["Always Show Text on Screen"] = "总是在屏上显示文字",
    ["Filter"] = "过滤",
    ["Spell Blacklist"] = "法术黑名单",
    ["Min Damage"] = "最小伤害",
    ["Ignore No Damage"] = "忽略无伤害",
    ["Count Limitation"] = "数量限制",
    ["Total"] = "总限制",
    ["Except for current target, 0 means no limit"] = "当前目标除外，0代表不限制",
    ["Count of Not-Targeting"] = "非当前目标个数",
    ["Count per Not-Targeting"] = "每个非当前目标",
    ["0 means no limit"] = "0代表不限制",
	["Number Style"] = "数字样式",
	["Icon Style"] = "图标样式",
	["Color by Damage Type"] = "根据伤害类型着色",
	["Spell ID or Name Seperated by Vertical bar (|)\nSpecial tags: spell|melee|pet|pet_spell|pet_melee"] = "法术ID或名称 竖线分隔 (|)\n特殊标签: spell|melee|pet|pet_spell|pet_melee",
	["Scale"] = "缩放",
    ["Alpha"] = "透明度",
    ["Pet Text Scale"] = "宠物文字缩放",
    ["Auto-Attack Text Scale"] = "自动攻击文字缩放",
    ["Scale based on Target"] = "缩放基于目标",
	["Use Standalone Not-Targeting Text Style"] = "使用独立的非当前目标文字样式",
	["Not-Targeting Text Style"] = "非当前目标文字样式",
	["On-Screen Text Style"] = "屏上文字样式",
}

L.CMD = {
    ["Classic Nameplate-based Floating Combat Text Command Help: /cnfct help"] = "Classic Nameplate-based Floating Combat Text命令帮助: /cnfct help",
    
    ["Open option"] = "打开选项",
    ["Enable addon"] = "启用插件",
    ["Disable addon"] = "禁用插件",
    ["Show text on screen"] = "在屏上显示文字",
    ["Show text on nameplate"] = "在姓名版上显示文字",
}

L.DIALOG = {
    ["ClassicNFCT: Font is invalid, please select another one"] = "ClassicNFCT: 字体无效, 请选择另一种字体"
}
