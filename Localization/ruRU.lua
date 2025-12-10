--[[
    Russian Localization
--]]

local L = LibStub('AceLocale-3.0'):NewLocale("ClassicNFCT", 'ruRU')
if not L then return end

L.NUM_TRUNCATION = {
    divider = 1000,
    words = {"", "K", "M", "B"}
}

L.NUM_STYLES = {
    ["truncate"] = "Обрезать",
    ["commaSep"] = "Разделитель тысяч",
    ["disable"] = "Отключить",
}

L.ICON_STYLES = {
    ["none"] = "Без значков",
    ["left"] = "Левая сторона",
    ["right"] = "Правая сторона",
    ["both"] = "Обе стороны",
};

L.FONT_STYLES = {
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
    ["Vertical distance of text starting from nameplate"] = "Вертикальное расстояние текста от иконки персонажа",
    ["Icon"] = "Значок",
    ["Scale"] = "Масштаб",
    ["Alpha"] = "Прозрачность",
    ["Pet Text Scale"] = "Масштаб текста для пета",
    ["Auto-Attack Text Scale"] = "Масштаб текста автоатаки",
}
