local sd = require( "serverData" )
local json = require( "json" )
local Alert = require( "views.other.Alert" )

--Precalls
local TAG = "Marketplace.lua: "
local store
local storeIsAvailable = true
local canMakePurchases = true
local purchaseCallback

local productIDs = {
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
----------
 
local targetAppStore = system.getInfo( "targetAppStore" )
print(TAG, "targetAppStore = "..targetAppStore)
 
if ( "apple" == targetAppStore ) then  -- iOS
    store = require( "store" )
elseif ( "google" == targetAppStore ) then  -- Android
    store = require( "plugin.google.iap.v3" )
else
    print( "In-app purchases are not available for this platform." )
    storeIsAvailable = false
    native.showAlert( "Notice", "In-app purchases are not supported on this system/device.", { "OK" } )
end

local function boughtItemsContains( boughtItems, shortCode )
    for k,v in pairs( boughtItems ) do
        if v.shortCode == shortCode then
            return true
        end
    end
    return false
end

local function boughtItemQuantity( boughtItems, shortCode )
    for k,v in pairs( boughtItems ) do
        if v.shortCode == shortCode then
            return v.quantity
        end
    end
end

local function createMessageFromBoughtItems( boughtItems )
    local message = ""
    if boughtItemsContains( boughtItems, "ADS" ) then
        message = "No more ads!"
    end
    if boughtItemsContains( boughtItems, "LIFE" ) then
        local quantity = boughtItemQuantity( boughtItems, "LIFE" )
        message = message .. "\n+" .. quantity .. " lives"
    end
    if boughtItemsContains( boughtItems, "SHIELD" ) then
        local quantity = boughtItemQuantity( boughtItems, "SHIELD" )
        message = message .. "\n+" .. quantity .. " shields"
    end
    if string.sub( message, 1, 1 ) == "\n" then
        message = string.sub( message, 2, string.len( message ) )
    end
    return message
end

local function showSuccessfulPurchaseAlert( boughtItems )
    local message = createMessageFromBoughtItems( boughtItems )
    Alert:new( "Purchase Successful!", message, {"OK"}, purchaseCallback )
end

local function showFailedPurchaseAlert()
    Alert:new( "Purchase Failed!", "Could not validate purchase receipt", {"OK"}, purchaseCallback )
end

local function showConfirmationAlert( boughtItems, hasErrors )
    if hasErrors then
        showFailedPurchaseAlert()
    else
        showSuccessfulPurchaseAlert( boughtItems )
    end
end

local function confirmPurchaseWithGameSparks( receipt, signature )
    if targetAppStore == "apple" then
        sd.confirmPurchaseWithApple( receipt, showConfirmationAlert )
    elseif targetAppStore == "google" then
        sd.confirmPurchaseWithGoogle( receipt, signature, showConfirmationAlert )
    end
end

local function transactionListener( event )
 
    local transaction = event.transaction
 
    if event.name == "init" then -- Google IAP initialization event (Apple doesn't use this)
        if transaction.isError then 
            -- Unsuccessful initialization; output error details
            print( transaction.errorType )
            print( transaction.errorString )
        else
            -- Perform steps to enable IAP, load products, etc.
            -- store.isActive will be 'true' at this point
        end
    else
        if transaction.isError then -- Failed transation
            print( TAG, transaction.errorType )
            print( TAG, transaction.errorString )
            Alert:new( "Transaction Failed", "Please check your internet connection and try again", {"OK"}, purchaseCallback)
        else -- Successful transaction
            if not ( event.transaction.state == "failed" ) then  -- Successful transaction
                print( json.prettify( event ) )
                print( TAG, "event.transaction: " .. json.prettify( transaction ) )
            else  -- Unsuccessful transaction; output error details
                print( TAG, transaction.errorType )
                print( TAG, transaction.errorString )
                Alert:new( "Transaction Failed", "Please check your internet connection and try again", {"OK"}, purchaseCallback)
            end

            if ( transaction.state == "purchased" or transaction.state == "restored" ) then
                -- Handle a normal purchase or restored purchase here
                print( TAG, transaction.state )
                print( TAG, transaction.productIdentifier )
                print( TAG, transaction.date )
                -- The reciept to send to GameSparks
                confirmPurchaseWithGameSparks( transaction.receipt, transaction.signature )
                -- On Google, consume purchase if it's not the AdsBundle
                --TODO: move to correct location. should be called after GameSparks says the purchase is valid
                if targetAppStore == "google" and transaction.productIdentifier ~= productIDs[1] then
                    store.consumePurchase( transaction.productIdentifier )
                end
            elseif ( transaction.state == "cancelled" ) then
                -- Handle a cancelled transaction here
                purchaseCallback()
            elseif ( transaction.state == "consumed" ) then
                -- Handle a consumed product here
            end
    
            -- Tell the store that the transaction is complete
            -- If you're providing downloadable content, do not call this until the download has completed
            store.finishTransaction( transaction )
        end
    end
end
 
-- Initialize store
if targetAppStore ~= "none" then
    store.init( transactionListener )
end

------------------------------------Returned Module
local v = {}

v.productIDs = productIDs

v.storeIsAvailable = storeIsAvailable

function v.isStoreAvailable()
    if targetAppStore == "apple" and not store.canMakePurchases and canMakePurchases then
        native.showAlert( "Notice", "In-app purchases are disabled on this device.", { "OK" } )
        canMakePurchases = false
    end
    return storeIsAvailable and canMakePurchases and store.isActive
end

function v.purchase( productID, callback )
    print(TAG, "Attempting to purchse: " .. productID)
    purchaseCallback = callback
    if store ~= nil then
        store.purchase( productID )
    end
end

return v
---------------------------------------------------