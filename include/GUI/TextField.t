%Text Field class
%By: Kevin Wang
class TextField
    inherit HoverableWidget
    import Input
    export initFull, initFast, getString, checkSubmitted

    %PRIVATE VARIABLES-----------------
    var textCoor : ^Vector
    var xPadding, yPadding : int
    var borderTransition : Transition
    var borderColr : TransitionColor
    var selectionColr : ^Colr
    var selectionStart, selectionEnd : int
    var active : boolean
    var maxChar : int

    proc initFull (boxPoint1, boxPoint2 : ^Vector, xPadding_, yPadding_ : int, startColr_, endColr_, selectionColr_, boxStartColr_, boxEndColr_ : ^Colr, increments_ : int,
	    text_ : string, maxChar_ : int, textStartColr_, textEndColr_ : ^Colr, font_ : int)
	boxCoor1 := boxPoint1
	boxCoor2 := boxPoint2
	xPadding := xPadding_
	yPadding := yPadding_
	boxColr.start := startColr_
	boxColr.finish := endColr_
	selectionColr := selectionColr_
	borderColr.start := boxStartColr_
	borderColr.finish := boxEndColr_
	borderTransition.increments := increments_
	if borderTransition.increments <= 0 then %dividing by 0 later will cause error therefore needs to be fixed here
	    borderTransition.increments := 1
	end if
	borderTransition.incrementCounter := 0
	borderTransition.rChange := (borderColr.finish -> r - borderColr.start -> r) / borderTransition.increments
	borderTransition.gChange := (borderColr.finish -> g - borderColr.start -> g) / borderTransition.increments
	borderTransition.bChange := (borderColr.finish -> b - borderColr.start -> b) / borderTransition.increments
	borderTransition.colr := borderColr.start
	text := text_
	maxChar := maxChar_
	textColr.start := textStartColr_
	textColr.finish := textEndColr_
	font := font_
	textCoor := Vectors.newXY (boxCoor1 -> x + xPadding, (boxCoor1 -> y + boxCoor2 -> y - Fonts.getHeight (font)) / 2)
	selectionStart := 0
	selectionEnd := 0
	active := false
    end initFull

    proc initFast (boxPoint1, boxPoint2 : ^Vector, text_ : string, font_ : int)
	boxCoor1 := boxPoint1
	boxCoor2 := boxPoint2
	text := text_
	font := font_
	xPadding := 3
	yPadding := 5
	boxColr.start := White
	boxColr.finish := White
	selectionColr := Color.construct (51 / 255, 153 / 255, 255 / 255)
	borderColr.start := Color.construct (115 / 255, 125 / 255, 115 / 255)
	borderColr.finish := Black
	borderTransition.increments := 20
	borderTransition.incrementCounter := 0
	borderTransition.rChange := (borderColr.finish -> r - borderColr.start -> r) / borderTransition.increments
	borderTransition.gChange := (borderColr.finish -> g - borderColr.start -> g) / borderTransition.increments
	borderTransition.bChange := (borderColr.finish -> b - borderColr.start -> b) / borderTransition.increments
	borderTransition.colr := borderColr.start
	maxChar := 255
	textColr.start := Black
	textColr.finish := Black
	textCoor := Vectors.newXY (boxCoor1 -> x + xPadding, (boxCoor1 -> y + boxCoor2 -> y - Fonts.getHeight (font)) / 2)
	selectionStart := 0
	selectionEnd := 0
	active := false
    end initFast

    fcn getString : string
	result text
    end getString

    fcn checkSubmitted : boolean
	result nowState (KEY_ENTER)
    end checkSubmitted

    proc wordPosition
	var selectionPosition := Font.Width (text (1 .. * +selectionEnd), font) + textCoor -> x
	if selectionPosition > boxCoor2 -> x div 1 - xPadding then
	    selectionPosition := (boxCoor2 -> x div 1 - xPadding) div 1
	elsif selectionPosition < boxCoor1 -> x div 1 + xPadding then
	    selectionPosition := (boxCoor1 -> x div 1 + xPadding) div 1
	end if
	textCoor -> setX (selectionPosition - Font.Width (text (1 .. * +selectionEnd), font))
    end wordPosition

    fcn determinePosition : int
	for i : 1 .. length (text)
	    var charposition := Font.Width (text (1 .. i), font) + textCoor -> x div 1
	    var characterlength := Font.Width (text (i), font)
	    if i = 1 then
		if mouseState.x <= charposition - characterlength div 2 then
		    result - length (text)
		end if
	    elsif i = length (text) then
		if mouseState.x >= charposition then
		    result 0
		end if
	    end if
	    if mouseState.x <= charposition and mouseState.x > charposition - characterlength div 2 then
		result - (length (text) - i)
	    elsif mouseState.x <= charposition - characterlength div 2 and mouseState.x >= charposition - characterlength then
		result - (length (text) - i) - 1
	    end if
	end for
	result 0
    end determinePosition

    proc inputUpdate (ch : string (1))
	if ch = KEY_BACKSPACE and (length (text (1 .. * +selectionStart)) > 0 or selectionStart ~= selectionEnd) then
	    if selectionStart ~= selectionEnd then
		text := text (1 .. * +min (selectionStart, selectionEnd)) + text (* +max (selectionStart, selectionEnd) + 1 .. *)
		selectionStart := max (selectionStart, selectionEnd)
		selectionEnd := selectionStart
	    else
		text := text (1 .. * +selectionStart - 1) + text (* +selectionStart + 1 .. *)
	    end if
	elsif ch = KEY_DELETE and (length (text (* +selectionStart + 1 .. *)) > 0 or selectionStart ~= selectionEnd) then
	    if selectionStart ~= selectionEnd then
		text := text (1 .. * +min (selectionStart, selectionEnd)) + text (* +max (selectionStart, selectionEnd) + 1 .. *)
		selectionStart := max (selectionStart, selectionEnd)
		selectionEnd := selectionStart
	    else
		selectionStart += 1
		selectionEnd += 1
		text := text (1 .. * +selectionStart - 1) + text (* +selectionStart + 1 .. *)
	    end if
	elsif ch = KEY_ENTER then
	    active := false
	elsif ch >= ' ' and ch <= '~' then
	    if selectionStart ~= selectionEnd then
		text := text (1 .. * +min (selectionStart, selectionEnd)) + ch + text (* +max (selectionStart, selectionEnd) + 1 .. *)
		selectionStart := max (selectionStart, selectionEnd)
		selectionEnd := selectionStart
	    elsif length (text) < maxChar then
		text := text (1 .. * +selectionStart) + ch + text (* +selectionStart + 1 .. *)
	    end if
	elsif ch = KEY_LEFT_ARROW and (length (text (1 .. * +selectionStart)) > 0 or selectionStart ~= selectionEnd) then
	    if selectionStart ~= selectionEnd then
		selectionStart := min (selectionStart, selectionEnd)
		selectionEnd := selectionStart
	    else
		selectionStart -= 1
		selectionEnd -= 1
		text := text (1 .. * +selectionStart) + text (* +selectionStart + 1 .. *)
	    end if
	elsif ch = KEY_RIGHT_ARROW and (length (text (* +selectionStart + 1 .. *)) > 0 or selectionStart ~= selectionEnd) then
	    if selectionStart ~= selectionEnd then
		selectionStart := max (selectionStart, selectionEnd)
		selectionEnd := selectionStart
	    else
		selectionStart += 1
		selectionEnd += 1
		text := text (1 .. * +selectionStart) + text (* +selectionStart + 1 .. *)
	    end if
	end if
    end inputUpdate

    body proc update
	if clicked (MouseState.left) then
	    if inRectVec (boxCoor1, boxCoor2) then
		if ~active then
		    active := true
		    Input.Flush
		end if
		selectionStart := determinePosition
		selectionEnd := determinePosition
	    else
		active := false
	    end if
	elsif clicking (MouseState.left) then
	    if active then
		selectionEnd := determinePosition
	    end if
	end if
	if doubleClick (300) then
	    selectionStart := -length (text)
	    selectionEnd := 0
	end if
	if active then
	    inputUpdate (ch)
	end if
	wordPosition
	borderTransition := updateTransitionColor (borderTransition, borderColr)
    end update

    body proc render
	if active then
	    Draw.FillBox (boxCoor1 -> x div 1, boxCoor1 -> y div 1, boxCoor2 -> x div 1, boxCoor2 -> y div 1, boxColr.start -> id)
	else
	    if inRectVec (boxCoor1, boxCoor2) then
		Draw.FillBox (boxCoor1 -> x div 1, boxCoor1 -> y div 1, boxCoor2 -> x div 1, boxCoor2 -> y div 1, boxColr.finish -> id)
	    else
		Draw.FillBox (boxCoor1 -> x div 1, boxCoor1 -> y div 1, boxCoor2 -> x div 1, boxCoor2 -> y div 1, boxColr.start -> id)
	    end if
	end if
	Draw.Box (boxCoor1 -> x div 1, boxCoor1 -> y div 1, boxCoor2 -> x div 1, boxCoor2 -> y div 1, Color.use (borderTransition.colr))
	View.ClipSet (boxCoor1 -> x div 1 + xPadding, boxCoor1 -> y div 1, boxCoor2 -> x div 1 - xPadding + 1, boxCoor2 -> y div 1)
	if active then
	    if selectionStart ~= selectionEnd then
		Draw.FillBox (textCoor -> x div 1 + Font.Width (text (1 .. * +selectionStart), font), boxCoor1 -> y div 1 + yPadding, textCoor -> x div 1 + Font.Width (text (1 .. * +selectionEnd),
		    font),
		    boxCoor2 -> y div 1 - yPadding, selectionColr -> id)
	    else
		if Time.Elapsed div 500 mod 2 = 0 then
		    Draw.Line (Font.Width (text (1 .. * +selectionStart), font) + textCoor -> x div 1, boxCoor1 -> y div 1 + yPadding, Font.Width (text (1 .. * +selectionStart), font) + textCoor -> x
			div 1,
			boxCoor2 -> y div 1 - yPadding, textColr.start -> id)
		end if
	    end if
	    Font.Draw (text, textCoor -> x div 1, textCoor -> y div 1, font, textColr.start -> id)
	elsif inRectVec (boxCoor1, boxCoor2) then
	    Font.Draw (text, textCoor -> x div 1, textCoor -> y div 1, font, textColr.finish -> id)
	else
	    Font.Draw (text, textCoor -> x div 1, textCoor -> y div 1, font, textColr.start -> id)
	end if
	View.ClipOff
    end render
end TextField
