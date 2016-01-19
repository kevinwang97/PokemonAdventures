%Entity Class (Parent class to all entities in the game)
%By: Kevin Wang
class Entity
    inherit Object
    export mapLocation, screenLocation, velocity, width, height, dead, mobVector,
	construct, setVelocity, setMapLoc, setScreenLoc, isOnScreen, setDead, update, render

    %PUBLIC VARIABLES-----------------
    var mapLocation, screenLocation : ^Vector
    var velocity : ^Vector
    var width, height : int
    var dead : boolean
    %Collision box
    const BOTTOMLEFT := 0
    const BOTTOMRIGHT := 1
    const TOPLEFT := 2
    const TOPRIGHT := 3
    const LEFT := 4
    const RIGHT := 5
    var mobVector : array 0 .. 5 of ^Vector
    %PRIVATE VARIABLES-----------------
    %Animation variables
    const ANIMATIONDELAY := 125
    var state, frame : int
    var lastChange : int

    deferred proc construct (spawn : ^Vector)

    proc initializeEntity (spawn : ^Vector)
	mapLocation := Vectors.clone (spawn)
	screenLocation := Vectors.newXY (MAXX / 2, MAXY / 2)
	velocity := Vectors.clone (nullVector)
	dead := false
	state := 1
	frame := 0
	lastChange := Time.Elapsed
    end initializeEntity

    proc setVelocity (v : ^Vector)
	Vectors.change (velocity, v)
    end setVelocity

    proc setMapLoc (loc : ^Vector)
	Vectors.change (mapLocation, loc)
    end setMapLoc

    proc setScreenLoc (loc : ^Vector)
	Vectors.change (screenLocation, loc)
    end setScreenLoc

    fcn isOnScreen : boolean
	result screenLocation -> x + width > 0 and
	    screenLocation -> x - width < MAXX and
	    screenLocation -> y + height > 0 and
	    screenLocation -> y - height < MAXY
    end isOnScreen

    proc setDead
	dead := true
    end setDead

    proc updateAnimation (maxSprites : int)
	if Time.Elapsed - lastChange > ANIMATIONDELAY then
	    lastChange := Time.Elapsed
	    if frame < maxSprites then
		frame += 1
	    else
		frame := 0
	    end if
	end if
    end updateAnimation

    proc checkHorizontalCollision (leftFix, rightFix : int)
	mapLocation -> setX (mapLocation -> x + velocity -> x)
	if mapLocation -> x < leftFix then
	    mapLocation -> setX (leftFix)
	    velocity -> setX (0)
	elsif mapLocation -> x > upper (tiles, 1) * TILESIZE + rightFix then
	    mapLocation -> setX (upper (tiles, 1) * TILESIZE + rightFix)
	    velocity -> setX (0)
	end if
	if velocity -> x < 0 then
	    %If entity is to the right of tile, checking 3 points on hit box
	    if tileLocNotSolid (Vectors.plus (mapLocation, mobVector (LEFT))) or
		    tileLocNotSolid (Vectors.plus (mapLocation, mobVector (TOPLEFT))) or
		    tileLocNotSolid (Vectors.plus (mapLocation, mobVector (BOTTOMLEFT))) then
		%Relocating entity
		mapLocation -> setX (((mapLocation -> x + mobVector (BOTTOMLEFT) -> x)
		    div TILESIZE + 1) * TILESIZE + leftFix)
		velocity -> setX (0)
	    end if
	elsif velocity -> x > 0 then
	    %If entity is to the left of tile, checking 3 points on hit box
	    if tileLocNotSolid (Vectors.plus (mapLocation, mobVector (RIGHT))) or
		    tileLocNotSolid (Vectors.plus (mapLocation, mobVector (TOPRIGHT))) or
		    tileLocNotSolid (Vectors.plus (mapLocation, mobVector (BOTTOMRIGHT))) then
		%Relocating entity
		mapLocation -> setX (((mapLocation -> x + mobVector (BOTTOMLEFT) -> x)
		    div TILESIZE) * TILESIZE + rightFix)
		velocity -> setX (0)
	    end if
	end if
    end checkHorizontalCollision

    deferred proc update

    deferred proc render

    body proc destruct
	mapLocation -> destruct
	screenLocation -> destruct
	for i : 0 .. 5
	    mobVector (i) -> destruct
	end for
	velocity -> destruct
    end destruct
end Entity
