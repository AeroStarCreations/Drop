-- Control center for logging into a game network.
--
-- USES:
--  * GameCenter login
--  * Google Play login

-- Local variables ------------------------------------------------------------[
local platformType
-------------------------------------------------------------------------------]

-- Local methods --------------------------------------------------------------[
local function setTypes()
    if system.getInfo( "platform" ) == "android" then
        platformType = "android"
    elseif system.getInfo("platform") == "ios" then
        platformType = "ios"
    end
end

local function initGameNetwork(callback)
    if platformType == "ios" then
        local gameCenter = require("other.gameCenter")
        gameCenter.init(callback)
    elseif platformType == "android" then
        local googlePlay = require("other.googlePlay")
        googlePlay.init(callback)
    end
end
-------------------------------------------------------------------------------]

-- Returned values/table ------------------------------------------------------[
local v = {}

function v.login(callback)
    setTypes()
    initGameNetwork(callback)
end

return v
-------------------------------------------------------------------------------]
