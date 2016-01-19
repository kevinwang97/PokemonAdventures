%Keyboard Module
%By: Kevin Wang
module * KeyboardSystem
    import Input
    export ~.*ch, ~.*prevState, ~.*nowState, update, pressed

    %PUBLIC VARIABLES-----------------
    %ch is type string (1) because it can hold a null string whereas a type
    %char cannot
    var ch : string (1)
    var prevState, nowState : array char of boolean

    %Updates keyboard state
    proc update
	if hasch then
	    ch := getchar
	else
	    ch := ""
	end if
	prevState := nowState
	Input.KeyDown (nowState)
    end update

    fcn pressed (c : char) : boolean
	result nowState (c) and ~prevState (c)
    end pressed
end KeyboardSystem
