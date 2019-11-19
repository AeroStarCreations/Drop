------------------------------------------------------------------
-- gameFunctions
--
-- This file contains functions called in the game scene.
--
-- Nathan Balli
------------------------------------------------------------------

local GGData = require( "utilities.GGData" )
local g = require( "globalVariables" )
local gn = require( "gameNetworks" )
local ld = require( "localData" )

-- LIST OF FUNCTIONS:
--
-- records
-- clearDrops
-- socialListener

local v = {}

----------------------------------------------------------------------------
-- Checks the stats from the game and updates records where appropriate   --
----------------------------------------------------------------------------
v.records = function( score, totalTime, hurricaneTime, shield, revive, colorDeathsTable )
        if ld.getSpecialDropsEnabled() then -- this function sets high scores and times
            if score > g.leaderboard.lb[1].value then
                g.leaderboard.lb[1].value = score
            end
            if totalTime > g.leaderboard.lb[2].value then
                g.leaderboard.lb[2].value = totalTime
            end
        else
            if score > g.leaderboard.lb[3].value then
                g.leaderboard.lb[3].value = score
            end
            if totalTime > g.leaderboard.lb[4].value then
                g.leaderboard.lb[4].value = totalTime
            end
        end
        if hurricaneTime > 0 then -- this function / loop watches for hurricane achievements
            for i=1,3 do
                if hurricaneTime >= i then
                    g.achievement.normalAchievements[24+i].isComplete = true
                end
            end
        end
        for i=0,2 do -- this loop watches for shield achievements
            if shield >= 2.5*(i^2+i+2) then--simplified quadratic formula ax^2+bx+c
                g.achievement.normalAchievements[28+i].isComplete = true
            end
        end
        for i=0,2 do -- this loop watches for revive achievements
            if revive >= 0.5*(i^2+7*i+2) then
                g.achievement.normalAchievements[31+i].isComplete = true
            end
        end
        for i=1,5 do -- this loop adjusts the number-of-games-played achievements
            if g.achievement.progressAchievements[i].isComplete == false then
                g.achievement.progressAchievements[i].number = ld.getGamesPlayed()
            end
        end
        -- local colorDeathsTable = {
        --     [6] = g.stats.redD,
        --     [7] = g.stats.orangeD,
        --     [8] = g.stats.yellowD,
        --     [9] = g.stats.lightGreenD,
        --     [10] = g.stats.darkGreenD,
        --     [11] = g.stats.lightBlueD,
        --     [12] = g.stats.darkBlueD,
        --     [13] = g.stats.pinkD,
        -- }
        local colorDeathsTable = {
            [6] = 0,
            [7] = 0,
            [8] = 0,
            [9] = 0,
            [10] = 0,
            [11] = 0,
            [12] = 0,
            [13] = 0,
        }
        for i=6,13 do -- this loop adjusts the death-by-color achievements
            if g.achievement.progressAchievements[i].isComplete == false then
                g.achievement.progressAchievements[i].number = colorDeathsTable[i]
            end
        end
        
        g.leaderboard:save()
        gn.checkAndRecord()
    end
    ----------------------------------------------------------------------------


    ----------------------------------------------------------------------------
    -- Clears all the active drops from the screen and sets them to nill      --
    ----------------------------------------------------------------------------
    v.clearDrops = function( dropsGroup )
        local function listener( obj ) --remove drops
            display.remove( obj )
            obj = nil
        end
        for i = 1, dropsGroup.numChildren do
            transition.to( dropsGroup[i], { 
                time = 80, 
                alpha = 0, 
                width = dropsGroup[i].width*2,
                height = dropsGroup[i].height*2,
                onComplete = listener,
            } )
        end
    end
    ----------------------------------------------------------------------------


    ----------------------------------------------------------------------------
    -- Produces the correct game-over social popup message                    --
    ----------------------------------------------------------------------------
    v.socialListener = function( event )
        
        local serviceName = event.target.id
        
        local isAvailable = native.canShowPopup( "social", serviceName )
        
        if isAvailable then
            
            native.showPopup( "social", 
            {
                service = serviceName,
                message = "I just dropped"..sText2.text.." points with a time of"..tText2.text.." in Drop - The Vertical Challenge! Check it out on the App Store!",
                --url = ,
            })
            
        else
            
            local bob
            if serviceName == "twitter" then
                bob = "Twitter"
            else
                bob = "Facebook"
            end
            
            native.showAlert(
                "Could not send "..bob.." message.",
                "Please setup your "..bob.." account or check your network connection.",
                { "OK" } )
            
        end
        
    end
    ----------------------------------------------------------------------------



    

return v
