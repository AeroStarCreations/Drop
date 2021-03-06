local cp = require("composer")
local controller = require("controllers.gameInfoController")
local scene = cp.newScene()
local widget = require("widget")
local g = require("other.globalVariables")
local ld = require("data.localData")
local logoModule = require("other.logoModule")
local colors = require("other.colors")
local Drop = require("views.other.Drop")
local fonts = require("other.fonts")
local stringUtils = require("other.stringUtils")

--Precalls
local rowHeight = 110
local lineGroup = {}
local textGroup = {}
local imageGroup = {}
local iconGroup = {}
local lineThickness = 4
local lineThicknessBold = 10
local nextY
local w = display.actualContentWidth
local h = display.actualContentHeight
----------

--Functions
local function incrementNextY(y)
    if not y then
        nextY = nextY + rowHeight
    else
        nextY = y
    end
end

local function createLine(parent, x1, y1, x2, y2, isBold)
    local thickness = lineThickness
    local color = colors.purple_xs
    if isBold then
        thickness = lineThicknessBold
        color = colors.purple
    end
    local line = display.newLine(parent, x1, y1, x2, y2)
    line:setStrokeColor(color:unpack())
    line.strokeWidth = thickness
    line.alpha = 0
    if not isBold then
        line:toBack()
    end
    table.insert(lineGroup, line)
    return line
end

local function createText(parent, text, x, y, horizontalSpace, color, isTitle)
    local font = fonts.getRegular()
    local yOffset = 6
    if isTitle then
        font = fonts.getBold()
        yOffset = 0
    end
    local text =
        display.newText(
        {
            parent = parent,
            text = text,
            x = x,
            y = y + 0.5 * rowHeight + yOffset,
            font = font
        }
    )
    text:setFillColor(color:unpack())
    controller.setFontSize(text, horizontalSpace)
    text.xScale = 0.001
    text.yScale = 0.001
    table.insert(textGroup, text)
    return text
end
-----------

function scene:create(event)
    local group = self.view

    g.create()

    ------------------------------------------Logo
    local drop = logoModule.getSmallLogo(group)
    ----------------------------------------------

    ------------------------------------Back Arrow
    local backArrow =
        widget.newButton {
        id = "backArrow",
        x = 90,
        y = 0,
        width = 100 * g.arrowRatio,
        height = 100,
        defaultFile = "images/arrow.png",
        overFile = "images/arrowD.png",
        onRelease = controller.backArrowListener
    }
    backArrow.rotation = 180
    backArrow.x = 0.4 * (drop.x - 0.5 * drop.width)
    backArrow.y = drop.y + 0.5 * drop.height
    group:insert(backArrow)
    ----------------------------------------------

    ------------------------------------Stats Logo
    local statsLogo = display.newImageRect(group, "images/logoGameStats.png", 66, 66)
    statsLogo.height = backArrow.height
    statsLogo.width = statsLogo.height
    statsLogo.x = display.contentWidth + 0.5 * statsLogo.width
    statsLogo.y = backArrow.y

    local statsLogoX =
        drop.x + 0.5 * drop.contentWidth + 0.5 * (display.contentWidth - drop.x - 0.5 * drop.contentWidth)

    controller.linkStatsLogo(statsLogo, statsLogoX)
    ----------------------------------------------

    incrementNextY(logoModule.getSmallLogoBottomY())
    ----------------------------------------------

    ----------------------------------Text & Lines
    createLine(group, 0, nextY, w, nextY, true)

    createText(group, "RECORDS", display.contentCenterX, nextY, w, colors.darkPink, true)

    incrementNextY()

    local verticalLineTopY = nextY
    createLine(group, 0, nextY, w, nextY, false)

    createText(group, "Normal", display.contentCenterX, nextY, w / 3, colors.blue, true)

    local x = w / 6 * 5
    createText(group, "Tricky", x, nextY, w / 3, colors.blue, true)

    incrementNextY()

    createLine(group, 0, nextY, w, nextY, false)

    local x = w / 6
    createText(group, "Score", x, nextY, w / 3, colors.blue, true)

    local text = stringUtils.addCommasToNumber(ld.getHighScore("HighScore"))
    createText(group, text, display.contentCenterX, nextY, w / 3, colors.purple, false)

    x = w / 6 * 5
    text = stringUtils.addCommasToNumber(ld.getHighScore("HighScoreTricky"))
    createText(group, text, x, nextY, w / 3, colors.purple, false)

    incrementNextY()

    createLine(group, 0, nextY, w, nextY, false)

    x = w / 6
    createText(group, "Time", x, nextY, w / 3, colors.blue, true)

    text = stringUtils.formatTime(ld.getHighScore("HighTime"))
    createText(group, text, display.contentCenterX, nextY, w / 3, colors.purple, false)

    x = w / 6 * 5
    text = stringUtils.formatTime(ld.getHighScore("HighTimeTricky"))
    createText(group, text, x, nextY, w / 3, colors.purple, false)

    incrementNextY()

    x = w / 3
    createLine(group, x, verticalLineTopY, x, nextY, false)

    createLine(group, x * 2, verticalLineTopY, x * 2, nextY, false)

    createLine(group, 0, nextY, w, nextY, true)

    x = w / 4
    verticalLineTopY = nextY
    createText(group, "Games", x, nextY, w / 2, colors.green, true)

    createText(group, "Deaths", x * 3, nextY, w / 2, colors.red, true)

    incrementNextY()

    createLine(group, 0, nextY, w, nextY, false)

    text = stringUtils.addCommasToNumber(ld.getGamesPlayed())
    createText(group, text, x, nextY, w / 2, colors.purple, false)

    text = stringUtils.addCommasToNumber(ld.getDeaths())
    createText(group, text, x * 3, nextY, w / 2, colors.purple, false)

    incrementNextY()

    createLine(group, x * 2, verticalLineTopY, x * 2, nextY, false)

    createLine(group, 0, nextY, w, nextY, true)

    -- Create 5 vertical lines
    x = w / 12
    local multiplier = 2
    for i = 1, 5 do
        local line = createLine(group, x * multiplier, nextY, x * multiplier, h, false)
        multiplier = multiplier + 2
    end

    controller.linkLineGroup(lineGroup)
    controller.linkTextGroup(textGroup)
    ----------------------------------------------

    -------------------------------Scroll View
    -- INSERT 4 IMAGES HERE --
    y = nextY + 0.5 * rowHeight
    local iconSize = rowHeight * 0.6
    iconGroup[1] = display.newImageRect(group, "images/smileIcon.png", iconSize, iconSize)
    iconGroup[1].x = x * 3
    iconGroup[2] = display.newImageRect(group, "images/deathIcon.png", iconSize, iconSize)
    iconGroup[2].x = x * 5
    iconGroup[3] = display.newImageRect(group, "images/checkIcon.png", iconSize, iconSize)
    iconGroup[3].x = x * 9
    iconGroup[4] = display.newImageRect(group, "images/xIcon.png", iconSize, iconSize)
    iconGroup[4].x = x * 11
    for k, icon in pairs(iconGroup) do
        icon.y = y
        icon.xScale = 0.001
        icon.yScale = 0.001
    end
    controller.linkIconGroup(iconGroup)

    incrementNextY()

    createLine(group, 0, nextY, w, nextY, false)

    local scrollView =
        widget.newScrollView(
        {
            left = 0,
            top = nextY + 0.5 * lineThickness,
            width = w,
            height = h - nextY,
            horizontalScrollDisabled = true,
            hideBackground = true
        }
    )
    group:insert(scrollView)

    local dropHeight = 100
    incrementNextY(0)

    for i = 1, Drop.getNumberOfColors() do
        -- Normal drop image
        local image1 = Drop.getDropImage(group, dropHeight, i, false)
        image1.x = x
        image1.y = nextY + 0.5 * rowHeight
        image1.xScale = 0.001
        image1.yScale = 0.001
        table.insert(imageGroup, image1)
        scrollView:insert(image1)
        -- # dodges
        local text = ld.getDropNormalDodges(Drop.types[i])
        local textObj = createText(group, text, x * 3, nextY, w / 6, colors.purple, false)
        scrollView:insert(textObj)
        -- # deaths
        text = ld.getDropNormalCollisions(Drop.types[i])
        textObj = createText(group, text, x * 5, nextY, w / 6, colors.purple, false)
        scrollView:insert(textObj)
        -- Special drop image
        local image2 = Drop.getDropImage(group, dropHeight, i, true)
        image2.x = x * 7
        image2.y = nextY + 0.5 * rowHeight
        image2.xScale = 0.001
        image2.yScale = 0.001
        table.insert(imageGroup, image2)
        scrollView:insert(image2)
        -- # collisions
        text = ld.getDropSpecialCollisions(Drop.types[i])
        textObj = createText(group, text, x * 9, nextY, w / 6, colors.purple, false)
        scrollView:insert(textObj)
        -- # misses
        text = ld.getDropSpecialDodges(Drop.types[i])
        textObj = createText(group, text, x * 11, nextY, w / 6, colors.purple, false)
        scrollView:insert(textObj)
        -- Update nextY
        incrementNextY()
        -- Create line
        if i ~= Drop.getNumberOfColors() then
            local line = createLine(group, 0, nextY, w, nextY, false)
            scrollView:insert(line)
        end
    end

    controller.linkImageGroup(imageGroup)

    scrollView:setScrollHeight(Drop.getNumberOfColors() * rowHeight)
end

function scene:show(event)
    local group = self.view
    local phase = event.phase

    if (phase == "will") then
    elseif (phase == "did") then
        g.show()

        controller.transitionIn()
    end
end

function scene:hide(event)
    local group = self.view
    local phase = event.phase

    if (phase == "will") then
    elseif (phase == "did") then
        g.hide()

        -- We destroy the scene so that all display objects are [re]created
        -- when the user enters the scene. This ensures the data will be
        -- up-to-date (e.g. high scores)
        cp.removeScene("views.scenes.gameInfo" , true)

        scene:destroy()
    end
end

function scene:destroy(event)
    local group = self.view
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
