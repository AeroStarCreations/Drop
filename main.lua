--require "CiderDebugger";

-- TEST

display.setStatusBar(display.HiddenStatusBar)

local cp = require( "composer" )
local GGData = require( "GGData" )
local g = require( "globalVariables" )
local ads = require( "ads" )
local chartboost = require( "plugin.chartboost" )
local ad = require( "advertisements" )
local gn = require( "gameNetworks" )


jack = display.newText( " ", display.contentCenterX, display.contentCenterY+150, display.contentWidth, display.contentHeight, g.comBold, 70)
jack:setFillColor( 0, 0, 0 )


system.setAccelerometerInterval( 30 )

--The following variables will be stored.
g.first = GGData:new( "first" )
g.gameSettings = GGData:new( "settings" )
g.buy = GGData:new( "purchases" )
g.stats = GGData:new( "stats" )
g.achievement = GGData:new( "achievements" ) --Game Center etc. achievements 
g.leaderboard = GGData:new( "leaderboards" ) --Game Center etc. leaderboards
----------------------------------------

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
    audio.setVolume( 0.8 )
    g.gameSettings.volume = 0.8
    g.gameSettings.bgChange = true
    g.gameSettings.specials = true
    g.gameSettings.sensitivity = 3
    g.gameSettings.tilt = true
    g.buy.invincibility = 999999
    g.buy.lives = 999999
    g.buy.ads = false
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
    g.stats.videoAd = { day=os.date("%j"), views=0, lastViewTime=0 }
    g.stats.red = 0 --survived read
    g.stats.redD = 0 --dead by red
    g.stats.orange = 0
    g.stats.orangeD = 0
    g.stats.yellow = 0
    g.stats.yellowD = 0
    g.stats.lightGreen = 0
    g.stats.lightGreenD = 0
    g.stats.darkGreen = 0
    g.stats.darkGreenD = 0
    g.stats.lightBlue = 0
    g.stats.lightBlueD = 0
    g.stats.darkBlue = 0
    g.stats.darkBlueD = 0
    g.stats.pink = 0
    g.stats.pinkD = 0
    g.stats.red2 = 0 --got red special
    g.stats.orange2 = 0
    g.stats.yellow2 = 0
    g.stats.lightGreen2 = 0
    g.stats.darkGreen2 = 0
    g.stats.lightBlue2 = 0
    g.stats.darkBlue2 = 0
    g.stats.pink2 = 0
    g.stats.red3 = 0 --missed red special
    g.stats.orange3 = 0
    g.stats.yellow3 = 0
    g.stats.lightGreen3 = 0
    g.stats.darkGreen3 = 0
    g.stats.lightBlue3 = 0
    g.stats.darkBlue3 = 0
    g.stats.pink3 = 0
    g.stats.numGames = 0
    g.stats.deaths = 0
    g.stats.invinces = 0
    g.stats.revives = 0
    g.first:save()
    g.gameSettings:save()
    g.buy:save()
    g.stats:save()
    g.achievement:save()
    g.leaderboard:save()
    --parse:logEvent( "Downloads", { ["screen"] = g.platformType } )
end

audio.setVolume (g.gameSettings.volume )

local gn = require( "gameNetworks" ) --This is down here because "gameNetworks" 
--uses "g." variables which are not created until above

----------------------The following creates and organizes the background images.
local bgImages = {
    [1] = "images/bg.png",
    [2] = "images/bg2.png",
    [3] = "images/bg3.png",
    [4] = "images/bg4.png",
    [5] = "images/bg5.png",
    [6] = "images/bg6.png",
    [7] = "images/bg7.png",
}

g.bg = {}

g.bgGroup = display.newGroup()
g.bgGroup.anchorX, g.bgGroup.anchorY = 0, 0
g.bgGroup:toBack()

for i = 1,7 do 
    g.bg[i] = display.newImageRect( g.bgGroup, bgImages[i], 1000, 1500 )
    g.bg[i].anchorX, g.bg[i].anchorY = 0, 0
    g.bg[i].alpha = 0
end

g.bg[1].alpha = 1
-------------------------------------------------------------

-- counts when the next ad should be displayed
g.getsReward = false
g.adWatchCount = 0
g.adDone = false

--------------------------------------------------------------------------------

gn.login()

--------------------------------------------------------------------------------

----------------------The following takes the user to the first "scene", center.
cp.recycleOnSceneChange = false
cp.loadScene( "center" )
cp.gotoScene( "center" )
------------------------------------------------------------

g.justOpened = true
