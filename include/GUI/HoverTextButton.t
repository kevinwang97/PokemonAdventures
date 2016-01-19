%Hover button that increments text color
%By: Kevin Wang
class HoverTextButton
    inherit HoverableWidget
    export initFull

    %PRIVATE VARIABLES-----------------
    var textTrans : Transition

    proc initFull (boxPoint1, boxPoint2 : ^Vector, text_ : string, font_ : int, textStartColr_, textEndColr_ : ^Colr, increments_ : int)
	boxCoor1 := boxPoint1
	boxCoor2 := boxPoint2
	text := text_
	font := font_
	textColr.start := textStartColr_
	textColr.finish := textEndColr_
	textTrans.increments := increments_
	if textTrans.increments <= 0 then %dividing by 0 later will cause error therefore needs to be fixed here
	    textTrans.increments := 1
	end if
	textTrans.incrementCounter := 0
	textTrans.rChange := (textColr.finish -> r - textColr.start -> r) / textTrans.increments
	textTrans.gChange := (textColr.finish -> g - textColr.start -> g) / textTrans.increments
	textTrans.bChange := (textColr.finish -> b - textColr.start -> b) / textTrans.increments
	textTrans.colr := textColr.start
    end initFull

    body proc update
	textTrans := updateTransitionColor (textTrans, textColr)
    end update

    body proc render
	Fonts.renderVec (text, boxCoor1, boxCoor2, AlignX.center, AlignY.center, font, textTrans.colr)
    end render
end HoverTextButton
