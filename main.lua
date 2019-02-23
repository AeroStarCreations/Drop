display.setStatusBar(display.HiddenStatusBar)

local cp = require( "composer" )
local GGData = require( "GGData" )
local g = require( "globalVariables" )
local ads = require( "ads" )
local chartboost = require( "plugin.chartboost" )
local ad = require( "advertisements" )
-- local gn = require( "gameNetworks" )
local json = require( "json" )
local Drop = require( "Drop" )
local ld = require( "localData" )
ld.init( Drop.types )
local bg = require( "backgrounds" )
bg.init()
local sd = require( "serverData" )
sd.init()

system.setAccelerometerInterval( 30 )

--The following variables will be stored.
g.first = GGData:new( "first" )
g.achievement = GGData:new( "achievements" ) --Game Center etc. achievements 
g.leaderboard = GGData:new( "leaderboards" ) --Game Center etc. leaderboards
----------------------------------------

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

g.first.useA = nil

if g.first.useA == nil then --First release!! Add a new function for each release!
    g.first.useA = false
    g.achievement.normalAchievements = {
        { isComplete = false, showBanner = true, id = "drop.mist" },
        { isComplete = false, showBanner = true, id = "drop.doubleMist" },
        { isComplete = false, showBanner = true, id = "drop.drizzle" },
        { isComplete = false, showBanner = true, id = "drop.doubleDrizzle" },
        { isComplete = false, showBanner = true, id = "drop.shower" },
        { isComplete = false, showBanner = true, id = "drop.doubleShower" },
        { isComplete = false, showBanner = true, id = "drop.downpour" },
        { isComplete = false, showBanner = true, id = "drop.doubleDownpour" },
        { isComplete = false, showBanner = true, id = "drop.thunderstorm" },
        { isComplete = false, showBanner = true, id = "drop.doubleThunderstorm" },
        { isComplete = false, showBanner = true, id = "drop.tropicalStorm" },
        { isComplete = false, showBanner = true, id = "drop.doubleTropicalStorm" },
        { isComplete = false, showBanner = true, id = "drop.mistTricky" },
        { isComplete = false, showBanner = true, id = "drop.doubleMistTricky" },
        { isComplete = false, showBanner = true, id = "drop.drizzleTricky" },
        { isComplete = false, showBanner = true, id = "drop.doubleDrizzleTricky" },
        { isComplete = false, showBanner = true, id = "drop.showerTricky" },
        { isComplete = false, showBanner = true, id = "drop.doubleShowerTricky" },
        { isComplete = false, showBanner = true, id = "drop.downpourTricky" },
        { isComplete = false, showBanner = true, id = "drop.doubleDownpourTricky" },
        { isComplete = false, showBanner = true, id = "drop.thunderstormTricky" },
        { isComplete = false, showBanner = true, id = "drop.doubleThunderstormTricky" },
        { isComplete = false, showBanner = true, id = "drop.tropicalStormTricky" },
        { isComplete = false, showBanner = true, id = "drop.doubleTropicalStormTricky" },
        { isComplete = false, showBanner = true, id = "drop.hurricane1" },
        { isComplete = false, showBanner = true, id = "drop.hurricane5" },
        { isComplete = false, showBanner = true, id = "drop.hurricane10" },
        { isComplete = false, showBanner = true, id = "drop.shield5" },
        { isComplete = false, showBanner = true, id = "drop.shield10" },
        { isComplete = false, showBanner = true, id = "drop.shield20" },
        { isComplete = false, showBanner = true, id = "drop.revive1" },
        { isComplete = false, showBanner = true, id = "drop.revive5" },
        { isComplete = false, showBanner = true, id = "drop.revive10" },
        { isComplete = false, showBanner = true, id = "drop.facebook" }, --not complete
    }
    g.achievement.progressAchievements = {
        { isComplete = false, number = 0, possible = 10, id = "drop.play10Games" },
        { isComplete = false, number = 0, possible = 50, id = "drop.play50Games" },
        { isComplete = false, number = 0, possible = 100, id = "drop.play100Games" },
        { isComplete = false, number = 0, possible = 500, id = "drop.500Games" },
        { isComplete = false, number = 0, possible = 1000, id = "drop.1000Games" },
        { isComplete = false, number = 0, possible = 10, id = "drop.dieRed" },
        { isComplete = false, number = 0, possible = 10, id = "drop.dieOrange" },
        { isComplete = false, number = 0, possible = 10, id = "drop.dieYellow" },
        { isComplete = false, number = 0, possible = 10, id = "drop.dieLightGreen" },
        { isComplete = false, number = 0, possible = 10, id = "drop.dieDarkGreen" },
        { isComplete = false, number = 0, possible = 10, id = "drop.dieLightBlue" },
        { isComplete = false, number = 0, possible = 10, id = "drop.dieDarkBlue" },
        { isComplete = false, number = 0, possible = 10, id = "drop.diePink" },
    }
    g.leaderboard.lb = {
        { value = 0, id = "drop.scoreLeaderboardGlobal" },
        { value = 0, id = "drop.timeLeaderboardGlobal" },
        { value = 0, id = "drop.scoreTrickyLeaderboardGlobal" },
        { value = 0, id = "drop.timeTrickyLeaderboardGlobal" },
    }
    
    g.first:save()
    g.achievement:save()
    g.leaderboard:save()
end

-- local gn = require( "gameNetworks" ) -- This is down here because "gameNetworks" 

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

-- gn.login()

--------------------------------------------------------------------------------

----------------------The following takes the user to the first "scene", center.
cp.recycleOnSceneChange = false
cp.loadScene( "center" )
cp.gotoScene( "center" )
------------------------------------------------------------

g.justOpened = true
