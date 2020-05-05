-- Private Members ------------------------------------------------------------[
local fillImages = {
    "images/squareGreen.jpg",
    "images/squareBlue.jpg",
    "images/squareOrange.jpg",
    "images/squareRed.jpg",
    "images/squareYellow.jpg",
    "images/squarePink.jpg"
}

local logoImages = {
    "images/logoRankings.png",
    "images/logoStore.png",
    "images/logoAboutASC.png",
    "images/logoMusic.png",
    "images/logoWatchAd.png",
    "images/logoGameStats.png",
}

local labelText = {
    "Rankings",
    "Store",
    "About ASC",
    "The Music",
    "Watch Ad",
    "Game Info",
}

local strokeColors = {
    { 0.055, 0.545, 0.078 }, --green
    { 0.098, 0.329, 0.902 }, --blue
    { 1, 0.427, 0.063 },     --orange
    { 0.902, 0.141, 0.125 },  --red
    { 0.922, 0.678, 0.055 }, --yellow
    { 1, 0, 0.722 },         --pink
}

local buttonIds = {
    "leaderboards",
    "market",
    "aboutASC",
    "aboutMusic",
    "ad",
    "gameInfo"
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