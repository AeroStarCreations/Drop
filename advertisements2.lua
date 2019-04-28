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

local appodeal = require( "plugin.appodeal" )
local ld = require( "localData" )
local colors = require( "colors" )
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
local background
local spinners = {}
local spinnerTransitions = {}

if platform == "ios" then
    --TODO: assign to actual iOS key
    appKey = "iOS key"
elseif platformName == "android" then
    --TODO: assign to actual Android key
    appKey = "Android key"
end

local function showAlert()
    local message = "Unable to show ad. Please check your network connection."
    if isRewarded then
        message = "Unable to show ad. Please check your network connection and try again."
    end
    native.showAlert( "Oops", message, { "Okay" } )
end

local function blockTouchListener()
    return true
end

local function showBackground()
    background = display.newRect( display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
    background:setFillColor( 0, 0, 0, 0.6 )
    background:addEventListener( "touch", blockTouchListener)
end

local function destroyBackground()
    background:removeEventListener( "touch", blockTouchListener)
    background:removeSelf()
    background = nil
end

local function showSpinner()
    local times = { 1000, 1000, 800, 800 }
    local rotations = { 180, -180, 180, -180 }
    for i=1, 4 do
        spinners[i] = display.newRoundedRect( display.contentCenterX, display.contentCenterY, 120, 20, 10 )
        spinners[i]:setFillColor( unpack(colors.purple_l) )
        spinnerTransitions[i] = transition.to( spinners[i], {
            time = times[i],
            iterations = -1,
            rotation = spinners[i].rotation + rotations[i]
        })
    end
end

local function destroySpinner()
    for i=1, #spinners do
        transition.cancel( spinnerTransitions[i] )
        spinners[i]:removeSelf()
        spinners[i] = nil
    end
end

local function timerListener( event )
    --TODO: remove outer environment condition
    if ( system.getInfo( "environment" ) == "device" ) then
        if appodeal.isLoaded( "rewardedVideo" ) then
            timer.cancel( adTimer )
            appodeal.show( "rewardedVideo" )
        end
    end
    if event ~= nil and event.count == timerIterations then -- the timer is done
        destroySpinner()
        destroyBackground()
        showAlert()
    end
end

local function startTimerForAd()
    showSpinner()
    showBackground()
    timerListener()
    adTimer = timer.performWithDelay( timerIterationDuration, timerListener, timerIterations )
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
        destroyBackground()
    elseif phase == "playbackBegan" then

    elseif phase == "playbackEnded" then
        destroyBackground()
        handleAdCompletion( true )
    elseif phase == "closed" then
        destroyBackground()
        handleAdCompletion( false )
    elseif phase == "dataReceived" then

    end
end

--TODO: set testMode to false before deploying
appodeal.init( adListener, { appKey=appKey, testMode=true } )

local v = {}

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

return v
