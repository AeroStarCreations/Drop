-- Best paying according to Google searches
-- 1) AdMob*
-- 3) Unity Ads*
-- 2) Chartboost*
-- 4) AppLovin*
-- 5) AdColony*
-- 6) Supersonic*
-- 7) Appnext*
-- 8) Vungle*
--
-- *has rewarded video

-- THIS MODULE USES APPODEAL
-- Appodeal loads ads automatically in the background

--TODO: provide billing info on appodeal.com

local appodeal = require("plugin.appodeal")
local ld = require("data.localData")
local metrics = require("other.metrics")
local Spinner = require("views.other.Spinner")
local TimerBank = require("other.TimerBank"):new()

--TODO: set testMode to false before deploying
local IS_TEST_MODE = true
local TAG = "advertisements2.lua: "
local PLATFORM = system.getInfo("platform")
--TODO: this is the Drop Testing key. Switch for the non-testing key
local IOS_APP_KEY = "90fd4f1ec310a6898d57032199061bbb2b34bf57c8d81c7a"
local ANDROID_APP_KEY = "9f72f301cd38796f7996457c9cab7372ce815fa740b99cd4"

local gamesBetweenAds = 2
local gamesPlayed = 0
local isRewarded
local onCompleteListener
local loadWaitTime = 5000
local timerDuration = 100
local timerIterations = loadWaitTime / timerDuration
local adTimer
local spinner

-- Private Members ------------------------------------------------------------[
local function callOnCompleteListener()
    if onCompleteListener then
        onCompleteListener()
    end
end

local function showAlert()
    local message = "Unable to show ad. Please check your network connection."
    if isRewarded then
        message = "Unable to show ad. Please check your network connection and try again."
    end
    native.showAlert("Bummer.", message, {"Okay"}, callOnCompleteListener)
end

local function cleanUp()
    TimerBank:cancel(adTimer)
    if spinner then
        spinner:delete()
    end
end

local function canShowAd()
    return appodeal.canShow("rewardedVideo")
end

local function showAd()
    appodeal.show("rewardedVideo")
end

local function timerListener(event)
    if canShowAd() then
        metrics.stopTimedEvent("ads_load_wait", { isFailure = false })
        showAd()
        cleanUp()
    elseif event.count == timerIterations then
        metrics.stopTimedEvent("ads_load_wait", { isFailure = true })
        cleanUp()
        showAlert()
    end
end

local function startTimerForAd()
    spinner = spinner or Spinner:new(true)
    spinner:show()
    adTimer = TimerBank:createTimer(timerDuration, timerListener, timerIterations)
    metrics.startTimedEvent("ads_load_wait")
end

local function showAdOrWaitForLoad(isRewarded, callback)
    if canShowAd() then
        showAd()
    else
        startTimerForAd()
    end
end

local function initiateShowAd()
    if isRewarded then
        showAdOrWaitForLoad()
    else
        gamesPlayed = gamesPlayed + 1
        if gamesPlayed >= gamesBetweenAds then
            gamesPlayed = 0
            showAdOrWaitForLoad()
        else
            callOnCompleteListener()
        end
    end
    metrics.logEvent("ads_request", { isRewarded = isRewarded })
end

local function handleAdCompletion(playbackEnded)
    if playbackEnded and isRewarded then
        ld.addInvincibility(1)
        ld.addVideoAdView()
        ld.setVideoAdLastViewTime()
        native.showAlert(
            "You've earned 1 shield!",
            "You can view " .. (3 - ld.getVideoAdViews()) .. " more video ads today.",
            {"Okay"},
            callOnCompleteListener
        )
    else
        callOnCompleteListener()
    end
end

local function adListener(event)
    local phase = event.phase
    print(TAG, "Appodeal phase: " .. phase)

    if phase == "init" then
    elseif phase == "loaded" then
    elseif phase == "displayed" then
    elseif phase == "clicked" then
    elseif phase == "failed" then
        cleanUp()
        showAlert()
    elseif phase == "playbackBegan" then
    elseif phase == "playbackEnded" then
        handleAdCompletion(true)
    elseif phase == "closed" then
        handleAdCompletion(false)
    elseif phase == "dataReceived" then
    end

    metrics.logEvent("ads_"..phase)
end

-- Initialization -------------------------------------------------------------[
local function init()
    local appKey = (PLATFORM == "ios" and IOS_APP_KEY) or ANDROID_APP_KEY
    appodeal.init(
        adListener,
        {
            appKey = appKey,
            testMode = IS_TEST_MODE,
            supportedAdTypes = {"rewardedVideo"}
        }
    )
end

-- Public Members -------------------------------------------------------------[
local v = {}

function v.showRewardedAd(callback)
    isRewarded = true
    onCompleteListener = callback
    initiateShowAd()
end

function v.showNormalAd(callback)
    isRewarded = false
    onCompleteListener = callback
    initiateShowAd()
end

function v.init()
    init()
end

return v
