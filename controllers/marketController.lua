-------------------------------------------------------------------------------
-- Private Members ------------------------------------------------------------
-------------------------------------------------------------------------------
-- Imports
local cp = require( "composer" )
local ld = require( "data.localData" )
local sd = require( "data.serverData" )
local Alert = require( "views.other.Alert" )
local model = require( "models.marketModel" )
local marketplace = require( "other.Marketplace" )
local Spinner = require( "views.other.Spinner" )

-- View Objects
local TAG = "marketController.lua: "
local areButtonsEnabled
local lineTop
local storeLogo
local buttonGroups
local scrollView
local playfabCatalog
local publisherCatalog = {}
local isShowing
local transitionInButtons
local spinner

-- TODO: switch to false before release
local testing = true

---------------------------------------------------------------------
-- Logic ------------------------------------------------------------
---------------------------------------------------------------------
local function isAdsId(id)
    return id == model.getProductId(1)
end

local function handleAdsBundlePurchase(id)
    --Set ads bundle purchase in local data
    ld.setAdsEnabled(false)
    --Remove ads bundle button
    if isAdsId(id) then
        local entry = buttonGroups[id]
        if not entry then return end

        entry.button:removeSelf()
        entry.button = nil
        entry.priceText:removeSelf()
        entry.priceText = nil
        entry.lifeText:removeSelf()
        entry.lifeText = nil
        entry.shieldText:removeSelf()
        entry.shieldText = nil
        entry.group:remove()
        entry.group = nil

        --Move all other buttons up
        local dy = buttonGroups[4].button.y - buttonGroups[2].button.y
        for k, entry in pairs(buttonGroups) do
            entry.button.y = entry.button.y - dy
            entry.priceText.y = entry.priceText.y - dy
        end
    end
end

local function dimAndDisableButtons()
    for k,v in pairs(buttonGroups) do
        v.displayGroup.alpha = 0.4
        areButtonsEnabled = false
    end
end

local function lightAndEnableButtons()
    for k,v in pairs(buttonGroups) do
        v.displayGroup.alpha = 1
        areButtonsEnabled = true
    end
end

local function createMessageFromItemId(id)
    if not playfabCatalog then return "" end
    for k, product in pairs(playfabCatalog) do
        if product.ItemId == id and product.Bundle and product.Bundle.BundledVirtualCurrencies then
            local message = ""
            if isAdsId(id) then
                message = "All ads have been removed!"
            end
            if product.Bundle.BundledVirtualCurrencies.LF then
                message = message .. "\n+" .. product.Bundle.BundledVirtualCurrencies.LF .. " lives"
            end
            if product.Bundle.BundledVirtualCurrencies.SH then
                message = message .. "\n+" .. product.Bundle.BundledVirtualCurrencies.SH .. " shields"
            end
            --Remove preceding newline character
            if string.sub( message, 1, 1 ) == "\n" then
                message = string.sub( message, 2, string.len( message ) )
            end
            return message
        end
    end
end

local function onValidationSuccess(result)
    for k, fulfillment in pairs(result.Fulfillments) do
        for k, item in pairs(fulfillment.FulfilledItems) do
            local message = createMessageFromItemId(item.ItemId)
            Alert:new( "Purchase Successful!", message, {"OK"})
            handleAdsBundlePurchase(item.ItemId)
        end
    end
end

local function onValidationFailure(result)
    local error = result.error
    local message = result.errorMessage
    Alert:new("Purchase Failed", "Could not validate your purchase", {"OK"})
end

-- 'result' must contain member: status
local function purchaseCallback(result)
    local status = result.status
    if "transactionError" == status then
        Alert:new( "Purchase Failed", "Please check your connection and try again", {"OK"})
    elseif "transactionFailed" == status then
        Alert:new( "Purchase Failed", "Could not complete your purchase", {"OK"})
    elseif "transactionCancelled" == status then
        --do nothing
    elseif "transactionConsumed" == status then
        --do nothing
    elseif "validationError" == status then
        onValidationFailure(result)
    elseif "validationSuccess" == status then
        onValidationSuccess(result)
    end
    lightAndEnableButtons()
end

local function buttonListener(event)
    local phase = event.phase
    local id = event.target.id
    local group = buttonGroups[id].displayGroup

    if not areButtonsEnabled and not testing then -- buttons disabled
        if phase == "moved" then
            scrollView:takeFocus( event )
        end
    else
        if phase == "moved" then
            -- https://docs.coronalabs.com/api/type/ScrollViewWidget/takeFocus.html
            local dy = math.abs( event.y - event.yStart )
            if dy > 10 then
                scrollView:takeFocus( event )
                group.xScale = 1
                group.yScale = 1
            end
        elseif phase == "began" and areButtonsEnabled then
            group.xScale = 0.9
            group.yScale = 0.9
        elseif phase == "ended" and areButtonsEnabled then
            print(TAG, 'button click: '..id)
            group.xScale = 1
            group.yScale = 1
            dimAndDisableButtons()
            marketplace.purchase(id, purchaseCallback)
        end
    end
end

local function didLoadProducts()
    return publisherCatalog and playfabCatalog
end

local function onProductsLoaded()
    if didLoadProducts() and isShowing then
        transitionInButtons()
    end
end

local function getProductInfoFromPublisherCallback(result)
    if result.error then return end
    publisherCatalog = result.products
    for id, productInfo in pairs(publisherCatalog) do
        buttonGroups[id].priceText.text = productInfo.localizedPrice
    end
    onProductsLoaded()
end

local function getProductInfoFromServerCallback(result)
    if result.error then return end
    playfabCatalog = result.Catalog
    for k, product in pairs(playfabCatalog) do
        if product.Bundle and product.Bundle.BundledVirtualCurrencies then
            if isAdsId(product.ItemId) then
                buttonGroups[product.ItemId].lifeText.text = "+"..product.Bundle.BundledVirtualCurrencies.LF
                buttonGroups[product.ItemId].shieldText.text = "+"..product.Bundle.BundledVirtualCurrencies.SH
            else
                if product.Bundle.BundledVirtualCurrencies.LF then
                    buttonGroups[product.ItemId].button:setLabel(product.Bundle.BundledVirtualCurrencies.LF)
                elseif product.Bundle.BundledVirtualCurrencies.SH then
                    buttonGroups[product.ItemId].button:setLabel(product.Bundle.BundledVirtualCurrencies.SH)
                end
            end
        end
    end
    onProductsLoaded()
end

local function sceneShow()
    if marketplace.isStoreAvailable() then
        lightAndEnableButtons()
    else
        timer.performWithDelay(1000, sceneShow)
    end
end

local function showSpinner()
    if not didLoadProducts() then return end
    spinner = spinner or Spinner:new()
    spinner:show(true)
end
---------------------------------------------------------------------
-- Transitions ------------------------------------------------------
---------------------------------------------------------------------
function transitionInButtons()
    if didLoadProducts() then
        if spinner then
            spinner:delete()
        end
        for k,v in pairs(buttonGroups) do
            transition.to( v.displayGroup, {time=350, delay=150, xScale=1, yScale=1, transition=easing.outBack} )
        end
    else
        timer.performWithDelay(500, showSpinner)
    end
end

local function transitionIn()
    transition.to( lineTop, {time=500, strokeWidth=lineTop.strokeWidthIn})
    transition.to( storeLogo, {time=500, x=storeLogo.xIn, transition=easing.outSine})
    transitionInButtons()
end

local function transitionOut()
    local function listener( event )
        cp.gotoScene( "views.scenes.extras" )
    end

    if spinner then
        spinner:delete()
    end
    transition.to( storeLogo, {time=500, x=storeLogo.xOut, transition=easing.inSine})
    transition.to( lineTop, {time=500, strokeWidth=0, onComplete=listener})
    for k,v in pairs(buttonGroups) do
        transition.to( v.displayGroup, {time=350, xScale=0.01, yScale=0.01, transition=easing.inBack} )
    end
end

-------------------------------------------------------------------------------
-- Public Members -------------------------------------------------------------
-------------------------------------------------------------------------------
local v = {}

function v.linkLineTop(viewObject)
    lineTop = viewObject
end

function v.linkLogo(viewObject)
    storeLogo = viewObject
end

function v.linkButtonGroups(viewObjectTable)
    buttonGroups = viewObjectTable
end

function v.linkScrollView(viewObject)
    scrollView = viewObject
end

function v.backArrowListener(event)
    transitionOut()
end

function v.buttonListener(event)
    buttonListener(event)
end

function v.sceneCreateComplete()
    if not publisherCatalog then
        marketplace.getProductInformationFromPublisherStore(getProductInfoFromPublisherCallback)
    else
        getProductInfoFromPublisherCallback({products=publisherCatalog})
    end
    if not playfabCatalog then
        sd.getProductInformationFromServer(getProductInfoFromServerCallback)
    else
        getProductInfoFromServerCallback({Catalog = playfabCatalog})
    end
    dimAndDisableButtons()
end

function v.sceneShow()
    isShowing = true
    transitionIn()
    sceneShow()
end

function v.sceneHide()
    isShowing = false
end

function v.getAdsEnabled()
    ld.getAdsEnabled()
end

function v.getButtonFileName(index)
    return model.getButtonFileName(index)
end

function v.getProductId(index)
    return model.getProductId(index)
end

return v
