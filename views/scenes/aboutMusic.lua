local controller = require( "controllers.aboutMusicController" )
local cp = require( "composer" )
local scene = cp.newScene()
local widget = require( "widget" )
local g = require( "other.globalVariables" )
local logoModule = require( "other.logoModule" )
local fonts = require("other.fonts")
local colors = require("other.colors")

function scene:create( event )

    local group = self.view
    
    g.create()
    
    ------------------------------------------Logo
    local drop = logoModule.getSmallLogo(group)
    ----------------------------------------------
    
    ------------------------------------Back Arrow
    local backArrow = widget.newButton{
        id = "backArrow",
        x = 90,
        y = 0,
        width = 100*g.arrowRatio,
        height = 100,
        defaultFile = "images/arrow.png",
        overFile = "images/arrowD.png",
        onRelease = controller.backArrowListener,
    }
    backArrow.rotation = 180
    backArrow.x = 0.4 * (drop.x - 0.5 * drop.width)
    backArrow.y = drop.y + 0.5 * drop.height
    group:insert(backArrow)
    ----------------------------------------------

    ------------------------------------Music Logo
    local musicLogo = display.newImageRect( group, "images/logoMusic.png", 66, 66 )
    musicLogo.height = backArrow.height
    musicLogo.width = musicLogo.height
    musicLogo.xIn = drop.x + 0.5*drop.contentWidth + 0.5*(display.contentWidth - drop.x - 0.5*drop.contentWidth)
    musicLogo.xOut = display.contentWidth+0.5*musicLogo.width
    musicLogo.x = musicLogo.xOut
    musicLogo.y = backArrow.y
    controller.linkMusicLogo(musicLogo)
    ----------------------------------------------

    ----------------------"Jeffrey Emerson Gaiser"
    local jeg = display.newText( group, "Jeffrey Emerson Gaiser", display.contentCenterX, 0, fonts.getBold(), 70, "center")
    jeg:setFillColor( colors.purple:unpack() )
    jeg.y = drop.y + drop.height + 0.7 * jeg.height
    while jeg.width > 0.95 * display.contentWidth do
        jeg.size = jeg.size - 0.5
    end
    jeg.alphaIn = 1
    jeg.alphaOut = 1
    jeg.alpha = jeg.alphaOut
    controller.linkJEG(jeg)
    ----------------------------------------------

    -----------------------------------------Lines
    local lineTopY = jeg.y - 0.5 * jeg.height
    local lineTop = display.newLine( group, 0, lineTopY, display.contentWidth, lineTopY )
    lineTop:setStrokeColor( colors.purple:unpack() )
    lineTop.strokeWidth = 2
    lineTop.xIn = 0
    lineTop.xOut = display.contentWidth
    lineTop.x = -display.contentWidth
    controller.linkLineTop(lineTop)

    local lineBottomY = lineTopY + jeg.height
    local lineBottom = display.newLine( group, 0, lineBottomY, display.contentWidth, lineBottomY )
    lineBottom:setStrokeColor( colors.purple:unpack() )
    lineBottom.strokeWidth = 2
    lineBottom.xIn = 0
    lineBottom.xOut = -display.contentWidth
    lineBottom.x = display.contentWidth
    controller.linkLineBottom(lineBottom)
    ----------------------------------------------

    ------------------------------------------Text
    local bio = display.newText( group, "Joe Shmoe", display.contentCenterX, lineBottom.y, 0.9*display.contentWidth, 0, fonts.getRegular(), 30, "center")
    bio:setFillColor( 0, 0, 0 )
    bio.anchorY = 0
    bio.text = "\n\n\tJeffrey Emerson Gaiser is an award-winning composer who specializes in working with film, video games, and other visual media. Jeffrey has scored numerous independent short films, games, and advertisements—garnering universal acclaim and millions of views on projects such as Masque; a finalist in Lionsgate’s The Storytellers: New Voices of the Twilight Saga competition. While attending the prestigious Berklee College of Music in Boston, Massachusetts, Jeffrey was also the Grand Prize-Winning Composer for Berklee’s own Scoring and Sound Design Contest two years in a row, and his work has been heard in festivals around the globe including The Cannes Film Festival, The Cleveland International Film Festival, and the Boston Science Fiction Film Festival."
    bio.alphaIn = 1
    bio.alphaOut = 0
    bio.alpha = bio.alphaOut
    controller.linkBio(bio)
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
        
        controller.transitionIn()

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