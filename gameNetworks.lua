--gameNetworks

local gameNetwork = require( "gameNetwork" )
local g = require( "globalVariables" )

local loggedIntoGN
local normalAchievementsUpdated

local TAG = "gameNetworks:"

local v = {}


function v.checkAndRecord() -------------------------Check if leaderboard stats are correct
    if loggedIntoGN == true then
        for i=1,#g.achievement.normalAchievements do --------------------------\
            if g.achievement.normalAchievements[i].isComplete == true then --Is achievement complete?
                gameNetwork.request( "unlockAchievement",
                {
                    achievement =
                    {
                        identifier = g.achievement.normalAchievements[i].id,
                        showsCompletionBanner = g.achievement.normalAchievements[i].showBanner
                    }
                }
                )
                print( "showsCompletionBanner = "..tostring(g.achievement.normalAchievements[i].showBanner))
                g.achievement.normalAchievements[i].isComplete = false
                g.achievement.normalAchievements[i].showBanner = false
                g.achievement:save()
                normalAchievementsUpdated = true
            end
        end 
        if normalAchievementsUpdated == true then
            normalAchievementsUpdated = false
        end -------------------------------------------------------------------/
        
        
        for i=1,#g.achievement.progressAchievements do ------------------------\
            if g.achievement.progressAchievements[i].isComplete == false then
                local x = g.achievement.progressAchievements[i].number
                local y = g.achievement.progressAchievements[i].possible
                local pc = math.round( 100*(x/y) ) --pc means percent complete
                print(pc)
                if pc >= 100 then
                    pc = 100
                    g.achievement.progressAchievements[i].isComplete = true
                    g.achievement:save()
                end
                gameNetwork.request( "unlockAchievement",
                {
                    achievement = 
                    {
                        identifier = g.achievement.progressAchievements[i].id,
                        percentComplete = pc,
                        showsCompletionBanner = true
                    }
                } )
            end
        end -------------------------------------------------------------------/
        
        local function leaderboardCallback( event )
            if event.type == "setHighScore" then
                testText.text = testText.text .. " - high score set"
            end
        end

        for i=1,#g.leaderboard.lb do ------------------------------------------\
            gameNetwork.request( "setHighScore",
            {
                localPlayerScore = 
                { 
                    category = g.leaderboard.lb[i].id, 
                    value = g.leaderboard.lb[i].value
                },
                listener = leaderboardCallback
            }
            )
        end ----------------------------------------------------------/
    end
end


--------------------------------------------------------------------------------
---------------------------------------------------------------------------Login
--------------------------------------------------------------------------------
local function loadPlayerRequestCallback( event )
    local playerID = event.data.playerID
    local playerAlias = event.data.alias
    testText.text = testText.text .. " - " .. playerID .. " - " .. playerAlias
    print(TAG, playerID.." : "..playerAlias)
end

local function gameNetworkLoginCallback( event )
    if event.data then
        testText.text = testText.text .. " - login success"
        print(TAG, "login success")
        loggedIntoGN = true
        gameNetwork.request( "loadLocalPlayer", { listener=loadPlayerRequestCallback } )
        v.checkAndRecord()
    else
        testText.text = testText.text .. " - login fail"
        print(TAG, "login failure")
        loggedIntoGN = false
    end
    return true
end

function v.login()
    gameNetwork.init( g.networkType, gameNetworkLoginCallback )
    testText.text = testText.text .. " - login called"
    print(TAG, "login called")
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



return v

