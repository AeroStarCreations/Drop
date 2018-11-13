--Settings

local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "globalVariables" )
local t = require( "transitions" )
local ld = require( "localData" )


--Precalls
local drop
local backArrow
local lineGroup = display.newGroup()
local groupVolume = display.newGroup()
local groupBackground = display.newGroup()
local groupSpecial = display.newGroup()
local groupSensitivity = display.newGroup()
local groupMethod = display.newGroup()
----------


function scene:create( event )

    local group = self.view
    
    g.create()
    
    ------------------------------------------Logo
    drop = display.newImageRect( "images/name.png", 1020, 390 )
    local dropRatio = drop.height/drop.width
    drop.width = 0.77*display.contentWidth
    drop.height = drop.width*dropRatio
    drop.x = display.contentCenterX
    drop.y = display.topStatusBarContentHeight + 0.4 * drop.height
    drop.xScale, drop.yScale = 0.47, 0.47
    group:insert(drop)
    ----------------------------------------------

    ------------------------------------Back Arrow
    local function baf( event )
       t.transOutSettings( backArrow, lineGroup, groupVolume, groupBackground, groupSpecial, groupSensitivity, groupMethod)
       print( "Arrow Pressed" )
    end

    backArrow = widget.newButton{
        id = "backArrow",
        x = 90,
        y = 0,
        width = 100*g.arrowRatio,
        height = 100,
        defaultFile = "images/arrow.png",
        overFile = "images/arrowD.png",
        onRelease = baf,
    }
    backArrow.rotation = 180
    backArrow.x = -backArrow.width
    backArrow.y = drop.y - 7
    ----------------------------------------------

    -----------------------------------------Lines
    local numberOfSettings = 5
    local focal = drop.y + 0.4 * drop.height
    
    local lineTable = {}
    
    for i=1, numberOfSettings do
       local ypos = focal + (i-1)*((display.contentHeight - focal)/numberOfSettings)
       lineTable[i] = display.newLine( lineGroup, 0, ypos, display.contentWidth, ypos )
       lineTable[i]:setStrokeColor( unpack( g.purple ) )
       lineTable[i].strokeWidth = 2
    end
    group:insert( lineGroup )
    lineGroup.alpha = 0
    ----------------------------------------------
      
    ------------------------------------------------------The following is TEXT

    -----------------------------------Volume Text
    local volTextOpt = {
        parent = groupVolume,
        text = "Game Volume",
        width = 215,
        x = 0.3*display.contentWidth,
        y = lineGroup[1].y+0.5*(lineGroup[2].y-lineGroup[1].y),
        font = g.comLight,
        fontSize = 60,
        align = "center",
    }
    
    local volText = display.newText(volTextOpt)
    volText:setFillColor( unpack( g.purple ) )
    volText.anchorX = 0.5; volText.anchorY = 0.5
    
    local volText2Opt = {
        parent = groupVolume,
        text = "–",
        y = volText.y-15,
        x = 0.7*display.contentWidth,
        width = 200,
        font = g.comRegular,
        fontSize = 45,
        align = "center",
    }
    
    local volText2 = display.newText(volText2Opt)
    volText2:setFillColor( unpack( g.purple ) )
    volText2.anchorX = 0.5; volText2.anchorY = 1

    local function setVolumeText()
        if ld.getVolume() < 0.1 then -- value won't be exactly 0 when mute
            volText2.text = "mute"
        else
            volText2.text = math.round( ld.getVolume()*100 ).."%"
        end
    end
    setVolumeText()
    ----------------------------------------------
    
    -------------------------------Background Text
    local bgTextOpt = {
        parent = groupBackground,
        text = "Changing Backgrounds",
        width = 385,
        x = 0.3*display.contentWidth,
        y = lineGroup[2].y+0.5*(lineGroup[3].y-lineGroup[2].y),
        font = g.comLight,
        fontSize = 60,
        align = "center",
    }
    
    local bgText = display.newText(bgTextOpt)
    bgText:setFillColor( unpack ( g.purple ) )
    bgText.anchorX = 0.5; bgText.anchorY = 0.5
    ----------------------------------------------

    ----------------------------------Special Text
    local specialTextOpt = {
        parent = groupSpecial,
        text = "Special Drops",
        width = 385,
        x = 0.3*display.contentWidth,
        y = lineGroup[3].y+0.5*(lineGroup[4].y-lineGroup[3].y),
        font = g.comLight,
        fontSize = 60,
        align = "center",
    }
    local specialText = display.newText(specialTextOpt)
    specialText:setFillColor( unpack( g.purple ) )
    specialText.anchorX = 0.5; specialText.anchorY = 0.5
    ----------------------------------------------

    ----------------------------------Sensitivity Text
    local senseTextOpt = {
        parent = groupSensitivity,
        text = "Movement Sensitivity",
        width = 310,
        x = 0.3*display.contentWidth,
        y = lineGroup[4].y+0.5*(lineGroup[5].y-lineGroup[4].y),
        font = g.comLight,
        fontSize = 60,
        align = "center",
    }
    
    local senseText = display.newText(senseTextOpt)
    senseText:setFillColor( unpack( g.purple ) )
    senseText.anchorX = 0.5; senseText.anchorY = 0.5
    
    local senseText2Opt = {
        parent = groupSensitivity,
        text = "Medium",
        y = senseText.y-15,
        x = 0.7*display.contentWidth,
        width = 200,
        font = g.comRegular,
        fontSize = 45,
        align = "center",
    }
    
    local senseText2 = display.newText(senseText2Opt)
    senseText2:setFillColor( unpack( g.purple ) )
    senseText2.anchorX = 0.5; senseText2.anchorY = 1
    
    local function sensitivityLevel()
        local w = ld.getMovementSensitivity()
        if w == 1 then
            senseText2.text = "X-Low"
        elseif w == 2 then
            senseText2.text = "Low"
        elseif w == 3 then
            senseText2.text = "Medium"
        elseif w == 4 then
            senseText2.text = "High"
        elseif w == 5 then
            senseText2.text = "X-High"
        end
    end
    sensitivityLevel()
    ----------------------------------------------

    ----------------------------------Method Text
    local methodTextOpt = {
        parent = groupMethod,
        text = "Control Method",
        width = 285,
        x = 0.3*display.contentWidth,
        y = lineGroup[5].y-0.5*(lineGroup[4].y-lineGroup[5].y),
        font = g.comLight,
        fontSize = 60,
        align = "center",
    }
    local methodText = display.newText(methodTextOpt)
    methodText:setFillColor( unpack( g.purple ) )
    methodText.anchorX = 0.5; methodText.anchorY = 0.5
    ----------------------------------------------
    -----------------------------------------------------------------------------------------------
    
    -----------------------------------------------------------------------The following is WIDGETS
    ----------------------------------Stepper Sheet
    local sheetOptions = {
        width = 200,
        height = 83+1/3,
        numFrames = 5,
        sheetContentWidth = 400,
        sheetContentHeight = 250,
    }
    local sheetStepper = graphics.newImageSheet( "images/sheetStepper.png", sheetOptions )
    -----------------------------------------------
    
    ----------------------------------Volume Stepper
    local function volumeStepperListener( event )
        local newVolume = event.value * 0.1
        if event.phase == "decrement" then
            ld.setVolume( newVolume )
            audio.setVolume( newVolume )
        elseif event.phase == "increment" then
            ld.setVolume( newVolume )
            audio.setVolume( newVolume )
        end
        setVolumeText()
        print( "Volume = "..audio.getVolume() )
    end

    print("initial volume = " .. ld.getVolume())
    
    local volumeStepper = widget.newStepper {
        width = 200,
        height = 83+1/3,
        x = 0.7*display.contentWidth,
        y = volText.y-10,
        sheet = sheetStepper,
        defaultFrame = 1,
        noMinusFrame = 2,
        noPlusFrame = 3,
        minusActiveFrame = 4,
        plusActiveFrame = 5,
        initialValue = math.round( ld.getVolume()*10 ),
        maximumValue = 10,
        minimumValue = 0,
        timerIncrimentSpeed = 500,
        changeSpeedAtIncriment = 2,
        onPress = volumeStepperListener,
    }
    volumeStepper.anchorX, volumeStepper.anchorY = 0.5, 0
    groupVolume:insert( volumeStepper )
    ------------------------------------------------
    
    -------------------------------Background Switch
    local function bgSwitchListener()
        if ld.getChangingBackgroundsEnabled() then
            print("Changing Backgrounds are OFF")
            ld.setChangingBackgroundsEnabled( false )
        else
            print("Changing Backgrounds are ON")
            ld.setChangingBackgroundsEnabled( true )
        end
    end
    
    local bgSwitch = g.onOffSwitch({
        parent = groupBackground,
        x = 0.7 * display.actualContentWidth,
        y = bgText.y,
        width = 210,
        height = 90,
        label1 = "OFF",
        label2 = "ON",
        isOn = ld.getChangingBackgroundsEnabled(),
        listener = bgSwitchListener
    })
    ------------------------------------------------
    
    -------------------------------Special Switch
    local function specialSwitchLstener()
        if ld.getSpecialDropsEnabled() then
            print("Specials are OFF")
            ld.setSpecialDropsEnabled( false )
        else
            print("Specials are ON")
            ld.setSpecialDropsEnabled( true )
        end
    end
    
    local specialSwitch = g.onOffSwitch({
        parent = groupSpecial,
        x = 0.7 * display.actualContentWidth,
        y = specialText.y,
        width = 210,
        height = 90,
        label1 = "OFF",
        label2 = "ON",
        isOn = ld.getSpecialDropsEnabled(),
        listener = specialSwitchLstener
    })
    ------------------------------------------------
    
    ----------------------------------Sensitivity Stepper
    local function sensitivityStepperListener( event )
       ld.setMovementSensitivity( event.value )
       sensitivityLevel()
       print( "Tilt sensitivity = "..senseText2.text )
    end
    
    local sensitivityStepper = widget.newStepper{
        width = 200,
        height = 83+1/3,
        x = 0.7*display.contentWidth,
        y = senseText.y-10,
        sheet = sheetStepper,
        defaultFrame = 1,
        noMinusFrame = 2,
        noPlusFrame = 3,
        minusActiveFrame = 4,
        plusActiveFrame = 5,
        initialValue = ld.getMovementSensitivity(),
        maximumValue = 5,
        minimumValue = 1,
        timerIncrimentSpeed = 500,
        changeSpeedAtIncriment = 2,
        onPress = sensitivityStepperListener,
    }
    sensitivityStepper.anchorX, sensitivityStepper.anchorY = 0.5, 0
    groupSensitivity:insert( sensitivityStepper )
    ------------------------------------------------
    
    -------------------------------Method Switch
    local function methodSwitchListener()
        if ld.getTiltControlEnabled() then
            print("Controls set to TAP")
            ld.setTiltControlEnabled( false )
        else
            print("Controls set to TILT")
            ld.setTiltControlEnabled( true )
        end
        print( "Tilt method set to " .. tostring(ld.getTiltControlEnabled()) )
    end
    
    local methodSwitch = g.onOffSwitch({
        parent = groupMethod,
        x = 0.7 * display.actualContentWidth,
        y = methodText.y,
        width = 210,
        height = 90,
        label1 = "TAP",
        label2 = "TILT",
        isOn = ld.getTiltControlEnabled(),
        listener = methodSwitchListener
    })
    ------------------------------------------------
    
    -----------------------------------------Insert groups and initial positions
    group:insert( groupVolume )
    group:insert( groupBackground )
    group:insert( groupSpecial )
    group:insert( groupSensitivity )
    group:insert( groupMethod )
    groupVolume.x = -1.2*groupVolume.width
    groupBackground.x = display.contentWidth
    groupSpecial.x = -1.2*groupSpecial.width
    groupSensitivity.x = display.contentWidth
    groupMethod.x = -1.2*groupMethod.width
    ----------------------------------------------------------------------------
    
    
    
end


function scene:show( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()
        
        t.transInSettings( backArrow, drop, lineGroup, groupVolume, groupBackground, groupSpecial, groupSensitivity, groupMethod )
        
    end
end


function scene:hide( event )
   
   local group = self.view
   local phase = event.phase
   
   if ( phase == "will" ) then
      
   elseif ( phase == "did" ) then
      
      g.hide()
      
      groupVolume.x = -1.5*groupVolume.width
      groupBackground.x = display.contentWidth
      groupSpecial.x = -1.5*groupSpecial.width
      groupSensitivity.x = display.contentWidth
      groupMethod.x = -1.5*groupMethod.width
      
   end
end


function scene:destroy( event )

    local group = self.view
    
    g.destroy()
    
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene