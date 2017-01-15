-------------------------------------------------------------------------------
--  Product IDs should match the In App Purchase products set up in iTunes Connect.
--  We cannot get them from the iTunes store so here they are hard coded;
--  your app could obtain them dynamically from your server.
-------------------------------------------------------------------------------
local g = require( "globalVariables" )

-- Create table for v library
local v = {}

-- To be assigned a product list from one of the arrays below after we've connected to a store.
-- Will be nil if no store is supported on this system/device.
local currentProductList = nil

-- Tables with data on valid and invalid products
-- Assigned by v.setData()
v.validProducts = {}
v.invalidProducts = {}


-- Product IDs for the "apple" app store.
local appleProductList =
{
	-- These Product IDs must already be set up in your store
	-- We'll use this list to retrieve prices etc. for each item
	-- Note, this simple test only has room for about 6 items, please adjust accordingly
	-- The iTunes store will not validate bad Product IDs.
	"com.AeroStarCreations.Drop.Shield1_5",
	"com.AeroStarCreations.Drop.Shield5_30",
	"com.AeroStarCreations.Drop.Shield10_65",
    "com.AeroStarCreations.Drop.Shield20_140",
    "com.AeroStarCreations.Drop.Shield50_365",
    "com.AeroStarCreations.Drop.Shield100_770",
    "com.AeroStarCreations.Drop.Life1_3",
    "com.AeroStarCreations.Drop.Life5_18",
    "com.AeroStarCreations.Drop.Life10_40",
    "com.AeroStarCreations.Drop.Life20_85",
    "com.AeroStarCreations.Drop.Life50_220",
    "com.AeroStarCreations.Drop.Life100_465",
    "com.AeroStarCreations.Drop.adsBundle",
}

-- Non-subscription product IDs for the "google" Android Marketplace.
local googleProductList =
{
	-- Real Product IDs for the "google" Android Marketplace.
	-- A managed product that can only be purchased once per user account. Google Play manages the transaction info.
	"iaptesting.managed",

	-- A product that isn't managed by Google Play. The app must store transaction info itself.
	-- In Google IAP V3, unmanaged products are treated like managed products and need to be explicitly consumed.
	"iaptesting.unmanaged",

	-- A bad product ID. For testing what actually happens in this case.
	"iaptesting.badid",
}

function v.getAppleProductList( )
	return appleProductList
end

function v.getGoogleProductList( )
    return googleProductList
end

local appleProductData = 
{ 
	{
		title = "Shield Drip",
		description = "5 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[1],
	},
	{
		title = "Shield Puddle",
		description = "30 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[2],
	},
	{
		title = "Shield Pond",
		description = "65 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[3],
	},
    {
		title = "Shield Lake",
		description = "140 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[4],
	},
    {
		title = "Shield Sea",
		description = "365 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[5],
	},
    {
		title = "Shield Ocean",
		description = "770 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[6],
	},
    {
		title = "Life Drip",
		description = "3 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[7],
	},
    {
		title = "Life Puddle",
		description = "18 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[8],
	},
    {
		title = "Life Pond",
		description = "40 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[9],
	},
    {
		title = "Life Lake",
		description = "85 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[10],
	},
    {
		title = "Life Sea",
		description = "220 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[11],
	},
    {
		title = "Life Ocean",
		description = "465 shields each worth 5 seconds of invincibility",
		productIdentifier = appleProductList[12],
	},
    {
		title = "Ads Bundle",
		description = "Remove ads from the game and recieve 3 lives and 5 shields",
		productIdentifier = appleProductList[13],
	},
}

local googleProductData = 
{ 
	{
		title = "Shield Drip",
		description = "5 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[1],
	},
	{
		title = "Shield Puddle",
		description = "30 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[2],
	},
	{
		title = "Shield Pond",
		description = "65 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[3],
	},
    {
		title = "Shield Lake",
		description = "140 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[4],
	},
    {
		title = "Shield Sea",
		description = "365 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[5],
	},
    {
		title = "Shield Ocean",
		description = "770 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[6],
	},
    {
		title = "Life Drip",
		description = "3 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[7],
	},
    {
		title = "Life Puddle",
		description = "18 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[8],
	},
    {
		title = "Life Pond",
		description = "40 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[9],
	},
    {
		title = "Life Lake",
		description = "85 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[10],
	},
    {
		title = "Life Sea",
		description = "220 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[11],
	},
    {
		title = "Life Ocean",
		description = "465 shields each worth 5 seconds of invincibility",
		productIdentifier = googleProductList[12],
	},
    {
		title = "Ads Bundle",
		description = "Remove ads from the game and recieve 3 lives and 5 shields",
		productIdentifier = googleProductList[13],
	},
}

-------------------------------------------------------------------------------
-- Returns the product data for the apple product list.
-------------------------------------------------------------------------------
function v.getAppleData( )
	return appleProductData
end

function v.getGoogleData( )
    return googleProductData
end

-------------------------------------------------------------------------------
-- Returns the product list for the platform we're running on.
-------------------------------------------------------------------------------
function v.getList( )
	return currentProductList
end

-------------------------------------------------------------------------------
-- Sets the product data that we wish to use for this platform.
-------------------------------------------------------------------------------
function v.setData( data )
  	if ( data.isError ) then
    	print( "Error in loading products " 
      	.. data.errorType .. ": " .. data.errorString )
    	return
  	end
	print( "data, data.name", data, data.name )
	print( data.products )
	print( "#data.products", #data.products )
	io.flush( )  -- remove for production

	-- save for later use
	v.validProducts = data.products
	v.invalidProducts = data.invalidProducts
end

-------------------------------------------------------------------------------
-- Sets the product list that we wish to use for this platform.
-------------------------------------------------------------------------------
function v.setProductList( platform )
	-- Set up the product list for this platform
	if ( platform == "Android" ) then
	    currentProductList = googleProductList
	elseif ( platform == "iPhone OS" ) then
		currentProductList = appleProductList
	elseif ( platform == "simulator" ) then
		--currentProductList = dummyProductList
	else
		-- Platform doesn't support IAP
		native.showAlert( "Notice", "In-app purchases are not supported on this system/device.", { "OK" } )
	end
end

----------------------------------------Give Reward
function v.giveReward( id )
    if id == 1 then
        g.buy.invincibility = g.buy.invincibility + 5
    elseif id == 2 then
        g.buy.invincibility = g.buy.invincibility + 30
    elseif id == 3 then
        g.buy.invincibility = g.buy.invincibility + 65
    elseif id == 4 then
        g.buy.invincibility = g.buy.invincibility + 140
    elseif id == 5 then
        g.buy.invincibility = g.buy.invincibility + 365
    elseif id == 6 then
        g.buy.invincibility = g.buy.invincibility + 770
    elseif id == 7 then
        g.buy.lives = g.buy.lives + 3
    elseif id == 8 then
        g.buy.lives = g.buy.lives + 18
    elseif id == 9 then
        g.buy.lives = g.buy.lives + 40
    elseif id == 10 then
        g.buy.lives = g.buy.lives + 85
    elseif id == 11 then
        g.buy.lives = g.buy.lives + 220
    elseif id == 12 then
        g.buy.lives = g.buy.lives + 465
    elseif id == 13 then
        g.buy.ads = true
        g.buy.invincibility = g.buy.invincibility + 5
        g.buy.lives = g.buy.lives + 3
    end
    g.buy:save()
end
---------------------------------------------------
-- Return product data library for external use
return v
