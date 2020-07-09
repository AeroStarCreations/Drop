--Requires
local cp = require( "composer" )
local g = require( "other.globalVariables" )
local Drop = require( "views.other.Drop" )
local ld = require( "data.localData" )
local bg = require( "controllers.backgroundController" )
local sd = require( "data.serverData" )
local ads = require( "other.advertisements2" )
local highScores = require( "data.highScores" )
local metrics = require( "other.metrics" )

-- App Configuration ---------------------------------------------------------[
display.setStatusBar(display.HiddenStatusBar)
system.setAccelerometerInterval(30)
audio.setVolume( ld.getVolume() or 0.8 )
g.getsReward = false
g.adWatchCount = 0
g.adDone = false
g.justOpened = true
if system.getInfo( "platform" ) == "android" then
    g.platformType = "Android"
    g.networkType = "google"
elseif system.getInfo("platform") == "ios" then
    g.platformType = "Apple"
    g.networkType = "gamecenter"
end
------------------------------------------------------------------------------]

-- Initializations -----------------------------------------------------------[
local function loginCallback( result )
    --get high scores
    if result.error then return end
    sd.getAllLeaderboardValues(highScores.storeHighScoresFromServer)
    --get stats?
end

ld.init(Drop.types)
bg.init()
ads.init()
------------------------------------------------------------------------------]

-- Go to first scene ---------------------------------------------------------[
cp.recycleOnSceneChange = false
cp.gotoScene( "views.scenes.center" )
------------------------------------------------------------------------------]

-- Application Events --------------------------------------------------------[
local function onSystemEvent( event )
    if event.type == "applicationStart" then
        sd.init(loginCallback)
    elseif event.type == "applicationResume" then
        print("APPLICATION RESUME")
    elseif event.type == "applicationSuspend" then
        print("APPLICATION SUSPEND")
    end
end

Runtime:addEventListener( "system", onSystemEvent )
------------------------------------------------------------------------------]
