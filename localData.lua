-- Control center for writing and reading local storage data.
-- Format of Drop data can be found at the bottom of this file.
--
-- !!! Make sure to call init() when using this module !!!
--
-- Don't set important values to true (i.e. purchases) until the server/backend confirms

local GGData = require( "GGData" )
local json = require( "json" )

-- GGData boxes ---------------------------------------------------------------[
local first = GGData:new( "first" )
local settings = GGData:new( "settings" )
local purchases = GGData:new( "purchases" )
local stats = GGData:new( "stats" )
local achievements = GGData:new( "normalAchievements" )
local social = GGData:new( "social" )
-------------------------------------------------------------------------------]

-- Default value --------------------------------------------------------------[
local settingsDefault = {
    volume = 0.8,
    changingBackgrounds = true,
    specialDrops = true,
    movementSensitivity = 3,
    tiltControl = true
}

local purchasesDefault = {
    invincibility = 999,
    lives = 999,
    ads = false
}

local achievementsDefault = {
    isComplete = false,
}

local socialDefault = {
    alias = "\n\n\n"
}
-------------------------------------------------------------------------------]

-- GameSparks Short Codes -----------------------------------------------------[
-- This is a copy of the table in achievements.lua
-- This had to be duplicated to avoid a requires/dependency loop
local achievementsShortCodes = {
    "MIST",
    "DOUBLE_MIST",
    "DRIZZLE",
    "DOUBLE_DRIZZLE",
    "SHOWER",
    "DOUBLE_SHOWER",
    "DOWNPOUR",
    "DOUBLE_DOWNPOUR",
    "THUNDERSTORM",
    "DOUBLE_THUNDERSTORM",
    "TROPICAL_STORM",
    "DOUBLE_TROPICAL_STORM",
    "MIST_TRICKY",
    "DOUBLE_MIST_TRICKY",
    "DRIZZLE_TRICKY",
    "DOUBLE_DRIZZLE_TRICKY",
    "SHOWER_TRICKY",
    "DOUBLE_SHOWER_TRICKY",
    "DOWNPOUR_TRICKY",
    "DOUBLE_DOWNPOUR_TRICKY",
    "THUNDERSTORM_TRICKY",
    "DOUBLE_THUNDERSTORM_TRICKY",
    "TROPICAL_STORM_TRICKY",
    "DOUBLE_TROPICAL_STORM_TRICKY",
    "HURRICANE_1",
    "HURRICANE_5",
    "HURRICANE_10",
    "SHIELD_5",
    "SHIELD_15",
    "SHIELD_30",
    "REVIVE_1",
    "REVIVE_5",
    "REVIVE_15",
    "PLAY_10",
    "PLAY_50",
    "PLAY_100",
    "PLAY_500",
    "PLAY_1000",
    "DIE_RED",
    "DIE_ORANGE",
    "DIE_YELLOW",
    "DIE_LIGHT_GREEN",
    "DIE_DARK_GREEN",
    "DIE_LIGHT_BLUE",
    "DIE_DARK_BLUE",
    "DIE_PINK",
    "SPECIAL_RED",
    "SPECIAL_ORANGE",
    "SPECIAL_YELLOW",
    "SPECIAL_LIGHT_GREEN",
    "SPECIAL_DARK_GREEN",
    "SPECIAL_LIGHT_BLUE",
    "SPECIAL_DARK_BLUE",
    "SPECIAL_PINK"
}
-------------------------------------------------------------------------------]
    
-- Local methods and ops ------------------------------------------------------[
local function saveSettings()
    settings:save()
end

local function savePurchases()
    purchases:save()
end

local function saveStats()
    stats:save()
end

local function saveSocial()
    social:save()
end

local function initializeAllData( dropTypes )
    -- Get data from backend or set the following to default
    first:set( "hasBeenInitialized", true )
    first:save()
    settings:set( "volume", settingsDefault.volume )
    settings:set( "changingBackgrounds", settingsDefault.changingBackgrounds )
    settings:set( "specialDrops", settingsDefault.specialDrops )
    settings:set( "movementSensitivity", settingsDefault.movementSensitivity )
    settings:set( "tiltControl", settingsDefault.tiltControl )
    settings:save()
    purchases:set( "invincibility", purchasesDefault.invincibility )
    purchases:set( "lives", purchasesDefault.lives )
    purchases:set( "ads", purchasesDefault.ads )
    purchases:save()
    stats:set( "videoAd", { day=os.date("%j"), views=0, lastViewTime=0 } )
    stats:set( "gamesPlayed", 0 )
    stats:set( "deaths", 0 )
    stats:set( "invincibilityUses", 0 )
    stats:set( "lifeUses", 0 )
    for i=1,#dropTypes do
        stats:set( dropTypes[i], {
            normalDodges = 0,
            normalCollisions = 0,
            specialDodges = 0,
            specialCollisions = 0
        })
    end
    stats:save()
    for k,v in pairs( achievementsShortCodes ) do
        achievements:set( v, achievementsDefault.isComplete )
    end
    achievements:save()
    social:set( "alias", socialDefault.alias )
    social:save()
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

-- First -----------------------------[
v.init = function( dropTypes )
    purchases:enableIntegrityControl()
    stats:enableIntegrityControl()
    social:enableIntegrityControl()
    if not first:get( "hasBeenInitialized" ) then
        initializeAllData( dropTypes )
    end
end
--------------------------------------]

-- Settings --------------------------[
v.getVolume = function()
    return settings:get( "volume" )
end

v.setVolume = function( newVolume )
    settings:set( "volume", newVolume )
    saveSettings()
end

v.getChangingBackgroundsEnabled = function()
    return settings:get( "changingBackgrounds" )
end

v.setChangingBackgroundsEnabled = function( areEnabled )
    settings:set( "changingBackgrounds", areEnabled )
    saveSettings()
end

v.getSpecialDropsEnabled = function()
    return settings:get( "specialDrops" )
end

v.setSpecialDropsEnabled = function( areEnabled )
    settings:set( "specialDrops", areEnabled )
    saveSettings()
end

v.getMovementSensitivity = function()
    return settings:get( "movementSensitivity" )
end

v.setMovementSensitivity = function( newSensitivity )
    settings:set( "movementSensitivity", newSensitivity )
    saveSettings()
end

v.getTiltControlEnabled = function()
    return settings:get( "tiltControl" )
end

v.setTiltControlEnabled = function( isEnabled )
    settings:set( "tiltControl", isEnabled )
    saveSettings()
end
--------------------------------------]

-- Purchases -------------------------[
v.getInvincibility = function()
    return purchases:get( "invincibility" )
end

v.addInvincibility = function( amount )
    purchases:increment( "invincibility", amount )
    savePurchases()
end

v.getLives = function()
    return purchases:get( "lives" )
end

v.addLives = function( amount )
    purchases:increment( "lives", amount )
    savePurchases()
end

v.getAdsEnabled = function()
    return purchases:get( "ads" )

end

v.setAdsEnabled = function( enabled )
    purchases:set( "ads", enabled )
    savePurchases()
end
--------------------------------------]

-- Stats -----------------------------[
v.getVideoAdDay = function()
    return stats:get( "videoAd" ).day
end

v.setVideoAdDay = function( newDay )
    local videoAd = stats:get( "videoAd" )
    videoAd.day = newDay
    stats:set( "videoAd", videoAd )
    saveStats()
end

v.getVideoAdViews = function()
    return stats:get( "videoAd" ).views
end

v.addVideoAdView = function()
    local videoAd = stats:get( "videoAd" )
    videoAd.views = videoAd.views + 1
    stats:set( "videoAd", videoAd )
    saveStats()
end

v.resetVideoAdViews = function()
    local videoAd = stats:get( "videoAd" )
    videoAd.views = 0
    stats:set( "videoAd", videoAd )
    saveStats()
end

v.getVideoAdLastViewTime = function()
    return stats:get( "videoAd" ).lastViewTime
end

v.setVideoAdLastViewTime = function( viewTime )
    local videoAd = stats:get( "videoAd" )
    videoAd.lastViewTime = viewTime
    stats:set( "videoAd", videoAd )
    saveStats()
end

v.getGamesPlayed = function()
    return stats:get( "gamesPlayed" )
end

v.incrementGamesPlayed = function()
    stats:increment( "gamesPlayed" )
    saveStats()
end

v.incrementsDeaths = function()
    stats:increment( "deaths" )
    saveStats()
end

v.getInvincibilityUses = function()
    return stats:get( "invincibilityUses" )
end

v.incrementInvincibilityUses = function()
    stats:increment( "invincibilityUses" )
    saveStats()
end

v.getLifeUses = function()
    return stats:get( "lifeUses" )
end

v.incrementLifeUses = function()
    stats:increment( "lifeUses" )
    saveStats()
end

v.getDropNormalDodges = function( dropType )
    local dropTable = stats:get( dropType )
    return dropTable.normalDodges
end

v.incrementDropNormalDodges = function( dropType )
    local dropTable = stats:get( dropType )
    dropTable.normalDodges = dropTable.normalDodges + 1
    stats:set( dropType, dropTable )
    saveStats()
end

v.getDropNormalCollisions = function( dropType )
    local dropTable = stats:get( dropType )
    return dropTable.normalCollisions
end

v.incrementDropNormalCollisions = function( dropType )
    local dropTable = stats:get( dropType )
    dropTable.normalCollisions = dropTable.normalCollisions + 1
    stats:set( dropType, dropTable )
    saveStats()
end

v.getDropSpecialDodges = function( dropType )
    local dropTable = stats:get( dropType )
    return dropTable.specialDodges
end

v.incrementDropSpecialDodges = function( dropType )
    local dropTable = stats:get( dropType )
    dropTable.specialDodges = dropTable.specialDodges + 1
    stats:set( dropType, dropTable )
    saveStats()
end

v.getDropSpecialCollisions = function( dropType )
    local dropTable = stats:get( dropType )
    return dropTable.specialCollisions
end

v.incrementDropSpecialCollisions = function( dropType )
    local dropTable = stats:get( dropType )
    dropTable.specialCollisions = dropTable.specialCollisions + 1
    stats:set( dropType, dropTable )
    saveStats()
end
--------------------------------------]

-- Achievements ----------------------[
v.setAchievementComplete = function( shortCode )
    achievements:set( shortCode, true )
    achievements:save()
end

v.getAchievementComplete = function( shortCode )
    return achievements:get( shortCode )
end
--------------------------------------]

-- Social ----------------------------[
v.getAlias = function()
    return social:get( "alias" )
end

v.setAlias = function( newAlias )
    social:set( "alias", newAlias )
    social:save()
end
--------------------------------------]

return v
-------------------------------------------------------------------------------]

--------------------------------------------------------------------------------
-- DATA FORMATS ----------------------------------------------------------------
--------------------------------------------------------------------------------

-- SETTINGS
-- settings = {
--     volume = int,
--     changingBackgrounds = bool,
--     specialDrops = bool,
--     movementSensitivity = int,
--     tiltControl = bool,
-- }

-- FIRST
-- first = {
--     hasBeenInitialized = bool
-- }

-- PURCHASES
-- purchases = {
--     invincibility = int,
--     lives = int,
--     ads = bool
-- }

-- STATS
-- stats = {
--     videoAd = {
--         day = os.date,
--         views = int,
--         lastViewTime = int
--     },
--     gamesPlayed = int,
--     deaths = int,
--     invincibilityUses = int,
--     lifeUses = int,
--     'dropType' = {
--         normalDodges = int,
--         normalCollisions = int,
--         specialDodges = int,
--         specialCollisions = int
--     }
--     ... one for every drop type
-- }

-- ACHIEVEMENTS
-- achievements = {
--     "SHORT_CODE" = isComplete:boolean
--     ... one for every achievement
-- }

-- SOCIAL
-- social = {
--     alias = string
-- }