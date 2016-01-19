%Extension of Turing's font library
%By: Kevin Wang
module * Fonts
    export ~.*AlignX, ~.*AlignY, isInstalled, getHeight, render, renderVec

    %PUBLIC VARIABLES-----------------
    type AlignX : enum (left, center, right)
    type AlignY : enum (bottom, center, top)

    %Checks if a font is installed, must pass a font name as parameter
    fcn isInstalled (style : string) : boolean
	var fontFamily : string
	Font.StartName
	loop
	    fontFamily := Font.GetName
	    if fontFamily = style then
		result true
	    elsif fontFamily = "" then
		result false
	    end if
	end loop
    end isInstalled

    %Custom made Font Height finder and is extrememly accurate
    fcn getHeight (font : int) : int
	var height, internalLeading, dummy : int
	var externalLeading : int
	Font.Sizes (font, height, dummy, dummy, internalLeading)
	var temp := height - internalLeading
	result round (temp - (temp / 4))
    end getHeight

    %Custom Font.Draw with much more capabilities
    proc render (text : string, x1, y1, x2, y2 : real, a1 : AlignX, a2 : AlignY,
	    font : int, colr : ^Colr)
	var drawX := x1
	var drawY := y1
	if a1 = AlignX.center then
	    drawX := (x1 + x2 - Font.Width (text, font)) / 2
	elsif a1 = AlignX.right then
	    drawX := x2 - Font.Width (text, font)
	end if
	if a2 = AlignY.center then
	    drawY := (y1 + y2 - getHeight (font)) / 2
	elsif a2 = AlignY.top then
	    drawY := y2 - getHeight (font)
	end if
	Font.Draw (text, drawX div 1, drawY div 1, font, Color.use (colr))
    end render

    proc renderVec (text : string, p1, p2 : ^Vector, a1 : AlignX, a2 : AlignY,
	    font : int, colr : ^Colr)
	render (text, p1 -> x, p1 -> y, p2 -> x, p2 -> y, a1, a2, font, colr)
    end renderVec
end Fonts
