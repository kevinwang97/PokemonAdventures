%Abstract parent class for active hoverable widgets
%By: Kevin Wang
class HoverableWidget
    inherit ActiveWidget

    %PRIVATE VARIABLES-----------------
    type Transition :
	record
	    colr : ^Colr
	    rChange, gChange, bChange : real
	    increments, incrementCounter : int
	end record

    fcn updateTransitionColor (transition : Transition, colr : TransitionColor) : Transition
	var r := transition
	if inRectVec (boxCoor1, boxCoor2) and r.incrementCounter < r.increments then
	    var c := r.colr
	    r.colr := Color.constructNotSaved (r.colr -> r + r.rChange, r.colr -> g + r.gChange, r.colr -> b + r.bChange)
	    if c ~= colr.start and c ~= colr.finish then %do not delete start color or end color
		Color.destruct (c)
	    end if
	    r.incrementCounter += 1
	    if r.incrementCounter = r.increments then
		r.colr := colr.finish
	    end if
	end if
	if ~inRectVec (boxCoor1, boxCoor2) and r.incrementCounter > 0 then
	    var c := r.colr
	    r.colr := Color.constructNotSaved (r.colr -> r - r.rChange, r.colr -> g - r.gChange, r.colr -> b - r.bChange)
	    if c ~= colr.start and c ~= colr.finish then %do not delete start color or end color
		Color.destruct (c)
	    end if
	    r.incrementCounter -= 1
	    if r.incrementCounter = 0 then
		r.colr := colr.start
	    end if
	end if
	result r
    end updateTransitionColor
end HoverableWidget
