local serviceName
local formalServiceName
local score

-- Local methods and ops ------------------------------------------------------[

local function showAlert()
    native.showAlert(
        "Cannot send " .. formalServiceName .. " message.",
        "Please set up your " .. formalServiceName .. " account or check your network connection.",
        { "OK" }
    )
end

local function showPopup()
    local isAvailable = native.canShowPopup( "social", serviceName )
    if isAvailable then
        native.showPopup( "social", {
            service = serviceName,
            message = "I just dropped " .. score .. " points in Drop – The Vertical Challenge! Try to beat my score! #DropChallenge",
            --url = ,
        })
    else
        showAlert()
    end
end
-------------------------------------------------------------------------------]

local v = {}

v.shareResultsOnTwitter = function( score )
    score = score
    serviceName = "twitter"
    formalServiceName = "Twitter"
    showPopup()
end

v.shareResultsOnFacebook = function( score )
    score = score
    serviceName = "facebook"
    formalServiceName = "Facebook"
    showPopup()
end

return v