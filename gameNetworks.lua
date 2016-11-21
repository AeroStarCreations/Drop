--gameNetworks

local gameNetwork = require( "gameNetwork" )
local g = require( "globalVariables" )

local loggedIntoGC
local normalAchievementsUpdated

local v = {}


function v.checkAndRecord() -------------------------Check if leaderboard stats are correct
    if loggedIntoGC == true then
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
        if normalAchievementsUpdated == true then --decreases parse mod calls
            --sc.updateNormalAchievements()
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
                --sc.updateProgressAchievements()
            end
        end -------------------------------------------------------------------/
        
        for i=1,#g.leaderboard.lb do ------------------------------------------\
            gameNetwork.request( "setHighScore",
            {
                localPlayerScore = 
                { 
                    category = g.leaderboard.lb[i].id, 
                    value = g.leaderboard.lb[i].value
                }
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
    print( playerID, playerAlias )
end

local function gameCenterLoginCallback( event )
    if event.data then
        loggedIntoGC = true
        gameNetwork.request( "loadLocalPlayer", { listener=loadPlayerRequestCallback } )
        v.checkAndRecord()
        print("*************************************************")
    else
        loggedIntoGC = false
    end
    return true
end

function v.login()
    gameNetwork.init( g.networkType, gameCenterLoginCallback )
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



return v

