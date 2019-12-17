-------------------------------------------------------------------------------
--  Product IDs should match the In App Purchase products set up in iTunes Connect.
--  We cannot get them from the iTunes store so here they are hard coded;
--  your app could obtain them dynamically from your server.
-------------------------------------------------------------------------------
local g = require( "other.globalVariables" )
local ld = require( "data.localData" )
local model = require( "models.iapModel" )

-- Create table for v library
local v = {}

-- Tables with data on valid and invalid products
-- Assigned by v.setData()
v.validProducts = {}
v.invalidProducts = {}

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
function v.setProductList()
	model.setProductDataList()
end

----------------------------------------Give Reward
function v.giveReward( id )
	local reward = model.getReward(id)
	if (reward.type == "invincibility") then
		ld.addInvincibility( reward.quantity )
	elseif (reward.type == "lives") then
		ld.addLives( reward.quantity )
	elseif (reward.type == "ads") then
		ld.setAdsEnabled( false )
		ld.addInvincibility( reward.quantityInvincibilities )
		ld.addLives( reward.quantityLives )
	else
		print(model.getTag(), "Reward type unknown!")
	end
end

return v
