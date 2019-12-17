-- Private Members ------------------------------------------------------------[
local tag = "IAP:"

local currentProductDataList = nil

local appleProductIDs = {
	-- These Product IDs must already be set up in your store
	-- We'll use this list to retrieve prices etc. for each item
	-- Note, this simple test only has room for about 6 items, please adjust accordingly
	-- The iTunes store will not validate bad Product IDs.
	[1] = "com.AeroStarCreations.Drop.Shield1_5",
	[2] = "com.AeroStarCreations.Drop.Shield5_30",
	[3] = "com.AeroStarCreations.Drop.Shield10_65",
    [4] = "com.AeroStarCreations.Drop.Shield20_140",
    [5] = "com.AeroStarCreations.Drop.Shield50_365",
    [6] = "com.AeroStarCreations.Drop.Shield100_770",
    [7] = "com.AeroStarCreations.Drop.Life1_3",
    [8] = "com.AeroStarCreations.Drop.Life5_18",
    [9] = "com.AeroStarCreations.Drop.Life10_40",
    [10] = "com.AeroStarCreations.Drop.Life20_85",
    [11] = "com.AeroStarCreations.Drop.Life50_220",
    [12] = "com.AeroStarCreations.Drop.Life100_465",
    [13] = "com.AeroStarCreations.Drop.adsBundle",
}

-- Non-subscription product IDs for the "google" Android Marketplace.
local googleProductIDs = {
    -- Real Product IDs for the "google" Android Marketplace.
    -- A managed product that can only be purchased once per user account. Google Play manages the transaction info.
    "iaptesting.managed",

    -- A product that isn't managed by Google Play. The app must store transaction info itself.
    -- In Google IAP V3, unmanaged products are treated like managed products and need to be explicitly consumed.
    "iaptesting.unmanaged",

    -- A bad product ID. For testing what actually happens in this case.
    "iaptesting.badid",
}

local productDescriptions = {
    [1] = "5 shields each worth 5 seconds of invincibility",
    [2] = "30 shields each worth 5 seconds of invincibility",
    [3] = "65 shields each worth 5 seconds of invincibility",
    [4] = "140 shields each worth 5 seconds of invincibility",
    [5] = "365 shields each worth 5 seconds of invincibility",
    [6] = "770 shields each worth 5 seconds of invincibility",
    [7] = "3 shields each worth 5 seconds of invincibility",
    [8] = "18 shields each worth 5 seconds of invincibility",
    [9] = "40 shields each worth 5 seconds of invincibility",
    [10] = "85 shields each worth 5 seconds of invincibility",
    [11] = "220 shields each worth 5 seconds of invincibility",
    [12] = "465 shields each worth 5 seconds of invincibility",
    [13] = "Remove ads from the game and recieve 3 lives and 5 shields",
}

local productTitles = {
    [1] = "Shield Drip",
    [2] = "Shield Puddle",
    [3] = "Shield Pond",
    [4] = "Shield Lake",
    [5] = "Shield Sea",
    [6] = "Shield Ocean",
    [7] = "Life Drip",
    [8] = "Life Puddle",
    [9] = "Life Pond",
    [10] = "Life Lake",
    [11] = "Life Sea",
    [12] = "Life Ocean",
    [13] = "Ads Bundle",
}

local rewards = {
    [1] = {quantity=5, type="invincibility"},
    [2] = {quantity=30, type="invincibility"},
    [3] = {quantity=65, type="invincibility"},
    [4] = {quantity=140, type="invincibility"},
    [5] = {quantity=365, type="invincibility"},
    [6] = {quantity=770, type="invincibility"},
    [7] = {quantity=3, type="lives"},
    [8] = {quantity=18, type="lives"},
    [9] = {quantity=40, type="lives"},
    [10] = {quantity=85, type="lives"},
    [11] = {quantity=220, type="lives"},
    [12] = {quantity=465, type="lives"},
    [13] = {quantityLives=3, quantityInvincibilities=5, type="ads"},
}

local function newProductData(platform, index)
    local productIDs = appleProductIDs
    if (platform == "android") then
        productIDs = googleProductIDs
    end
    return {
        title = productTitles[index],
        description = productDescriptions[index],
        productID = productIDs[index]
    }
end

local function getPlatform()
    local platform = system.getInfo( "platform" )
    local environment = system.getInfo( "environment" )
    if (environment == "simulator") then
        print(tag, "IAP is not supported on the simulator.")
    end
    if (platform == "ios" or platform == "android") then
        return platform
    end
    error("IAP not supported on this device! Should never reach this point.")
end

local function setCurrentProductDataList()
    currentProductDataList = {}
    local platform = getPlatform()
    for index = 1, #productTitles do
        table.insert( 
            currentProductDataList,
            index,
            newProductData(platform, index)
        )
    end
end

-- Public Members -------------------------------------------------------------[
local v = {}

function v.getTag()
    return tag
end

function v.setProductDataList()
    setCurrentProductDataList()
end

function v.getProductDataList()
    if (currentProductDataList == nil) then
        setCurrentProductDataList()
    end
    return currentProductDataList
end

function v.getReward(index)
    return rewards[index]
end

return v