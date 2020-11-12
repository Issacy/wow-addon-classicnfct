--[[
	Russian Localization
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'ruRU')
if not L then return end

L.fmtStyles = {
    ["truncate"] = "Обрезать",
    ["commaSep"] = "Разделенные запятой",
    ["disable"] = "Отключить",
}

L.iconValues = {
    ["none"] = "Без значков",
    ["left"] = "Левая сторона",
    ["right"] = "Правая сторона",
    ["both"] = "Обе стороны",
    ["only"] = "Только значки (без текста)",
};

L.fontFlags = {
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
	["Animation Speed"] = "Скорость анимации",
    ["Default speed: 1"] = "Скорость по умолчанию: 1",
    ["Animation Max Lines"] = "Максимум строк анимации",
    ["Animation Count"] = "Количество анимаций",
	["Appearance"] = "Вид",
	["Font"] = "Шрифт",
	["Font Flags"] = "Флаги шрифтов",
	["Text Shadow"] = "Текстовая тень",
	["Use Damage Type Color"] = "Использовать цвет типа повреждения",
	["Vertical Distance"] = "Вертикальное расстояние",
	["Vertical Distance of Text Starting from NamePlate"] = "Вертикальное расстояние текста от иконки персонажа",
	["Text Formatting"] = "Форматирование текста",
    ["Format Style"] = "Формат стиля",
    ["Target Text Appearance"] = "Вид текста цели",
	["Icon"] = "Значок",
	["Scale"] = "Масштаб",
    ["Alpha"] = "Прозрачность",
    ["Pet Text Scale (Based on Target)"] = "Масштаб текста для пета (в зависимости от цели)",
    ["Auto-Attack Text Scale (Based on Target)"] = "Масштаб текста автоатаки (в зависимости от цели)",
	["Use Seperate Off-Target Text Appearance"] = "Использовать отдельный внешний вид текста вне цели",
	["Off-Target Text Appearance"] = "Внешний вид текста вне цели",
}
