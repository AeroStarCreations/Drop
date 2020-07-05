local GGFont = require("thirdParty.GGFont")

-- Private Members ------------------------------------------------------------[
local function insertCommas(num, acc)
    local len = string.len(num)
    if len > 3 then
        acc = "," .. num:sub(len - 2, len) .. acc
        num = num:sub(1, len - 3)
        return insertCommas(num, acc)
    else
        return num .. acc
    end
end

local function addCommasToNumber(num)
    local numString = tostring(num)

    local isNegative = num < 0
    if isNegative then
        numString = numString:sub(2, string.len(num))
    end

    numString = insertCommas(numString, "")

    if isNegative then
        return "-" .. numString
    end
    return numString
end

---Formats the time given in seconds
local function formatTime(time)
    local hour = math.floor( time / 3600 )
    local minute = math.floor( (time - hour * 3600) / 60 )
    local second = math.floor( time - hour * 3600 - minute * 60 )
    if minute < 10 and hour > 0 then
        minute = "0"..minute
    end
    if second < 10 then
        second = "0"..second
    end
    local text
    if hour > 0 then
        text = hour..":"..minute..":"..second
    else
        text = minute..":"..second
    end
    return text
end

-- Public Members -------------------------------------------------------------[
local v = {}

function v.addCommasToNumber(number)
    return addCommasToNumber(number)
end

function v.formatTime(time)
    return formatTime(time)
end

return v
