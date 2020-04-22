display.setStatusBar(display.HiddenStatusBar)

local cp = require( "composer" )
local GGData = require( "thirdParty.GGData" )
local g = require( "other.globalVariables" )
-- local ads = require( "ads" )
-- local chartboost = require( "plugin.chartboost" )
-- local ad = require( "advertisements" )
-- local gn = require( "other.gameNetworks" )
local json = require( "json" )
local Drop = require( "views.other.Drop" )
local ld = require( "data.localData" )
ld.init( Drop.types )
local bg = require( "controllers.backgroundController" )
bg.init()
local sd = require( "data.serverDataOld" )
sd.init()
local sdNew = require( "data.serverData" )
local achieve = require( "data.achievements" )
achieve.init()
local ads = require( "other.advertisements2" )
ads.init()
local highScores = require( "data.highScores" )

system.setAccelerometerInterval( 30 )

-- Set audio volume ----------------
audio.setVolume( ld.getVolume() )
------------------------------------

if system.getInfo( "platformName" ) == "Android" then
    g.platformType = "Android"
    g.networkType = "google"
else
    g.platformType = "Apple"
    g.networkType = "gamecenter"
end

-- counts when the next ad should be displayed
g.getsReward = false
g.adWatchCount = 0
g.adDone = false

--------------------------------------------------------------------------------

testText = display.newText( "", display.contentCenterX, display.contentCenterY, display.contentWidth-10, display.contentHeight-10, native.systemFont, 40)
testText:toFront();
testText:setFillColor(0,0,0)
-- testText.alpha = 0

--------------------------------------------------------------------------------

local function loginCallback( values )
    --set display name
    sdNew.setDisplayName(values.InfoResultPayload.AccountInfo.TitleInfo.DisplayName)
    --get high scores
    sdNew.getAllLeaderboardValues(highScores.storeHighScoresFromServer)
    --get stats
end

sdNew.init(loginCallback)

--------------------------------------------------------------------------------

----------------------The following takes the user to the first "scene", center.
cp.recycleOnSceneChange = false
cp.gotoScene( "views.scenes.center" )
------------------------------------------------------------

g.justOpened = true
