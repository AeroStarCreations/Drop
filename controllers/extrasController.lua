-------------------------------------------------------------------------------
-- Private Members ------------------------------------------------------------
-------------------------------------------------------------------------------
-- Imports
local model = require("models.extrasModel")
local cp = require("composer")
local ld = require("data.localData")
local g = require("other.globalVariables")
local ads = require("other.advertisements2")
local json = require("json")

-- View Objects
local backArrow
local dropLogo
local buttonGroup
local squares
local countDown

-- Other
local addButtonTouchListeners
local buttonFocalX
local adTimer
local currentTime
local timeDifference

---------------------------------------------------------------------
-- Transitions ------------------------------------------------------
---------------------------------------------------------------------
local function transitionInFromCenter()
    transition.to(backArrow, {time = 300, x = 0.4 * (dropLogo.x - 0.5 * dropLogo.width), transition = easing.outQuad})
    for k, v in ipairs(buttonGroup) do
        transition.to(v, {time = 400, xScale = 1, yScale = 1, transition = easing.outBack})
    end
    timer.performWithDelay(400, addButtonTouchListeners)
end

local function transitionInFromOther()
    for i = 1, #buttonGroup do
        if (i % 2 == 0) then
            transition.to(
                buttonGroup[i],
                {time = 400, x = display.contentWidth - buttonFocalX, transition = easing.outSine}
            )
        else
            transition.to(buttonGroup[i], {time = 400, x = buttonFocalX, transition = easing.outSine})
        end
    end
    timer.performWithDelay(400, addButtonTouchListeners)
end

local function transitionIn(previousSceneName)
    if previousSceneName == "views.scenes.center" then
        transitionInFromCenter()
    else
        transitionInFromOther()
    end
end

local function transitionOutToCenter()
    transition.to(backArrow, {time = 300, x = -backArrow.width, transition = easing.inQuad})
    for k, v in ipairs(buttonGroup) do
        transition.to(v, {time = 400, xScale = 0.001, yScale = 0.001, transition = easing.inBack})
    end
    timer.performWithDelay(
        400,
        function()
            cp.gotoScene("views.scenes.center")
        end
    )
end

local function transitionOutToOther(scene)
    for i = 1, #buttonGroup do
        if (i % 2 == 0) then
            transition.to(
                buttonGroup[i],
                {time = 400, x = display.contentWidth + 0.51 * buttonGroup[i].width, transition = easing.inSine}
            )
        else
            transition.to(buttonGroup[i], {time = 400, x = -0.51 * buttonGroup[i].width, transition = easing.inSine})
        end
    end
    timer.performWithDelay(
        400,
        function()
            cp.gotoScene(scene)
        end
    )
end

---------------------------------------------------------------------
-- Other Logic ------------------------------------------------------
---------------------------------------------------------------------
local function buttonReleasedWithinBounds(event)
    local eventX = event.x
    local eventY = event.y
    local button = event.target.parent
    local halfBtnW = 0.5 * button.width * button.xScale / button.parent.xScale
    local halfBtnH = 0.5 * button.height * button.yScale / button.parent.yScale
    return eventX > button.x - halfBtnW and eventX < button.x + halfBtnW and eventY > button.y - halfBtnH and
        eventY < button.y + halfBtnH
end

local function buttonListener(event)
    print(json.prettify(event))
    local id = event.target.parent.id

    if not event.target.isEnabled then
        return
    end

    if event.phase == "began" then
        display.getCurrentStage():setFocus(event.target)
        transition.to(event.target.parent, {time = 40, xScale = 0.7, yScale = 0.7})
    elseif event.phase == "ended" then
        display.getCurrentStage():setFocus(nil)
        transition.to(event.target.parent, {time = 40, xScale = 1, yScale = 1})
        print(id .. "button was not pressed.")
        if buttonReleasedWithinBounds(event) then
            print(id .. "button was pressed.")
            if id == "leaderboards" then
                transitionOutToOther("views.scenes.leaderboardsScene")
            elseif id == "market" then
                transitionOutToOther("views.scenes.market")
            elseif id == "aboutASC" then
                transitionOutToOther("views.scenes.aboutASC")
            elseif id == "aboutMusic" then
                transitionOutToOther("views.scenes.aboutMusic")
            elseif id == "ad" then
                event.target.isEnabled = false
                ads.show(true)
            elseif id == "gameInfo" then
                transitionOutToOther("views.scenes.gameInfo")
            end
        end
    end
end

function addButtonTouchListeners()
    for k, v in ipairs(squares) do
        v:addEventListener("touch", buttonListener)
    end
end

local function removeButtonTouchListeners()
    for k, v in ipairs(squares) do
        v:removeEventListener("touch", buttonListener)
    end
end

local function getAdButton()
    for k, button in ipairs(squares) do
        if button.parent.id == "ad" then
            return button
        end
    end
end

local function adTimerListener()
    local adButton = getAdButton()

    if ld.getVideoAdViews() < 5 then
        currentTime = os.time(os.date("*t")) --current seconds since 1970
        timeDifference = currentTime - ld.getVideoAdLastViewTime()

        if timeDifference >= 300 then --300 seconds between video ads
            if not adButton.isEnabled then
                adButton.alpha = 1
                adButton.isEnabled = true
                countDown.text = " "
            end
        else
            if adButton.sEnabled then
                adButton.alpha = 0.4
                adButton.isEnabled = false
            end
            countDown.text = g.timeFormat(300 - timeDifference)
        end
    else
        adButton.isEnabled = false
        adButton.alpha = 0.3
    end
end

local function onSceneShow(previousSceneName)
    transitionIn(previousSceneName)
    getAdButton().isEnabled = false
    adTimerListener()
    adTimer = timer.performWithDelay(1000, adTimerListener, -1)
end

local function onSceneHide()
    removeButtonTouchListeners()
    if adTimer then
        timer.cancel(adTimer)
        adTimer = nil
    end
end

-------------------------------------------------------------------------------
-- Public Members -------------------------------------------------------------
-------------------------------------------------------------------------------
local v = {}

function v.backArrowListener()
    print("Arrow Pressed")
    transitionOutToCenter()
end

function v.onSceneShow(previousSceneName)
    onSceneShow(previousSceneName)
end

function v.onSceneHide()
    onSceneHide()
end

function v.setButtonFocalX(x)
    buttonFocalX = x
end

function v.buttonListener(event)
    buttonListener(event)
end

function v.getFillImages()
    return model.getFillImages()
end

function v.getLogoImages()
    return model.getLogoImages()
end

function v.getLabelText()
    return model.getLabelText()
end

function v.getStrokeColors()
    return model.getStrokeColors()
end

function v.getButtonIds()
    return model.getButtonIds()
end

function v.linkButtons(viewObject)
    buttonGroup = viewObject
end

function v.linkSquares(viewObject)
    squares = viewObject
end

function v.linkBackArrow(viewObject)
    backArrow = viewObject
end

function v.linkLogo(viewObject)
    dropLogo = viewObject
end

function v.linkCountDown(viewObject)
    countDown = viewObject
end

return v
