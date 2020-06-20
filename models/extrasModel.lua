-- Private Members ------------------------------------------------------------[
local fillImages = {
    "images/squareGreen.jpg",
    "images/squareBlue.jpg",
    "images/squareOrange.jpg",
    "images/squarePink.jpg",
    "images/squareRed.jpg",
    "images/squareYellow.jpg",
}

local logoImages = {
    "images/logoRankings.png",
    "images/logoStore.png",
    "images/logoAboutASC.png",
    "images/logoGameStats.png",
    "images/logoWatchAd.png",
    "images/logoMusic.png",
}

local labelText = {
    "Rankings",
    "Store",
    "About ASC",
    "Game Info",
    "Watch Ad",
    "The Music",
}

local strokeColors = {
    { 0.055, 0.545, 0.078 }, --green
    { 0.098, 0.329, 0.902 }, --blue
    { 1, 0.427, 0.063 },     --orange
    { 1, 0, 0.722 },         --pink
    { 0.902, 0.141, 0.125 },  --red
    { 0.922, 0.678, 0.055 }, --yellow
}

local buttonIds = {
    "leaderboards",
    "market",
    "aboutASC",
    "gameInfo",
    "ad",
    "aboutMusic",
}

-- Public Members -------------------------------------------------------------[
local v = {}

function v.getFillImages()
    return fillImages
end

function v.getLogoImages()
    return logoImages
end

function v.getLabelText()
    return labelText
end

function v.getStrokeColors()
    return strokeColors
end

function v.getButtonIds()
    return buttonIds
end

return v