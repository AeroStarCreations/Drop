-- Private Members ------------------------------------------------------------[
local tag = "achievements:"

local function newNormalAchievement(shortCode, lives, invincibilities, description)
    return {
        shortCode = shortCode,
        reward = {
            lives = lives,
            invincibilities = invincibilities,
            description = description
        }
    }
end

local function newProgressAchievement(shortCode, lives, invincibilities, targetValue, description)
    local achievement = newNormalAchievement(shortCode, lives, invincibilities, description)
    achievement.targetValue = targetValue
    return achievement
end

-- If this table is updated, it must also be updated in localData.lua
local normalAchievements = {
    -- SHORT_CODE, lives, invincibilites, description
    newNormalAchievement("MIST", 0, 1, "Complete level Mist"),
    newNormalAchievement("DOUBLE_MIST", 0, 1, "Complete level Double Mist"),
    newNormalAchievement("DRIZZLE", 0, 1, "Complete level Drizzle"),
    newNormalAchievement("DOUBLE_DRIZZLE", 0, 1, "Complete level Double Drizzle"),
    newNormalAchievement("SHOWER", 0, 1, "Complete level Shower"),
    newNormalAchievement("DOUBLE_SHOWER", 0, 1, "Complete level Double Shower"),
    newNormalAchievement("DOWNPOUR", 0, 1, "Complete level Downpour"),
    newNormalAchievement("DOUBLE_DOWNPOUR", 0, 1, "Complete level Double Downpour"),
    newNormalAchievement("THUNDERSTORM", 0, 1, "Complete level Thunderstorm"),
    newNormalAchievement("DOUBLE_THUNDERSTORM", 1, 0, "Complete level Double Thunderstorm"),
    newNormalAchievement("TROPICAL_STORM", 0, 1, "Complete level Tropical Storm"),
    newNormalAchievement("DOUBLE_TROPICAL_STORM", 1, 1, "Complete level Double Tropical Storm"),
    newNormalAchievement("MIST_TRICKY", 0, 1, "Complete level Mist without special drops"),
    newNormalAchievement("DOUBLE_MIST_TRICKY", 0, 1, "Complete level Double Mist without special drops"),
    newNormalAchievement("DRIZZLE_TRICKY", 0, 1, "Complete level Drizzle without special drops"),
    newNormalAchievement("DOUBLE_DRIZZLE_TRICKY", 0, 1, "Complete level Double Drizzle without special drops"),
    newNormalAchievement("SHOWER_TRICKY", 0, 1, "Complete level Shower without special drops"),
    newNormalAchievement("DOUBLE_SHOWER_TRICKY", 0, 1, "Complete level Double Shower without special drops"),
    newNormalAchievement("DOWNPOUR_TRICKY", 0, 1, "Complete level Downpour without special drops"),
    newNormalAchievement("DOUBLE_DOWNPOUR_TRICKY", 0, 1, "Complete level Double Downpour without special drops"),
    newNormalAchievement("THUNDERSTORM_TRICKY", 0, 1, "Complete level Thunderstorm without special drops"),
    newNormalAchievement("DOUBLE_THUNDERSTORM_TRICKY", 1, 0, "Complete level Double Thunderstorm without special drops"),
    newNormalAchievement("TROPICAL_STORM_TRICKY", 0, 1, "Complete level Tropical Storm without special drops"),
    newNormalAchievement("DOUBLE_TROPICAL_STORM_TRICKY", 1, 1, "Complete level Double Tropical Storm without special drops")
}

local progressAchievements = {
    -- SHORT_CODE, lives, invincibilites, target_value, description
    newProgressAchievement("HURRICANE_1", 1, 1, 60, "Survive in level Hurricane for 1 minute"),
    newProgressAchievement("HURRICANE_3", 2, 2, 300, "Survive in level Hurricane for 3 minutes"),
    newProgressAchievement("HURRICANE_10", 3, 3, 700, "Survive in level Hurricane for 10 minutes"),
    newProgressAchievement("SHIELD_5", 1, 0, 5, "Use 5 shields"),
    newProgressAchievement("SHIELD_15", 2, 0, 15, "Use 15 shields"),
    newProgressAchievement("SHIELD_30", 3, 0, 30, "Use 30 shields"),
    newProgressAchievement("REVIVE_1", 0, 1, 1, "Revive 1 time"),
    newProgressAchievement("REVIVE_5", 0, 3, 5, "Revive 5 times"),
    newProgressAchievement("REVIVE_15", 0, 5, 15, "Revive 15 times"),
    newProgressAchievement("PLAY_10", 1, 1, 10, "Play 10 games"),
    newProgressAchievement("PLAY_50", 2, 2, 50, "Play 50 times"),
    newProgressAchievement("PLAY_100", 3, 3, 100, "Play 100 times"),
    newProgressAchievement("PLAY_500", 4, 6, 500, "Play 500 times"),
    newProgressAchievement("PLAY_1000", 5, 10, 1000, "Play 1000 times"),
    newProgressAchievement("DIE_RED", 0, 1, 5, "Die 5 times from red drops"),
    newProgressAchievement("DIE_ORANGE", 0, 1, 10, "Die 10 times from orange drops"),
    newProgressAchievement("DIE_YELLOW", 0, 2, 15, "Die 15 times from yellow drops"),
    newProgressAchievement("DIE_LIGHT_GREEN", 0, 2, 20, "Die 20 times from light green drops"),
    newProgressAchievement("DIE_DARK_GREEN", 1, 0, 25, "Die 25 times from dark green drops"),
    newProgressAchievement("DIE_LIGHT_BLUE", 1, 0, 30, "Die 30 times from light blue drops"),
    newProgressAchievement("DIE_DARK_BLUE", 1, 1, 35, "Die 35 times from dark blue drops"),
    newProgressAchievement("DIE_PINK", 1, 1, 40, "Die 40 times from pink drops"),
    newProgressAchievement("SPECIAL_RED", 0, 1, 50, "Collect 50 special red drops"),
    newProgressAchievement("SPECIAL_ORANGE", 0, 1, 50, "Collect 50 special orange drops"),
    newProgressAchievement("SPECIAL_YELLOW", 0, 1, 50, "Collect 50 special yellow drops"),
    newProgressAchievement("SPECIAL_LIGHT_GREEN", 0, 1, 50, "Collect 50 special light green drops"),
    newProgressAchievement("SPECIAL_DARK_GREEN", 0, 1, 50, "Collect 50 special dark green drops"),
    newProgressAchievement("SPECIAL_LIGHT_BLUE", 0, 1, 50, "Collect 50 special light blue drops"),
    newProgressAchievement("SPECIAL_DARK_BLUE", 0, 1, 50, "Collect 50 special dark blue drops"),
    newProgressAchievement("SPECIAL_PINK", 0, 1, 50, "Collect 50 special pink drops")
}

-- Public Members -------------------------------------------------------------[
local v = {}

function v.getTag()
    return tag
end

function v.getNormalAchievements()
    return normalAchievements
end

function v.getProgressAchievements()
    return progressAchievements
end

function v.getAchievementShortCodes()
    local shortCodes = {}
    for key, value in pairs(normalAchievements) do
        table.insert( shortCodes, value.shortCode )
    end
    for key, value in pairs(progressAchievements) do
        table.insert( shortCodes, value.shortCode )
    end
    return shortCodes
end

return v