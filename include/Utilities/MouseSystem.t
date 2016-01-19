%Mouse Module
%By: Kevin Wang
module * MouseSystem
    export ~.*MouseState, Mouse, ~.*mouseState, ~.*prevMouseState, initialize,
	~.*released, ~.*clicked, ~.*clicking,
	~.*doubleClick, update, ~.*inRect, ~.*inOval, ~.*inRectVec, ~.*inOvalVec

    %PUBLIC VARIABLES-----------------
    type * MouseState : enum (left, middle, right)
    type Mouse :
	record
	    x, y, b, lastReleased : int
	end record
    var mouseState, prevMouseState : Mouse

    %Initialization of mouse properties, MUST be initialized
    proc initialize
	mousewhere (mouseState.x, mouseState.y, mouseState.b)
	mouseState.lastReleased := -9999
    end initialize

    %Checks if a mouse button is released
    fcn released (s : MouseState) : boolean
	if s = MouseState.left then
	    result mouseState.b = 0 and prevMouseState.b = 1
	elsif s = MouseState.middle then
	    result mouseState.b = 0 and prevMouseState.b = 10
	elsif s = MouseState.right then
	    result mouseState.b = 0 and prevMouseState.b = 100
	end if
    end released

    %Checks if a mouse button is clicked
    fcn clicked (s : MouseState) : boolean
	if s = MouseState.left then
	    result mouseState.b = 1 and prevMouseState.b = 0
	elsif s = MouseState.middle then
	    result mouseState.b = 10 and prevMouseState.b = 0
	elsif s = MouseState.right then
	    result mouseState.b = 100 and prevMouseState.b = 0
	end if
    end clicked

    %Checks if a mouse button is still clicking
    fcn clicking (s : MouseState) : boolean
	if s = MouseState.left then
	    result mouseState.b = 1 and prevMouseState.b = 1
	elsif s = MouseState.middle then
	    result mouseState.b = 10 and prevMouseState.b = 10
	elsif s = MouseState.right then
	    result mouseState.b = 100 and prevMouseState.b = 100
	end if
    end clicking

    %Updates mouse
    proc update
	prevMouseState := mouseState
	mousewhere (mouseState.x, mouseState.y, mouseState.b)
	if released (MouseState.left) then
	    mouseState.lastReleased := Time.Elapsed
	end if
    end update

    %Checks if left button was double clicked within time period
    fcn doubleClick (delay : int) : boolean
	result released (MouseState.left) and
	    Time.Elapsed - prevMouseState.lastReleased <= delay
    end doubleClick

    %Checks if mouse is in a rectangle
    fcn inRect (x1, y1, x2, y2 : real) : boolean
	result mouseState.x > x1 and mouseState.x < x2
	    and mouseState.y > y1 and mouseState.y < y2
    end inRect

    fcn inRectVec (p1, p2 : ^Vector) : boolean
	result inRect (p1 -> x, p1 -> y, p2 -> x, p2 -> y)
    end inRectVec

    %Checks if mouse is in an oval
    fcn inOval (x, y : real, xRadius, yRadius : int) : boolean
	result sqrt ((mouseState.x - x) ** 2 / xRadius ** 2 +
	    (mouseState.y - y) ** 2 / yRadius ** 2) <= 1
    end inOval

    fcn inOvalVec (p : ^Vector, xRadius, yRadius : int) : boolean
	result inOval (p -> x, p -> y, xRadius, yRadius)
    end inOvalVec
end MouseSystem
