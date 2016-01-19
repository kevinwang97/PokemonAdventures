%Hover button that increments box color
%By: Kevin Wang
class HoverButton
    inherit HoverableWidget
    export initFull, initFast

    %PRIVATE VARIABLES-----------------
    var boxTrans : Transition

    proc initFull (boxPoint1, boxPoint2 : ^Vector, text_ : string, font_ : int, textStartColr_, textEndColr_, startColr_, endColr_ : ^Colr, increments_ : int)
	boxCoor1 := boxPoint1
	boxCoor2 := boxPoint2
	text := text_
	font := font_
	textColr.start := textStartColr_
	textColr.finish := textEndColr_
	boxColr.start := startColr_
	boxColr.finish := endColr_
	boxTrans.increments := increments_
	boxTrans.incrementCounter := 0
	boxTrans.rChange := (boxColr.finish -> r - boxColr.start -> r) / boxTrans.increments
	boxTrans.gChange := (boxColr.finish -> g - boxColr.start -> g) / boxTrans.increments
	boxTrans.bChange := (boxColr.finish -> b - boxColr.start -> b) / boxTrans.increments
	boxTrans.colr := boxColr.start
    end initFull

    proc initFast (boxPoint1, boxPoint2 : ^Vector, text_ : string, font_ : int, textColr_, startColr_, endColr_ : ^Colr)
	boxCoor1 := boxPoint1
	boxCoor2 := boxPoint2
	text := text_
	font := font_
	textColr.start := textColr_
	textColr.finish := textColr_
	boxColr.start := startColr_
	boxColr.finish := endColr_
	boxTrans.increments := 20
	boxTrans.incrementCounter := 0
	boxTrans.rChange := (boxColr.finish -> r - boxColr.start -> r) / boxTrans.increments
	boxTrans.gChange := (boxColr.finish -> g - boxColr.start -> g) / boxTrans.increments
	boxTrans.bChange := (boxColr.finish -> b - boxColr.start -> b) / boxTrans.increments
	boxTrans.colr := boxColr.start
    end initFast

    body proc update
	boxTrans := updateTransitionColor (boxTrans, boxColr)
    end update

    body proc render
	Draw.FillBox (boxCoor1 -> x div 1, boxCoor1 -> y div 1, boxCoor2 -> x div 1, boxCoor2 -> y div 1, Color.use (boxTrans.colr))
	Draw.Box (boxCoor1 -> x div 1, boxCoor1 -> y div 1, boxCoor2 -> x div 1, boxCoor2 -> y div 1, Black -> id)
	if inRectVec (boxCoor1, boxCoor2) then
	    Fonts.renderVec (text, boxCoor1, boxCoor2, AlignX.center, AlignY.center, font, textColr.finish)
	else
	    Fonts.renderVec (text, boxCoor1, boxCoor2, AlignX.center, AlignY.center, font, textColr.start)
	end if
    end render
end HoverButton
