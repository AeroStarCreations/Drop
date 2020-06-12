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

--TODO: provide billing info on appodeal.com

local appodeal = require( "plugin.appodeal" )
local ld = require( "data.localData" )
local colors = require( "other.colors" )
local Spinner = require("views.other.Spinner")

local platformName = system.getInfo( "platform" )
local TAG = "advertisements2.lua: "
local gamesBetweenAds = 2
local gamesPlayed = 0
local appKey
local isRewarded
local onCompleteListener
-- Timer
local loadWaitTime = 5000
local timerIterationDuration = 100
local timerIterations = loadWaitTime / timerIterationDuration
local adTimer
-- Spinner
local spinner

if platformName == "ios" then
    --TODO: this is the Drop Testing key. Switch for the non-testing key
    appKey = "90fd4f1ec310a6898d57032199061bbb2b34bf57c8d81c7a"
elseif platformName == "android" then
    appKey = "9f72f301cd38796f7996457c9cab7372ce815fa740b99cd4"
end

local function showAlert()
    local message = "Unable to show ad. Please check your network connection."
    if isRewarded then
        message = "Unable to show ad. Please check your network connection and try again."
    end
    native.showAlert( "Oops!", message, { "Okay" } )
end

-- Returns true if the ad is loaded, false otherwise
local function showRewardedVideoIfLoaded()
    --TODO: remove outer environment condition
    if system.getInfo("environment") == "device" and appodeal.isLoaded("rewardedVideo") then
        appodeal.show( "rewardedVideo" )
        return true
    end
    return false
end

local function timerListener( event )
    if showRewardedVideoIfLoaded() then
        timer.cancel( adTimer )
    elseif event.count == timerIterations then
        spinner:delete()
        showAlert()
    end
end

local function startTimerForAd()
    if not showRewardedVideoIfLoaded() then
        spinner = spinner or Spinner:new(true)
        spinner:show()
        adTimer = timer.performWithDelay( timerIterationDuration, timerListener, timerIterations )
    end
end

local function handleAdCompletion( playbackEnded )
    if playbackEnded and isRewarded then
        ld.addInvincibility( 1 )
        ld.addVideoAdView()
        ld.setVideoAdLastViewTime()
        native.showAlert( "You've earned 1 shield!", "You can view "..(5 - ld.getVideoAdViews()).." more video ads today.", { "Okay" } )
    end
    if onCompleteListener ~= nil then 
        onCompleteListener() 
    end
end

local function adListener( event )
    local phase = event.phase
    print(TAG .. "adListener event.phase: " .. phase)

    if phase == "init" then

    elseif phase == "loaded" then

    elseif phase == "displayed" then

    elseif phase == "clicked" then

    elseif phase == "failed" then
        showAlert()
        -- destroyBackground()
    elseif phase == "playbackBegan" then

    elseif phase == "playbackEnded" then
        -- destroyBackground()
        handleAdCompletion( true )
    elseif phase == "closed" then
        -- destroyBackground()
        handleAdCompletion( false )
    elseif phase == "dataReceived" then

    end
end

local v = {}

-- adIsRewarded indicates the an award should be given at the end of the ad
-- listener is the function to call at the end of the process
function v.show( adIsRewarded, listener )
    isRewarded = adIsRewarded
    onCompleteListener = listener

    -- Ads are shown either for a reward or after a game is completed
    if isRewarded then
        startTimerForAd()
        return true
    else
        gamesPlayed = gamesPlayed + 1
    end

    if gamesPlayed >= gamesBetweenAds then
        startTimerForAd()
        gamesPlayed = 0
    elseif listener ~= nil then
        listener()
    end
end

function v.init()
    --TODO: set testMode to false before deploying
    appodeal.init( adListener, {
        appKey = appKey,
        testMode = true
    })
end

return v
