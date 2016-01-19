%Mob Class (Parent class to all mob entities)
%By: Kevin Wang
class Mob
    inherit Entity

    %PRIVATE VARIABLES-----------------
    const GRAVITY := 0.35
    const MAXFALLINGSPEED := -20
    var jumping, falling, moving : boolean

    %General initialization for all mobs
    proc initializeMob (spawn : ^Vector)
	initializeEntity (spawn)
	jumping := false
	falling := false
	moving := false
    end initializeMob

    proc updateMobAnimation (maxSprites : int)
	updateAnimation (maxSprites)
	%Set frame to 0 if not moving
	if ~moving then
	    frame := 0
	end if
    end updateMobAnimation

    %Checks if mob is falling or jumping
    proc updateState
	if velocity -> y < 0 then
	    falling := true
	    jumping := false
	elsif velocity -> y > 0 then
	    falling := false
	    jumping := true
	end if
    end updateState

    proc checkVerticalCollision (bottomFix, topFix : int)
	mapLocation -> setY (mapLocation -> y + velocity -> y)
	if mapLocation -> y < bottomFix then
	    mapLocation -> setY (bottomFix)
	    velocity -> setY (0)
	    falling := false
	elsif mapLocation -> y > upper (tiles, 2) * TILESIZE + topFix then
	    mapLocation -> setY (upper (tiles, 2) * TILESIZE + topFix)
	    velocity -> setY (0)
	end if
	%If entity is on a solid tile, checking 2 points on hit box
	if tileLocNotSolid (Vectors.plus (mapLocation, mobVector (BOTTOMLEFT))) or
		tileLocNotSolid (Vectors.plus (mapLocation, mobVector (BOTTOMRIGHT))) then
	    %Relocating entity
	    mapLocation -> setY (((mapLocation -> y + mobVector (BOTTOMLEFT) -> y)
		div TILESIZE + 1) * TILESIZE + bottomFix)
	    velocity -> setY (0)
	    falling := false
	else
	    %If entity is under a solid tile, checking 2 points on hit box
	    if tileLocNotSolid (Vectors.plus (mapLocation, mobVector (TOPLEFT))) or
		    tileLocNotSolid (Vectors.plus (mapLocation, mobVector (TOPRIGHT))) then
		%Relocating entity
		mapLocation -> setY (((mapLocation -> y + mobVector (BOTTOMLEFT) -> y)
		    div TILESIZE) * TILESIZE + topFix)
		velocity -> setY (0)
	    end if
	end if
    end checkVerticalCollision

    %Moves mob
    proc updatePosition (bottomFix, topFix, leftFix, rightFix : int)
	if velocity -> y > MAXFALLINGSPEED then
	    velocity -> setY (velocity -> y - GRAVITY)
	end if
	checkVerticalCollision (bottomFix, topFix)
	checkHorizontalCollision (leftFix, rightFix)
    end updatePosition
end Mob
