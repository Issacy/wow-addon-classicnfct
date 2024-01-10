--[[
	Russian Localization
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'ruRU')
if not L then return end

L.numStyles = {
    ["truncate"] = "Обрезать",
    ["commaSep"] = "Разделенные запятой",
    ["disable"] = "Отключить",
}

L.iconStyles = {
    ["none"] = "Без значков",
    ["left"] = "Левая сторона",
    ["right"] = "Правая сторона",
    ["both"] = "Обе стороны",
    ["only"] = "Только значки (без текста)",
};

L.fontStyles = {
    [""] = "Нет",
    ["OUTLINE"] = "Контур",
    ["THICKOUTLINE"] = "Толстый контур",
    ["nil, MONOCHROME"] = "Монохромный",
    ["OUTLINE , MONOCHROME"] = "Монохромный контур",
    ["THICKOUTLINE , MONOCHROME"] = "Монохромный толстый контур",
};

L.MISS_EVENT_STRINGS = {
    ["ABSORB"] = "Поглощение",
    ["BLOCK"] = "Блокировано",
    ["DEFLECT"] = "Отклонено",
    ["DODGE"] = "Уклонение",
    ["EVADE"] = "Уклонение",
    ["IMMUNE"] = "Иммун",
    ["MISS"] = "Промах",
    ["PARRY"] = "Парировать",
    ["REFLECT"] = "Отражать",
    ["RESIST"] = "Сопротивление",
};

L.UI = {
	["Enable"] = "Включено",
	["If the addon is enabled"] = "Если аддон включен",
	["Disable Blizzard FCT"] = "Отключить Blizzard FCT",
	["Animations"] = "Анимации",
	["Font"] = "Шрифт",
	["Vertical Distance"] = "Вертикальное расстояние",
	["Vertical Distance of Text Starting from NamePlate"] = "Вертикальное расстояние текста от иконки персонажа",
	["Icon"] = "Значок",
	["Scale"] = "Масштаб",
    ["Alpha"] = "Прозрачность",
    ["Pet Text Scale"] = "Масштаб текста для пета",
    ["Auto-Attack Text Scale"] = "Масштаб текста автоатаки",
}
