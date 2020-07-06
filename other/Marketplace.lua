local sd = require( "data.serverData" )
local json = require( "json" )
local model = require( "models.marketModel" )

-- Precalls ------------------------------------------------------------------[
local TAG = "Marketplace.lua: "
local store
local storeIsAvailable = true
local purchaseCallback
local getProductInfoCallback
local targetAppStore
local products
local latestTransaction

------------------------------------------------------------------------------]
local function validateReceiptCallback(result)
    if result.error then
        result.status = "validationError"
    else
        result.status = "validationSuccess"
         -- On Google, consume purchase if it's not the AdsBundle
        if targetAppStore == "google" and latestTransaction.productIdentifier ~= model.getProductId(1) then
            store.consumePurchase( latestTransaction.productIdentifier )
        end
        -- Tell the store that the transaction is complete
        -- If you're providing downloadable content, do not call this until the download has completed
        store.finishTransaction(latestTransaction)
    end
    purchaseCallback(result)
end

local function validatePurchaseReceipt()
    local receipt = latestTransaction.receipt
    local signature = latestTransaction.signature
    local id = latestTransaction.productIdentifier
    local currencyCode = products[id].priceLocale
    local purchasePrice = products[id].priceCentesimal
    if targetAppStore == "google" then
        sd.validateGoogleReceipt(currencyCode, purchasePrice, receipt, signature, validateReceiptCallback)
    elseif targetAppStore == "apple" then
        sd.validateAppleReceipt(currencyCode, purchasePrice, receipt, validateReceiptCallback)
    end
end

local function transactionListener( event )
    local transaction = event.transaction
 
    if event.name == "init" then -- Google IAP initialization event (Apple doesn't use this)
        if transaction.isError then 
            -- Unsuccessful initialization; output error details
            print(TAG, "Store initialization error")
            print(TAG, transaction.errorType)
            print(TAG, transaction.errorString)
        else
            -- Perform steps to enable IAP, load products, etc.
            -- store.isActive will be 'true' at this point
        end
    else
        if transaction.isError then -- Failed transation
            print(TAG, "Store transaction error")
            print(TAG, transaction.errorType )
            print(TAG, transaction.errorString )
            purchaseCallback({status = "transactionError"})
        else -- Successful transaction
            if event.transaction.state ~= "failed" then  -- Successful transaction
                print( TAG, json.prettify( event ) )
                print( TAG, "event.transaction: " .. json.prettify( transaction ) )
            else  -- Unsuccessful transaction; output error details
                print( TAG, transaction.errorType )
                print( TAG, transaction.errorString )
                purchaseCallback({status = "transactionFailed"})
            end

            if transaction.state == "purchased" or transaction.state == "restored" then
                -- Handle a normal purchase or restored purchase here
                print( TAG, transaction.state )
                print( TAG, transaction.productIdentifier )
                print( TAG, transaction.date )
                -- The receipt to send to PlayFab
                latestTransaction = transaction
                validatePurchaseReceipt()
            elseif ( transaction.state == "cancelled" ) then
                -- Handle a cancelled transaction here
                purchaseCallback({status = "transactionCancelled"})
            elseif ( transaction.state == "consumed" ) then
                -- Handle a consumed product here
                purchaseCallback({status = "transactionConsumed"})
            end
        end
    end
end

local function getCentesimalPrice(formattedPrice)
    return string.gsub(formattedPrice, "%D+", "")
end

-- This method creates a table where the keys are product IDs and
-- the values are tables with the localized price, price locale,
-- and centesimal price
local function loadProductsListener(event)
    print(TAG, "loadProductsListener event", json.prettify(event))
    local result = {}
    result.products = {}
    result.error = #event.products == 0
    for k, product in pairs(event.products) do
        result.products[product.productIdentifier] = {
            localizedPrice = product.localizedPrice,
            priceLocale = product.priceLocale,
            priceCentesimal = getCentesimalPrice(product.priceLocale)
        }
    end
    getProductInfoCallback(result)
end

-- Initialization ------------------------------------------------------------[
targetAppStore = system.getInfo("targetAppStore")

if ( "apple" == targetAppStore ) then  -- iOS
    store = require( "store" )
    store.init( transactionListener )
elseif ( "google" == targetAppStore ) then  -- Android
    store = require( "plugin.google.iap.v3" )
    store.init( transactionListener )
else
    print( "In-app purchases are not available for this platform." )
    storeIsAvailable = false
    native.showAlert( "Uh-oh", "In-app purchases are not supported on this device.", { "OK" } )
end
------------------------------------------------------------------------------]

-- Public Members ------------------------------------------------------------[
local v = {}

v.storeIsAvailable = storeIsAvailable

function v.isStoreAvailable()
    return store and storeIsAvailable and store.isActive
end

-- Passes the result of receipt validation to 'callback'
function v.purchase( productID, callback )
    print(TAG, "Attempting to purchase: " .. productID)
    purchaseCallback = callback
    if v.isStoreAvailable() then
        store.purchase( productID )
    end
end

function v.getProductInformationFromPublisherStore(callback)
    if v.isStoreAvailable() and store.canLoadProducts then
        getProductInfoCallback = callback
        store.loadProducts(model.getProductIds(), loadProductsListener)
    end
end

return v
------------------------------------------------------------------------------]
