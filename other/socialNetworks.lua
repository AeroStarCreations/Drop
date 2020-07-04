--Requires
local g = require("other.globalVariables")
local widget = require("widget")
local GGTwitter = require( "thirdParty.GGTwitter" )
local fonts = require("other.fonts")
local metrics = require("other.metrics")

--Precalls
local TAG = "socialNetworks.lua: "
local CONSUMER_KEY = "C4gwN8bpltRt2N632U6epuQ9Q"
local CONSUMER_SECRET = "UDwrF3kWTpLId9IVr7GN81pQ9Lh5WaM7URygS1G4VRgVpBSkSI"
local TWITTER_URL = "https://twitter.com/Aero_SC"

local twitter

-- Local methods and ops ------------------------------------------------------[
local function showAlert(serviceFormal)
    local message = "You may need to install " .. serviceFormal .. " on your device."
    if "ios" == system.getInfo("platform") then
        message = "You may need to configure " .. serviceFormal .. " in your device settings."
    end
    native.showAlert(
        "Cannot create " .. serviceFormal .. " message",
        message,
        {"OK"}
    )
end

local function showPopup(params)
    if native.canShowPopup("social", params.service) then
        native.showPopup("social", {
                service = params.service,
                message = "I just scored " .. params.score .. " points in Drop – The Vertical Challenge! Can you beat my score? #DropItUp"
                --url = , --TODO: add url for appropriate app store
        })
    else
        showAlert(params.serviceFormal)
    end
end

local function followAscOnTwitter()
    local function onComplete(event)
        if event.action == "clicked" then
            local i = event.index
            if i == 1 then      --"Later"
                --Dialog will dismiss automatically
            elseif i == 2 then  --"Follow"
                twitter:follow("Aero_SC")
            end
        end
    end

    native.showAlert(
        "Follow Aero Star Creations?",
        "Follow @Aero_SC to stay up-to-date on news, sneak peeks, and more.",
        {"Later", "Follow"},
        onComplete
    )
end

local function twitterListener(event)
    if event.phase == "authorized" then
        print(TAG, "SUCCESS: Twitter authorization")
        if twitter.onAuthorized then
            twitter.onAuthorized()
        end
    elseif event.phase == "followed" then
        print(TAG, "SUCCESS: Twitter follow")
        native.showAlert("Thank You!", "You are know following Aero Star Creations (@Aero_SC)", {"OK"})
    elseif event.phase == "failed" then
        print(TAG, "FAILURE: Twitter authorization")
        native.showAlert(
            "Twitter Login",
            "Could not log in to Twitter",
            {"OK"}
        )
    end
end

local function authorizeTwitterThenCompleteAction(action)
    if twitter:isAuthorized() then
        action()
    else
        twitter.onAuthorized = action
        twitter:authorize()
    end
end

local function openAscOnFacebook(displayGroup)
    local facebookView
    local facebookViewListener
    local closeButton
    local buttonHeight = 150

    local function removeAllObjects()
        facebookView:removeEventListener("urlRequest", facebookViewListener)
        facebookView:removeSelf()
        facebookView = nil
        closeButton:removeSelf()
        closeButton = nil
    end

    closeButton =
        widget.newButton {
        parent = displayGroup,
        width = display.contentWidth,
        height = buttonHeight,
        x = display.contentCenterX,
        y = display.contentHeight - 0.5 * buttonHeight,
        onRelease = removeAllObjects,
        label = "Close",
        labelYOffset = 7,
        font = fonts.getRegular(),
        fontSize = 60,
        labelColor = {default = {1, 1, 1}, over = {0.8, 0.8, 1}},
        defaultFile = "images/buttonGreen.png"
    }

    function facebookViewListener(event)
        if event.errorCode then
            removeAllObjects()
        end
        facebookView:removeEventListener("urlRequest", facebookViewListener)
    end

    facebookView =
        native.newWebView(
        display.contentCenterX,
        display.contentCenterY - 0.5 * buttonHeight,
        display.contentWidth,
        display.contentHeight - buttonHeight
    )
    facebookView:request("https://www.facebook.com/AeroStarCreations")
    facebookView:addEventListener("urlRequest", facebookViewListener)
end
-------------------------------------------------------------------------------]

-- Initialization -------------------------------------------------------------]
twitter = GGTwitter:new(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    twitterListener,
    TWITTER_URL
)
-------------------------------------------------------------------------------]

local v = {}

function v.shareResultsOnTwitter(score)
    showPopup({
        score = score,
        service = "twitter",
        serviceFormal = "Twitter"
    })
end

function v.shareResultsOnFacebook(score)
    showPopup({
        score = score,
        service = "facebook",
        serviceFormal = "Facebook"
    })
end

function v.followAscOnTwitter()
    authorizeTwitterThenCompleteAction(followAscOnTwitter)
end

function v.openAscOnFacebook(displayGroup)
    openAscOnFacebook(displayGroup)
end

return v
