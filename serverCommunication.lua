-- Server Communication 

local parse = require( "mod_parse" )
local GGData = require( "utilities.GGData" )
local g = require( "globalVariables" )

local v = {}

function v.login( id, alias, networkName )
    --password and username are the gamenetwork ID b/c that never changes
    local PASSWORD = tostring(id)
    local ID = "id"..PASSWORD
    local dataTable = { ["username"] = ID, ["password"] = PASSWORD, ["alias"] = tostring(alias), ["gameNetwork"] = tostring(networkName) }
    local function onCreateUser( e ) 
        if not e.error then --User Create
            g.stats.userObjId = e.response.objectId --
            g.stats:save()
            parse:setSessionToken( e.response.sessionToken )
            parse:createObject( "Stats", {}, function(e) --Create Stats Row
                if not e.error then
                    g.stats.statsObjId = e.response.objectId --
                    g.stats:save()
                    parse:linkObject( "Stats", g.stats.statsObjId, "player", parse.USER_CLASS, g.stats.userObjId, function(e)
                        if not e.error then
                        end
                    end)
                end
            end)
            parse:createObject( "Settings", {}, function(e) --Create Settings Row
                if not e.error then
                    g.stats.settingsObjId = e.response.objectId --
                    g.stats:save()
                    parse:linkObject( "Settings", g.stats.settingsObjId, "player", parse.USER_CLASS, g.stats.userObjId, function(e)
                        if not e.error then
                        end
                    end)
                end
            end)
            parse:createObject( "Buy", {}, function(e) --Create Buy Row
                if not e.error then
                    g.stats.buyObjId = e.response.objectId --
                    g.stats:save()
                    parse:linkObject( "Buy", g.stats.buyObjId, "player", parse.USER_CLASS, g.stats.userObjId, function(e)
                        if not e.error then
                        end
                    end)
                end
            end)
            parse:createObject( "Scores", {}, function(e) --Create Buy Row
            if not e.error then
                    g.stats.scoresObjId = e.response.objectId --
                    g.stats:save()
                    parse:linkObject( "Scores", g.stats.scoresObjId, "player", parse.USER_CLASS, g.stats.userObjId, function(e)
                        if not e.error then
                        end
                    end)
                end
            end)
            parse:createObject( "Achievements", {}, function(e) --Create Achievement Row
            if not e.error then
                    g.stats.achievementsObjId = e.response.objectId --
                    g.stats:save()
                    parse:linkObject( "Achievements", g.stats.achievementsObjId, "player", parse.USER_CLASS, g.stats.userObjId, function(e)
                        if not e.error then
                        end
                    end)
                end
            end)
        elseif e.error then --User Login
            parse:loginUser( { ["username"] = ID, ["password"] = PASSWORD }, function(e)
                if not e.error then
                    
                end
            end )
        end
    end
    parse:createUser( dataTable, onCreateUser )
end

--v.login( "NathanPB37", "Nate of Great", "gamecenter" )

function v.updateNormalAchievements()
    local billy = {}
    for i=1,#g.achievement.normalAchievements do
        billy[i] = {}
        billy[i][1] = g.achievement.normalAchievements[i].isComplete
        billy[i][2] = g.achievement.normalAchievements[i].showBanner
        billy[i][3] = g.achievement.normalAchievements[i].id
    end

    parse:updateObject( "Achievements", g.stats.achievementsObjId, { ["normal"] = billy }, function(e)
        if not e.error then
            
        end
    end)
end

function v.updateProgressAchievements()
    local billy = {}
    for i=1,#g.achievement.progressAchievements do
        billy[i] = {}
        billy[i][1] = g.achievement.progressAchievements[i].isComplete
        billy[i][2] = g.achievement.progressAchievements[i].number
        billy[i][3] = g.achievement.progressAchievements[i].possible
        billy[i][4] = g.achievement.progressAchievements[i].id
    end

    parse:updateObject( "Achievements", g.stats.achievementsObjId, { ["progress"] = billy }, function(e)
        if not e.error then
            
        end
    end)
end



--local billy = {}
--for i=1,#g.achievement.normalAchievements do
--    billy[i] = {}
--    billy[i][1] = g.achievement.normalAchievements[i].isComplete
--    billy[i][2] = g.achievement.normalAchievements[i].showBanner
--    billy[i][3] = g.achievement.normalAchievements[i].id
--    print( billy[i][1], billy[i][2], billy[i][3] )
--end
--
--parse:updateObject( "Stats", g.stats.statsObjId, { ["videoAd"] = billy }, function(e)
--    if not e.error then
--        print("worked")
--        parse:getObject( "Stats", g.stats.statsObjId, function(e)
--            if not e.error then
--                print( e.response.videoAd[1][3])
--            else 
--                print("~~~~~~~~~~~~~~~~~~~~~~~")
--            end
--        end)
--    else
--        print("no worky...")
--    end
--end)



return v

