-- advertisements.lua

-- Ads order: Vungle -> RevMob -> AdMob

local g = require("globalVariables")
local ads = require( "ads" )
local revmob = require("plugin.revmob")
local applovin = require("plugin.applovin")
local ld = require( "localData" )

local v = {}

v.vungleID = "54bac771691279e35200002b"
v.revmobID = "57327392dd07028f57f29092"
v.admobID = "ca-app-pub-7913549522988958/3001743620"
v.applovinID = "7zf3xb4NouBWUZ8hNLThTrX3LyxCptIxqz_lZ37LxIsPs_6ELaxqPStmOozCeG7TD6CoAK75c-VT-ciKBd8b4_"

if system.getInfo( "platformName " ) == "Android" then
    v.admobID = "ca-app-pub-7913549522988958/7292342428"
    v.revmobID = "57327d77c2da78b748b937fa"
    v.vungleID = "54bac964249050db52000032"
end

v.buttonColor = nil

local recallVungle = false

-------------------------------------------------- FUNCTIONS

local function postAd()
    if v.buttonColor == "red" then
        g.adDone = true
    elseif v.buttonColor == "blue" then
        g.adDone = true
        g.restart()
    elseif v.buttonColor == "yellow" and getsReward then
        ld.addInvincibility( 1 )
        ld.addVideoAdView()
        ld.setVideoAdLastViewTime( os.time( os.date('*t') ) )
        g.getsReward = true
        native.showAlert( "You've earned 1 shield!", "You can view "..(5 - ld.getVideoAdViews()).." more video ads today.", { "Okay" } )
    end
    getsReward = false
end

local function admobListener( event )
    if event.isError then
        
    elseif event.phase == "hidden" then
        
    end
end

local function revmobListener( event )
    if event.isError or event.phase == "failed" then
        native.showAlert( "Unable to show ad. Please check your network connection and try again later.", { "Okay" } )
        getsReward = false
        postAd()
    elseif event.phase == "sessionStarted" then
        
    elseif event.phase == "loaded" then
        revmob.show( v.revmobID ) 
    elseif event.phase == "videoPlaybackBegan" then
        print( "REVMOB" )
    elseif event.phase == "hidden" then
        getsReward = true
        postAd()
    end
end

local function applovinListener( event )
    if event.isError then
        print( "ERROR" )
        revmob.load( "video", { appId = v.revmobID } )
    elseif event.phase == "init" then
        applovin.load()
    elseif event.phase == "playbackBegan" then
        print( "APPLOVIN" )
    elseif event.phase == "hidden" then
        print( "HIDDEN" )
        applovin.load()
        getsReward = true
        postAd()
    end
end

local function vungleListener( event )
    print( "In the listener" )
    if event.isError then

        print( "***RESPONSE*** : " .. event.response )
        applovin.show()

    elseif event.type == "adStart" then
        print( "VUNGLE" )
    elseif event.type == "adEnd" then

        print( "ADD HAS ENDED" )
        getsReward = true
        postAd()
    end
end

function v.showAd()
    if v.buttonColor == "yellow" then
        ads.show( "interstitial", { isAnimated=true, isAutoRotation=true, isBackButtonEnabled=false} )
    elseif g.adWatchCount == 2 then
        ads.show( "interstitial", { isAnimated=true, isAutoRotation=true, isBackButtonEnabled=false } )
        g.adWatchCount = 0
    else 
        g.adWatchCount = g.adWatchCount + 1
        g.adDone = true
        if v.buttonColor == "blue" then
            g.restart()
        end
    end
end

ads.init( "vungle", v.vungleID, vungleListener )
applovin.init( applovinListener, { sdkKey = v.applovinID } )
revmob.init( revmobListener, { appId = v.revmobID } )

return v