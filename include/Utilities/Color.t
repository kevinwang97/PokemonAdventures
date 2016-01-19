%Color Module
%By: Kevin Wang
%Some color names begin with a capital as keyword was taken already
module * Color
    export ~.*Colr, numCreated, constructNotSaved, construct, use, destruct,
	mixColorNotSaved, mixColorSaved, getNotSaved, getSaved,
	~.*Black, ~.*White, ~.*Red, ~.*Green, ~.*Blue, ~.*Yellow, ~.*babyBlue,
	~.*Magenta, ~.*Purple, ~.*Orange, ~.*Grey

    %PUBLIC VARIABLES-----------------
    type Colr :
	record
	    r, g, b : real
	    id : int
	end record
    %PRIVATE VARIABLES-----------------
    var numColors := 0

    %Does not exclude deleted colors, returns number of colors created
    fcn numCreated : int
	result numColors
    end numCreated

    %Creating a color with no id
    fcn constructNotSaved (r, g, b : real) : ^Colr
	var c : ^Colr
	new c
	c -> r := r
	c -> g := g
	c -> b := b
	result c
    end constructNotSaved

    %Need to call this function to use an unsaved color
    fcn use (c : ^Colr) : int
	RGB.SetColor (255, c -> r, c -> g, c -> b)
	result 255
    end use

    %Saving a color to an id
    fcn construct (r, g, b : real) : ^Colr
	if numColors = 254 then %255 is reserved for non saved Colors
	    Error.Halt ("Reached max colors allowed to save")
	end if
	var c := constructNotSaved (r, g, b)
	c -> id := numColors
	numColors += 1
	RGB.SetColor (c -> id, c -> r, c -> g, c -> b)
	result c
    end construct

    %DIRTY - only use to replace deleted colors
    fcn constructSaveId (id : int, r, g, b : real) : ^Colr
	var c := constructNotSaved (r, g, b)
	c -> id := id
	RGB.SetColor (c -> id, c -> r, c -> g, c -> b)
	result c
    end constructSaveId

    %Mixing
    fcn mixColorNotSaved (c1, c2 : ^Colr, percentage : real) : ^Colr
	result constructNotSaved (c1 -> r * percentage + c2 -> r * (1 - percentage),
	    c1 -> g * percentage + c2 -> g * (1 - percentage),
	    c1 -> b * percentage + c2 -> b * (1 - percentage))
    end mixColorNotSaved

    fcn mixColorSaved (c1, c2 : ^Colr, percentage : real) : ^Colr
	result construct (c1 -> r * percentage + c2 -> r * (1 - percentage),
	    c1 -> g * percentage + c2 -> g * (1 - percentage),
	    c1 -> b * percentage + c2 -> b * (1 - percentage))
    end mixColorSaved

    %Retrieving color information
    fcn getNotSaved (c : int) : ^Colr
	var h : ^Colr
	new h
	RGB.GetColor (c, h -> r, h -> g, h -> b)
	result constructNotSaved (h -> r, h -> g, h -> b)
    end getNotSaved

    fcn getSaved (c : int) : ^Colr
	var h : ^Colr
	new h
	RGB.GetColor (c, h -> r, h -> g, h -> b)
	result construct (h -> r, h -> g, h -> b)
    end getSaved

    %Deleting color leaves the previous color
    proc destruct (c : ^Colr)
	var h := c
	free h
    end destruct

    %Predefined Colors
    var Black := construct (0, 0, 0)
    var White := construct (1, 1, 1)
    var Red := construct (1, 0, 0)
    var Green := construct (0, 1, 0)
    var Blue := construct (0, 0, 1)
    var Yellow := construct (1, 1, 0)
    var babyBlue := construct (0, 1, 1)
    var Magenta := construct (1, 0, 1)
    var Purple := construct (0.5, 0, 0.5)
    var Orange := construct (1, 0.5, 0)
    var Grey := construct (0.5, 0.5, 0.5)
end Color
