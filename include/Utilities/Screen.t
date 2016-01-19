%Screen Module
%By: Kevin Wang
module Screen
    export ~.*FPS, ~.*WIDTH, ~.*HEIGHT, ~.*SCALE, ~.*MAXX, ~.*MAXY,
	setInit

    %PUBLIC VARIABLES-----------------
    const FPS := 60
    const WIDTH := 480
    const HEIGHT := WIDTH div 16 * 9
    const SCALE := 2
    const MAXX := WIDTH * SCALE
    const MAXY := HEIGHT * SCALE

    %Initializes the screen
    proc setInit (x, y : int, title : string)
	setscreen ("Graphics:" + intstr (x) + ";" + intstr (y) + ",Title:"
	    + title + ",Position:Center,Center,Nobuttonbar,Offscreenonly")
	buttonchoose ("Multibutton")
	color (Black -> id)
	colorback (White -> id)
    end setInit
end Screen
