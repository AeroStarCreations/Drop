-- Private Members ------------------------------------------------------------[
local buttonFileNames = {
    [1] = "images/iapAdsBundle.png",
    [2] = "images/iapShields1.png",
    [3] = "images/iapLives1.png",
    [4] = "images/iapShields5.png",
    [5] = "images/iapLives5.png",
    [6] = "images/iapShields10.png",
    [7] = "images/iapLives10.png",
    [8] = "images/iapShields20.png",
    [9] = "images/iapLives20.png",
    [10] = "images/iapShields50.png",
    [11] = "images/iapLives50.png",
    [12] = "images/iapShields100.png",
    [13] = "images/iapLives100.png"
}

local productIds = {
    [1] = "com.aerostarcreations.drop.adsbundle",
    [2] = "com.aerostarcreations.drop.shield1",
    [3] = "com.aerostarcreations.drop.life1",
    [4] = "com.aerostarcreations.drop.shield5",
    [5] = "com.aerostarcreations.drop.life5",
    [6] = "com.aerostarcreations.drop.shield10",
    [7] = "com.aerostarcreations.drop.life10",
    [8] = "com.aerostarcreations.drop.shield20",
    [9] = "com.aerostarcreations.drop.life20",
    [10] = "com.aerostarcreations.drop.shield50",
    [11] = "com.aerostarcreations.drop.life50",
    [12] = "com.aerostarcreations.drop.shield100",
    [13] = "com.aerostarcreations.drop.life100",
}

-- Public Members -------------------------------------------------------------[
local v = {}

function v.getButtonFileName(index)
    return buttonFileNames[index]
end

function v.getProductId(index)
    return productIds[index]
end

function v.getProductIds()
    return productIds
end

return v
