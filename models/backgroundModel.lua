-- Private Members ------------------------------------------------------------[
local fileWidth = 1000
local fileHeight = 1500
local activeBackgroundIndex = 0
local fadeInTime = 3500
local fadeOutTime = 2500

local imageGroup = {}
local images = {}

local backgroundFileNames = {
    [1] = "images/bg.png",
    [2] = "images/bg2.png",
    [3] = "images/bg3.png",
    [4] = "images/bg4.png",
    [5] = "images/bg5.png",
    [6] = "images/bg6.png",
    [7] = "images/bg7.png"
}

-- Public Members -------------------------------------------------------------[
local v = {}

function v.getFileNames()
    return backgroundFileNames
end

function v.getFileWidth()
    return fileWidth
end

function v.getFileHeight()
    return fileHeight
end

function v.getImageGroup()
    return imageGroup
end

function v.setImageGroup(group)
    imageGroup = group
end

function v.getImage(index)
    return images[index]
end

function v.getActiveImage(dif)
    return images[activeBackgroundIndex + (dif or 0)]
end

function v.setImage(index, imageRect)
    images[index] = imageRect
end

function v.setImageAlpha(index, alpha)
    images[index].alpha = alpha
end

function v.getImagesSize()
    return #images
end

function v.getActiveBackgroundIndex()
    return activeBackgroundIndex
end

function v.setActiveBackgroundIndex(index)
    activeBackgroundIndex = index
end

function v.incrementActiveBackgroundIndex()
    activeBackgroundIndex = activeBackgroundIndex + 1
end

function v.getFadeInTime()
    return fadeInTime
end

function v.getFadeOutTime()
    return fadeOutTime
end

return v
