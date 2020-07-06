local GGFont = require("thirdParty.GGFont")

local FONT_MANAGER = GGFont:new()
local LIGHT_FONT_NAME = "comfortaaLight"
local REGULAR_FONT_NAME = "comfortaaRegular"
local BOLD_FONT_NAME = "comfortaaBold"

-- Private Members ------------------------------------------------------------[

-- Initialization -------------------------------------------------------------[
FONT_MANAGER:add( REGULAR_FONT_NAME, "Comfortaa-Regular", "Comfortaa-Regular.ttf" )
FONT_MANAGER:add( LIGHT_FONT_NAME, "Comfortaa-Light", "Comfortaa-Light.ttf" )
FONT_MANAGER:add( BOLD_FONT_NAME, "Comfortaa-Bold", "Comfortaa-Bold.ttf" )

-- Public Members -------------------------------------------------------------[
local v = {}

function v.getLight()
    return FONT_MANAGER:get(LIGHT_FONT_NAME)
end

function v.getRegular()
    return FONT_MANAGER:get(REGULAR_FONT_NAME)
end

function v.getBold()
    return FONT_MANAGER:get(BOLD_FONT_NAME)
end

return v
