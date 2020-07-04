-- Central hub for all Drop colors and color functions

local Colors = {}
local Colors_mt = { __index = Colors }

function Colors:new(rgbTable)
    local self = {}
    setmetatable(self, Colors_mt)
    self.rgb = rgbTable
    return self
end

function Colors:unpack()
    return self.rgb[1], self.rgb[2], self.rgb[3]
end

local v = {}

v.darkRed = Colors:new({ 0.902, 0.141, 0.125 })
v.darkOrange = Colors:new({ 1, 0.427, 0.063 })
v.darkYellow = Colors:new({ 0.922, 0.678, 0.055 })
v.darkGreen = Colors:new({ 0.055, 0.545, 0.078 })
v.darkBlue = Colors:new({ 0.098, 0.329, 0.902 })
v.darkPink = Colors:new({ 1, 0, 0.722 })

v.red = Colors:new({ 0.98, 0.35, 0.35 })
v.orange = Colors:new({ 0.97, 0.64, 0.23 })
v.yellow = Colors:new({ 0.91, 0.91, 0.00 })
v.green = Colors:new({ 0.31, 0.86, 0.42 })
v.blue = Colors:new({ 0.00, 0.73, 1.00 })
v.pink = Colors:new({ 0.96, 0.40, 0.76 })

v.lightGreen = Colors:new({ 0.61, 0.95, 0.05 })
v.lightBlue = Colors:new({ 0.05, 0.91, 0.93 })

v.purple_xs = Colors:new({ 0.78, 0.70, 0.84 })
v.purple_s = Colors:new({ 0.67, 0.55, 0.76 })
v.purple = Colors:new({ 0.4, 0.176, 0.569 })
v.purple_l = Colors:new({ 0.33, 0.15, 0.47 })
v.purple_xl = Colors:new({ 0.24, 0.09, 0.36 })

-- v.lightBlue = { 0.047, 0.894, 0.918 })
-- v.blue = { 0.118, 0.565, 1 })
-- v.orange = { 0.965, 0.537, 0.231 })

return v