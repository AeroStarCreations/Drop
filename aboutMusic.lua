local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "globalVariables" )
local t = require( "transitions" )
local GGTwitter = require( "GGTwitter" )


--Precalls
local drop
local backArrow
local jeg
local lineTop
local lineBottom
local bio
----------


function scene:create( event )

    local group = self.view
    
    g.create()
    
    ------------------------------------------Logo
    drop = display.newImageRect( "images/name.png", 1020, 390 )
    local dropRatio = drop.height/drop.width
    drop.width = 0.77*display.contentWidth; drop.height = drop.width*dropRatio
    drop.x, drop.y = display.contentCenterX, 0.06*display.contentHeight+1
    drop.xScale, drop.yScale = 0.47, 0.47
    group:insert(drop)
    ----------------------------------------------
    
    ------------------------------------Back Arrow
    local function baf( event )
        t.transOutAboutMusic( musicLogo, lineTop, lineBottom, jeg, bio )
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
    backArrow.x = drop.x-0.5*drop.width
    backArrow.y = drop.y - 7
    group:insert(backArrow)
    ----------------------------------------------

    ------------------------------------Music Logo
    musicLogo = display.newImageRect( group, "images/logoMusic.png", 66, 66 )
    musicLogo.width, musicLogo.height = 0.45*drop.height, 0.45*drop.height
    musicLogo.x = display.contentWidth + 0.5*musicLogo.width
    musicLogo.y = backArrow.y + 10
    musicLogoX = drop.x + 0.5*drop.contentWidth + 0.5*(display.contentWidth - drop.x - 0.5*drop.contentWidth)
    ----------------------------------------------

    ----------------------"Jeffrey Emerson Gaiser"
    jeg = display.newText( group, "Jeffrey Emerson Gaiser", display.contentCenterX, 0, g.comBold, 70, "center")
    jeg:setFillColor( unpack(g.purple) )
    jeg.y = 2*drop.y + 0.5*jeg.height
    while jeg.width > 0.95 * display.contentWidth do
        jeg.size = jeg.size - 0.5
    end
    jeg.alpha = 0
    ----------------------------------------------

    -----------------------------------------Lines
    lineTop = display.newLine( group, 0, drop.y*2, display.contentWidth, drop.y*2 )
    lineTop:setStrokeColor( unpack( g.purple ) )
    lineTop.strokeWidth = 2
    lineTop.x = -display.contentWidth

    lineBottom = display.newLine( group, 0, lineTop.y+2*(jeg.y-lineTop.y), display.contentWidth, lineTop.y+2*(jeg.y-lineTop.y) )
    lineBottom:setStrokeColor( unpack( g.purple ) )
    lineBottom.strokeWidth = 2
    lineBottom.x = display.contentWidth
    ----------------------------------------------

    ------------------------------------------Text
    bio = display.newText( group, "Joe Shmoe", display.contentCenterX, lineBottom.y, 0.9*display.contentWidth, 0, g.comRegular, 30, "center")
    bio:setFillColor( 0, 0, 0 )
    bio.anchorY = 0
    bio.text = "\n\n\tJeffrey Emerson Gaiser is an award-winning composer who specializes in working with film, video games, and other visual media. Jeffrey has scored numerous independent short films, games, and advertisements—garnering universal acclaim and millions of views on projects such as Masque; a finalist in Lionsgate’s The Storytellers: New Voices of the Twilight Saga competition. While attending the prestigious Berklee College of Music in Boston, Massachusetts, Jeffrey was also the Grand Prize-Winning Composer for Berklee’s own Scoring and Sound Design Contest two years in a row, and his work has been heard in festivals around the globe including The Cannes Film Festival, The Cleveland International Film Festival, and the Boston Science Fiction Film Festival."
    bio.alpha = 0
    ----------------------------------------------

    --------------------------------Social Buttons
    
    ----------------------------------------------
end


function scene:show( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.show()
        
        t.transInAboutMusic( musicLogo, musicLogoX, lineTop, lineBottom, jeg, bio )

    end
end


function scene:hide( event )

    local group = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
        g.hide()
        
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