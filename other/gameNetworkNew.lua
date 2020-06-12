-- Control center for logging into a game network.
--
-- USES:
--  * GameCenter login
--  * Google Play login

local gameCenter = require("other.gameCenter")
local googlePlay = require("other.googlePlay")

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
        gameCenter.init(callback)
    elseif platformType == "android" then
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
