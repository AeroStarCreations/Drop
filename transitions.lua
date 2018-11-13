--Transitions

local g = require( "globalVariables" )
local cp = require( "composer" )
local ld = require( "localData" )
local bg = require( "backgrounds" )

local v = {}

--Precalls
local rot1, rot2
----------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------Center
--------------------------------------------------------------------------------
v.transInCenter = function( asc, logo, arrow, fb, twit, extras, settings, listener )
    
    
    local function finish( event )
        listener()
    end
    
    local function arrowCheck( event )
        if arrow.x ~= display.contentCenterX+17 then
            arrow.x = -arrow.width
            transition.to( arrow, { time=800, transition=easing.outQuad, x=display.contentCenterX+17, onComplete=arrowCheck } )
        end
    end
    
    transition.to( asc, { time=400, y=display.contentHeight-30, transition=easing.outQuad } )
    transition.to( logo, { time=700, y=0.2*display.contentHeight, transition=easing.outQuad, xScale=1, yScale=1--[[, rotation=0--]], onComplete=finish } )
    transition.to( fb, { time=700, x=display.contentCenterX - 80, transition=easing.outQuad } )
    transition.to( twit, { time=700, x=display.contentCenterX + 80, transition=easing.outQuad } )
    transition.to( extras, { time=600, x=0, y=display.contentHeight, transition=easing.outQuad } )
    transition.to( settings, { time=600, x=display.contentWidth, y=display.contentHeight, transition=easing.outQuad } )
    
    if g.justOpened then
        transition.to( arrow, { time=900, xScale=1, yScale=1, transition=easing.outBack } )
    elseif cp.getSceneName( "previous" ) == "game2" then
        arrow.x = g.arrowX
        transition.to( arrow, { time=1200, transition=easing.outBack, x=display.contentCenterX+17, y=display.contentCenterY, xScale=1, yScale=1, rotation=rot2 })
    else
        arrow.x = -arrow.width
        transition.to( arrow, { time=800, transition=easing.outQuad, x=display.contentCenterX+17, onComplete=arrowCheck } )
    end

    --Fade out the backgrounds from gameplay
    if ld.getChangingBackgroundsEnabled() then
        bg.fadeOutToDefault()
    end
    
end
--------------------------------------------------------------------------------
v.transOutCenter = function( asc, logo, arrow, fb, twit, extras, settings )
    
    
    local function startListener( event )
        arrow:setEnabled( false )
        fb:setEnabled( false )
        twit:setEnabled( false )
        extras:setEnabled( false )
        settings:setEnabled( false )
        
        print( "Transitions begun" )
    end
    
    local function finishListener( event )
        arrow:setEnabled( true )
        fb:setEnabled( true )
        twit:setEnabled( true )
        extras:setEnabled( true )
        settings:setEnabled( true )
        
        if g.goingToGame == true then
            cp.gotoScene( "game2" )
        elseif g.goingToExtras == true then
            cp.gotoScene( "extras" )
        elseif g.goingToSettings == true then
            cp.gotoScene( "settings" )
        end
        
        print( "Transitions complete" )
    end
    
    
    local a = math.random()
    if a < 0.5 then
        rot1 = arrow.rotation-90
        rot2 = 0--arrow.rotation+90
    else
        rot1 = arrow.rotation+270
        rot2 = 0--arrow.rotation-270
    end
    
    
    if g.goingToGame == true then
        
        transition.to( asc, { time=400, delay=800, y=display.contentHeight+50, transition=easing.inQuad } )
        transition.to( logo, { time=700, y=-logo.height, transition=easing.inQuad } )
        transition.to( arrow, { time=2000, transition=easing.inOutBack, x=display.contentCenterX, y=display.contentHeight-49.5, xScale=0.33, yScale=0.33, rotation=rot1, onStart=startListener, onComplete=finishListener })
        transition.to( fb, { time=700, delay=500, x=-fb.width, transition=easing.inQuad } )
        transition.to( twit, { time=700, delay=500, x=display.contentWidth+twit.width, transition=easing.inQuad } )
        transition.to( extras, { time=600, delay=800, x=-200, y=display.contentHeight+200, transition=easing.inQuad } )
        transition.to( settings, { time=600, delay=800, x=display.contentWidth+200, y=display.contentHeight+200, transition=easing.inQuad } )
        
    else
        
        transition.to( asc, { time=400, delay=400, y=display.contentHeight+50, transition=easing.inQuad } )
        transition.to( logo, { time=500, delay=300, y=display.topStatusBarContentHeight + 0.4 * logo.height, transition=easing.inQuad, xScale=0.47, yScale=0.47, rotation=0 } )
        transition.to( arrow, { time=800, transition=easing.inQuad, x=display.contentWidth+arrow.width, onStart=startListener, onComplete=finishListener } )
        transition.to( fb, { time=700, delay=100, x=-fb.width, transition=easing.inQuad } )
        transition.to( twit, { time=700, delay=100, x=display.contentWidth+twit.width, transition=easing.inQuad } )
        transition.to( extras, { time=600, delay=200, x=-200, y=display.contentHeight+200, transition=easing.inQuad } )
        transition.to( settings, { time=600, delay=200, x=display.contentWidth+200, y=display.contentHeight+200, transition=easing.inQuad } )
        
    end
    
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
------------------------------------------------------------------------Settings
--------------------------------------------------------------------------------
v.transInSettings = function( arrow, logo, lines, group1, group2, group3, group4, group5 )
    transition.to( arrow, { time=300, x=(logo.x-0.5*logo.width), transition=easing.outQuad } )
    transition.to( lines, { time=800, alpha=1, transition=easing.outQuad } )
    transition.to( group1, { time=600, x=0, transition=easing.outQuad } )
    transition.to( group2, { time=600, x=0, transition=easing.outQuad } )
    transition.to( group3, { time=600, x=0, transition=easing.outQuad } )
    transition.to( group4, { time=600, x=0, transition=easing.outQuad } )
    transition.to( group5, { time=600, x=0, transition=easing.outQuad } )
end
--------------------------------------------------------------------------------
v.transOutSettings = function( arrow, lineGroup, group1, group2, group3, group4, group5 )
    
    local function finish( event )
        cp.gotoScene( "center" )
    end
    
    transition.to( arrow, { time=300, x=-arrow.width, transition=easing.inQuad } )
    transition.to( lineGroup, { time=300, alpha=0, transition=easing.inQuad } )
    transition.to( group1, { time=600, x=display.contentWidth+0.5*group1.width, transition=easing.inQuad, onComplete=finish } )
    transition.to( group2, { time=600, x=-1.2*group2.width, transition=easing.inQuad } )
    transition.to( group3, { time=600, x=display.contentWidth+0.5*group3.width, transition=easing.inQuad } )
    transition.to( group4, { time=600, x=-1.2*group4.width, transition=easing.inQuad } )
    transition.to( group5, { time=600, x=display.contentWidth+0.5*group5.width, transition=easing.inQuad } )
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--------------------------------------------------------------------------Extras
--------------------------------------------------------------------------------
v.transInExtras = function( arrow, logo, r1, r2, r3, r4, r5, r6, listener )
    
    local function finish()
        listener()
    end
    
    transition.to( arrow, { time=300, x=(logo.x-0.5*logo.width), transition=easing.outQuad } )
    transition.to( r1, { time=400, xScale=1, yScale=1, transition=easing.outBack, onComplete=finish } )
    transition.to( r2, { time=400, xScale=1, yScale=1, transition=easing.outBack } )
    transition.to( r3, { time=400, xScale=1, yScale=1, transition=easing.outBack } )
    transition.to( r4, { time=400, xScale=1, yScale=1, transition=easing.outBack } )
    transition.to( r5, { time=400, xScale=1, yScale=1, transition=easing.outBack } )
    transition.to( r6, { time=400, xScale=1, yScale=1, transition=easing.outBack } )
end
--------------------------------------------------------------------------------
v.transInExtrasFromOther = function( r1, r2, r3, r4, r5, r6, coordinate, listener )

    local function finish()
        listener()
    end
    
    transition.to( r1, { time=400, x=coordinate, transition=easing.outSine, onComplete=listener } )
    transition.to( r3, { time=400, x=coordinate, transition=easing.outSine } )
    transition.to( r5, { time=400, x=coordinate, transition=easing.outSine } )
    transition.to( r2, { time=400, x=display.contentWidth - coordinate,transition=easing.outSine } )
    transition.to( r4, { time=400, x=display.contentWidth - coordinate, transition=easing.outSine } )
    transition.to( r6, { time=400, x=display.contentWidth - coordinate, transition=easing.outSine } )
end
--------------------------------------------------------------------------------
v.transOutExtras = function( arrow, r1, r2, r3, r4, r5, r6 )
    
    local function listener( event )
        cp.gotoScene( "center" )
    end
    
    transition.to( arrow, { time=300, x=-arrow.width, transition=easing.inQuad } )
    transition.to( r1, { time=400, xScale=0.001, yScale=0.001, transition=easing.inBack, onComplete=listener } )
    transition.to( r2, { time=400, xScale=0.001, yScale=0.001, transition=easing.inBack } )
    transition.to( r3, { time=400, xScale=0.001, yScale=0.001, transition=easing.inBack } )
    transition.to( r4, { time=400, xScale=0.001, yScale=0.001, transition=easing.inBack } )
    transition.to( r5, { time=400, xScale=0.001, yScale=0.001, transition=easing.inBack } )
    transition.to( r6, { time=400, xScale=0.001, yScale=0.001, transition=easing.inBack } )
end
--------------------------------------------------------------------------------
v.transOutExtrasOther = function( scene, r1, r2, r3, r4, r5, r6 )

    local function listener( event )
        cp.gotoScene( scene )
    end

    transition.to( r1, { time=400, x=-0.51*r1.width, transition=easing.inSine, onComplete=listener } )
    transition.to( r3, { time=400, x=-0.51*r3.width, transition=easing.inSine } )
    transition.to( r5, { time=400, x=-0.51*r5.width, transition=easing.inSine } )
    transition.to( r2, { time=400, x=display.contentWidth + 0.51*r2.width,transition=easing.inSine } )
    transition.to( r4, { time=400, x=display.contentWidth + 0.51*r4.width, transition=easing.inSine } )
    transition.to( r6, { time=400, x=display.contentWidth + 0.51*r6.width, transition=easing.inSine } )
end
--------------------------------------------------------------------------------
v.transInAboutASC = function( logo, logoX, line1, line2, asc, text, fb, twit )

    transition.to( logo, {time=500, x=logoX, transition=easing.outSine})
    transition.to( line1, {time=600, x=0, transition=easing.outSine})
    transition.to( line2, {time=600, x=0})
    transition.to( asc, {time=500, alpha=1})
    transition.to( text, {time=500, alpha=1})
    transition.to( fb, { time=600, x=display.contentCenterX - 80, transition=easing.outQuad } )
    transition.to( twit, { time=600, x=display.contentCenterX + 80, transition=easing.outQuad } )

end
--------------------------------------------------------------------------------
v.transOutAboutASC = function( logo, line1, line2, asc, text, fb, twit )

    local function listener( event )
        cp.gotoScene( "extras" )
    end

    transition.to( logo, {time=500, x=display.contentWidth+0.5*logo.width, transition=easing.inSine})
    transition.to( line1, {time=600, x=display.contentWidth, onComplete=listener})
    transition.to( line2, {time=600, x=-display.contentWidth})
    transition.to( asc, {time=500, alpha=0})
    transition.to( text, {time=500, alpha=0})
    transition.to( fb, { time=600, x=-120, transition=easing.outQuad } )
    transition.to( twit, { time=600, x=display.contentWidth+twit.width, transition=easing.outQuad } )

end
--------------------------------------------------------------------------------
v.transInAboutMusic = function( logo, logoX, line1, line2, jeg, text )

    transition.to( logo, {time=500, x=logoX, transition=easing.outSine})
    transition.to( line1, {time=600, x=0})
    transition.to( line2, {time=600, x=0})
    transition.to( jeg, {time=500, alpha=1})
    transition.to( text, {time=500, alpha=1})

end
--------------------------------------------------------------------------------
v.transOutAboutMusic = function( logo, line1, line2, jeg, text )

    local function listener( event )
        cp.gotoScene( "extras" )
    end

    transition.to( logo, {time=500, x=display.contentWidth+0.5*logo.width, transition=easing.inSine})
    transition.to( line1, {time=600, x=display.contentWidth, onComplete=listener})
    transition.to( line2, {time=600, x=-display.contentWidth})
    transition.to( jeg, {time=500, alpha=0})
    transition.to( text, {time=500, alpha=0})
end
--------------------------------------------------------------------------------
v.transInMarket = function( logo, logoX, topLine )

    transition.to( topLine, {time=500, strokeWidth=10})
    transition.to( logo, {time=500, x=logoX, transition=easing.outSine})

end
--------------------------------------------------------------------------------
v.transOutMarket = function( logo, topLine )

    local function listener( event )
        cp.gotoScene( "extras" )
    end

    transition.to( logo, {time=500, x=display.contentWidth+0.5*logo.width, transition=easing.inSine})
    transition.to( topLine, {time=500, strokeWidth=0, onComplete=listener})

end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
----------------------------------------------------------------------------Game
--------------------------------------------------------------------------------
v.buttonsIn = function( B, b1, b2, m )
    
    m.x = -0.5*m.width
    
    local function finish()
        B:setEnabled( true )
        b1:setEnabled( true )
        b2:setEnabled( true )
    end
    
    transition.to( B, { time=200, y=display.contentCenterY-0.5*B.height, transition=easing.outQuad, onComplete=finish } )
    transition.to( b1, { time=200, x=B.x-0.5*B.width, transition=easing.outQuad } )
    transition.to( b2, { time=200, x=B.x+0.5*B.width, transition=easing.outQuad } )
    transition.to( m, { time=200, x=display.contentCenterX, transition=easing.outQuad } )
    
end
--------------------------------------------------------------------------------
v.buttonsOut = function( B, b1, b2, m )
    
    B:setEnabled( false )
    b1:setEnabled( false )
    b2:setEnabled( false )
    
    local function listener1()
        m.text = "Game Paused"
        B:setLabel( "Resume" )
    end
    
    transition.to( B, { time=200, y=0, transition=easing.inQuad, onComplete=listener1 } )
    transition.to( b1, { time=200, x=-b1.width, transition=easing.inQuad } )
    transition.to( b2, { time=200, x=display.contentWidth+b2.width, transition=easing.inQuad } )
    transition.to( m, { time=200, x=display.contentWidth+0.5*m.width, transition=easing.outQuad } )
    
    return true
end
--------------------------------------------------------------------------------
v.countDown = function( b1, b2, b3, tr, func )
    
    b1.alpha, b2.alpha, b3.alpha = 0.2, 0.2, 0.2
    
    local function listener2()
        func()
        tr.fill = { 0, 0.65, 1 }
        tr.isVisible = false
    end
    
    b1.xScale, b1.yScale = 1, 1
    b2.xScale, b2.yScale = 1, 1
    b3.xScale, b3.yScale = 1, 1

    local function listener1()
        transition.to( b1, { time=200, delay=550, alpha=0, xScale=0, yScale=0, transition=easing.inBack } )
        transition.to( b2, { time=200, delay=550, alpha=0, xScale=0, transition=easing.inBack, yScale=0 } )
        transition.to( b3, { time=200, delay=550, alpha=0, xScale=0, transition=easing.inBack, yScale=0 } )
        transition.to( tr, { time=200, delay=550, alpha=0, onComplete=listener2 } )
    end
    
    transition.to( b1, { time=50, delay=750, alpha=1 } )
    transition.to( b2, { time=50, delay=1500, alpha=1 } )
    transition.to( b3, { time=50, delay=2250, alpha=1, onComplete=listener1 } )
    
end
--------------------------------------------------------------------------------
v.gameOverStatsIn = function( fill, t1, t2, t3, t4, l1, l2, l3, scr, tm, highs, hight, twit, fb ) 
    
    t2.text = " "..scr.text
    t4.text = " "..tm.text
    
    transition.to( fill, { time=200, y=g.statsFocal, transition=easing.inQuad } )
    transition.to( t1, { time=200, x=display.contentCenterX, transition=easing.inQuad } )
    transition.to( t2, { time=200, x=display.contentCenterX, transition=easing.inQuad } )
    transition.to( t3, { time=200, x=display.contentCenterX, transition=easing.inQuad } )
    transition.to( t4, { time=200, x=display.contentCenterX, transition=easing.inQuad } )
    transition.to( l1, { time=200, alpha=1 } )
    transition.to( l2, { time=200, alpha=1 } )
    transition.to( l3, { time=200, alpha=1 } )
    transition.to( highs, { time=200, y=g.statsFocal + g.statsAreaH*0.75, transition=easing.inQuad } )
    transition.to( hight, { time=200, y=g.statsFocal + g.statsAreaH*0.75, transition=easing.inQuad } )
    transition.to( twit, { time=200, y=g.statsFocal+0.5*g.statsAreaH, transition=easing.inQuad } )
    transition.to( fb, { time=100, delay=100, y=display.contentHeight, transition=easing.inQuad } )
    
end
--------------------------------------------------------------------------------
v.gameOverStatsOut = function( fill, t1, t2, t3, t4, l1, l2, l3, scr, tm, highs, hight, twit, fb )
    
    transition.to( fill, { time=200, y=display.contentHeight, transition=easing.inQuad } )
    transition.to( t1, { time=100, delay=100, x=0, transition=easing.inQuad } )
    transition.to( t2, { time=100, delay=100, x=display.contentWidth, transition=easing.inQuad } )
    transition.to( t3, { time=100, delay=100, x=0, transition=easing.inQuad } )
    transition.to( t4, { time=100, delay=100, x=display.contentWidth, transition=easing.inQuad } )
    transition.to( l1, { time=200, alpha=0 } )
    transition.to( l2, { time=200, alpha=0 } )
    transition.to( l3, { time=200, alpha=0 } )
    transition.to( highs, { time=200, y=display.contentHeight+0.5*highs.height, transition=easing.inQuad } )
    transition.to( hight, { time=200, y=display.contentHeight+0.5*hight.height, transition=easing.inQuad } )
    transition.to( twit, { time=150, delay=50, y=display.contentHeight+twit.height, transition=easing.inQuad } )
    transition.to( fb, { time=200, y=display.contentHeight+fb.height, transition=easing.inQuad } )
    
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return v
