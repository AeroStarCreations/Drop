display.setStatusBar(display.HiddenStatusBar)

local cp = require( "composer" )
local GGData = require( "utilities.GGData" )
local g = require( "globalVariables" )
-- local ads = require( "ads" )
-- local chartboost = require( "plugin.chartboost" )
-- local ad = require( "advertisements" )
-- local gn = require( "gameNetworks" )
local json = require( "json" )
local Drop = require( "objects.Drop" )
local ld = require( "localData" )
ld.init( Drop.types )
local bg = require( "controllers.backgroundController" )
bg.init()
local sd = require( "serverData" )
sd.init()
local achieve = require( "achievements" )
achieve.init()
local highScores = require( "highScores" )
highScores.init()
local ads = require( "advertisements2" )
ads.init()

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

--------------------------------------------------------------------------------

----------------------The following takes the user to the first "scene", center.
cp.recycleOnSceneChange = false
cp.gotoScene( "views.scenes.center" )
------------------------------------------------------------

g.justOpened = true
