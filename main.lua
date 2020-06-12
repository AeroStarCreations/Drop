--Requires
local cp = require( "composer" )
local g = require( "other.globalVariables" )
local Drop = require( "views.other.Drop" )
local ld = require( "data.localData" )
local bg = require( "controllers.backgroundController" )
local sd = require( "data.serverData" )
local ads = require( "other.advertisements2" )
local highScores = require( "data.highScores" )

-- App Configuration ---------------------------------------------------------[
display.setStatusBar(display.HiddenStatusBar)
system.setAccelerometerInterval(30)
audio.setVolume( ld.getVolume() )
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
local function loginCallback( values )
    --get high scores
    sd.getAllLeaderboardValues(highScores.storeHighScoresFromServer)
    --get stats?
end

sd.init(loginCallback)
ld.init(Drop.types)
bg.init()
ads.init()
------------------------------------------------------------------------------]

-- Go to first scene ---------------------------------------------------------[
cp.recycleOnSceneChange = false
cp.gotoScene( "views.scenes.center" )
------------------------------------------------------------------------------]

