%Abstract parent class for active widgets
%By: Kevin Wang
class ActiveWidget
    export selected, update, render

    %PRIVATE VARIABLES-----------------
    type TransitionColor :
	record
	    start, finish : ^Colr
	end record
    var text : string
    var font : int
    var boxCoor1, boxCoor2 : ^Vector
    var boxColr, textColr : TransitionColor

    %Returns if user clicked on widget
    fcn selected : boolean
	result inRectVec (boxCoor1, boxCoor2) and released (MouseState.left)
    end selected

    deferred proc update
    deferred proc render
end ActiveWidget
