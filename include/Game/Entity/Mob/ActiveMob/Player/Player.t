%Player Class, inherits from parent Mob class
%By: Kevin Wang
class Player
    inherit ActiveMob
    import Item, ProjectileManager
    export inventory, flinching, teleport, resetTeleport, setInventory, setFlinching, setLastFlinch, allCandies

    %PUBLIC VARIABLES-----------------
    var inventory : array 0 .. 2 of ItemType
    var flinching : boolean
    var teleport : boolean
    %PRIVATE VARIABLES-----------------
    const SPEED := 5.2
    const RUNNINGSPEED := 1.3 * SPEED
    const JUMP := 12
    var running, doubleJumped : boolean
    var lastFlinch : int

    body proc construct (spawn : ^Vector)
	mobVector (BOTTOMLEFT) := Vectors.newXY (10 * CHARACTERSCALE, 2 * CHARACTERSCALE)
	mobVector (BOTTOMRIGHT) := Vectors.newXY (20 * CHARACTERSCALE, 2 * CHARACTERSCALE)
	mobVector (TOPLEFT) := Vectors.newXY (10 * CHARACTERSCALE, 28 * CHARACTERSCALE)
	mobVector (TOPRIGHT) := Vectors.newXY (20 * CHARACTERSCALE, 28 * CHARACTERSCALE)
	mobVector (LEFT) := Vectors.newXY (10 * CHARACTERSCALE, 15 * CHARACTERSCALE)
	mobVector (RIGHT) := Vectors.newXY (20 * CHARACTERSCALE, 15 * CHARACTERSCALE)
	width := Pic.Width (ash (0, 0))
	height := Pic.Height (ash (0, 0))
	initializeMob (spawn)
	health := 5
	startingHealth := health
	contactDamage := 2
	running := false
	doubleJumped := false
	lastFlinch := -9999
	flinching := false
	teleport := false
	for i : 0 .. 2
	    inventory (i) := ItemType.null
	end for
    end construct

    proc resetTeleport
	teleport := false
    end resetTeleport

    proc setInventory (ind : int, itemType : ItemType)
	inventory (ind) := itemType
    end setInventory

    proc setFlinching (b : boolean)
	flinching := b
    end setFlinching

    proc setLastFlinch (t : int)
	lastFlinch := t
    end setLastFlinch

    fcn allCandies : boolean
	for i : 0 .. 2
	    if inventory (i) ~= ItemType.candy then
		result false
	    end if
	end for
	result true
    end allCandies

    fcn hasKey : int
	for decreasing j : 2 .. 0
	    if inventory (j) = ItemType.key then
		result j
	    elsif j = 0 then
		result - 1
	    end if
	end for
    end hasKey

    proc unlockBlock
	var keySlot := hasKey
	if keySlot = -1 then
	    return
	end if
	var tileLoc1 := Vectors.newXY (mapLocation -> x, mapLocation -> y + 2 * CHARACTERSCALE)
	var tileLoc2 := Vectors.newXY (mapLocation -> x + width, mapLocation -> y + 2 * CHARACTERSCALE)
	if tileId (tileLoc1) = 19 then
	    setTileId (tileLoc1 -> x div TILESIZE, tileLoc1 -> y div TILESIZE, 0)
	    setTileId (tileLoc1 -> x div TILESIZE, (tileLoc1 -> y + TILESIZE) div TILESIZE, 0)
	    inventory (keySlot) := ItemType.null
	elsif tileId (tileLoc1) = 20 then
	    setTileId (tileLoc1 -> x div TILESIZE, tileLoc1 -> y div TILESIZE, 0)
	    setTileId (tileLoc1 -> x div TILESIZE, (tileLoc1 -> y - TILESIZE) div TILESIZE, 0)
	    inventory (keySlot) := ItemType.null
	end if
	if tileId (tileLoc2) = 19 then
	    setTileId (tileLoc2 -> x div TILESIZE, tileLoc2 -> y div TILESIZE, 0)
	    setTileId (tileLoc2 -> x div TILESIZE, (tileLoc2 -> y + TILESIZE) div TILESIZE, 0)
	    inventory (keySlot) := ItemType.null
	elsif tileId (tileLoc2) = 20 then
	    setTileId (tileLoc2 -> x div TILESIZE, tileLoc2 -> y div TILESIZE, 0)
	    setTileId (tileLoc2 -> x div TILESIZE, (tileLoc2 -> y - TILESIZE) div TILESIZE, 0)
	    inventory (keySlot) := ItemType.null
	end if
    end unlockBlock

    proc updateKeys
	%Jumping
	if KeyboardSystem.pressed (KEY_UP_ARROW) and ~doubleJumped then
	    if jumping or falling then
		doubleJumped := true
	    end if
	    jumping := true
	    velocity -> setY (JUMP)
	end if
	%Moving Right
	if nowState (KEY_RIGHT_ARROW) then
	    if ~running then
		velocity -> setX (SPEED)
	    else
		velocity -> setX (RUNNINGSPEED)
	    end if
	    state := 1
	end if
	%Moving Left
	if nowState (KEY_LEFT_ARROW) then
	    if ~running then
		velocity -> setX (-SPEED)
	    else
		velocity -> setX (-RUNNINGSPEED)
	    end if
	    state := 0
	end if
	%Not Moving
	if ~nowState (KEY_LEFT_ARROW) and ~nowState (KEY_RIGHT_ARROW) then
	    velocity -> setX (0)
	    moving := false
	else
	    moving := true
	end if
	%Running
	if nowState (KEY_CTRL) and ~running and ~falling and ~jumping and ~doubleJumped then
	    running := true
	elsif ~nowState (KEY_CTRL) then
	    running := false
	end if
	%Attacking
	if KeyboardSystem.pressed (KEY_SHIFT) then
	    var tempVec : ^Vector
	    if state = 0 then
		tempVec := Vectors.newXY (-11, 0)
		ProjectileManager.add (Vectors.newXY (mapLocation -> x - 16,
		    mapLocation -> y + mobVector (LEFT) -> y / 2),
		    tempVec)
	    else
		tempVec := Vectors.newXY (11, 0)
		ProjectileManager.add (Vectors.newXY (mapLocation -> x +
		    mobVector (RIGHT) -> x, mapLocation -> y + mobVector (RIGHT) -> y / 2),
		    tempVec)
	    end if
	end if
	%Unlocking a block
	if KeyboardSystem.pressed ("z") then
	    unlockBlock
	end if
	%Check teleport
	if (tileId (Vectors.plus (mapLocation, mobVector (BOTTOMLEFT))) = 21 or
		tileId (Vectors.plus (mapLocation, mobVector (BOTTOMRIGHT))) = 21) and
		KeyboardSystem.pressed (KEY_ENTER) then
	    teleport := true
	end if
    end updateKeys

    body proc update
	updateKeys
	updateState
	updatePosition (-2 * CHARACTERSCALE, 14 * CHARACTERSCALE, -9 * CHARACTERSCALE, 0)
	if Time.Elapsed - lastFlinch > 1000 then
	    flinching := false
	end if
	if ~jumping and ~falling then
	    doubleJumped := false
	end if
	if ~running then
	    updateMobAnimation (upper (ash, 2))
	else
	    updateMobAnimation (upper (ashRunning, 2))
	end if
    end update

    proc renderInventory
	var pic := Pic.New (10, MAXY - 58, 154, MAXY - 10)
	var blendedPic := Pic.Blend (greyInventory, pic, 40)
	Pic.Draw (blendedPic, 10, MAXY - 58, picCopy)
	Pic.Free (pic)
	Pic.Free (blendedPic)
	for i : 0 .. 2
	    if inventory (i) = ItemType.key then
		Pic.Draw (key, 10 + i * 48, MAXY - 58, picMerge)
	    elsif inventory (i) = ItemType.candy then
		Pic.Draw (candy, 10 + i * 48, MAXY - 58, picMerge)
	    end if
	end for
	Draw.Box (10, MAXY - 58, 154, MAXY - 10, Black -> id)
	Draw.ThickLine (10, MAXY - 10, 154, MAXY - 10, 3, Black -> id)
	Draw.ThickLine (10, MAXY - 58, 154, MAXY - 58, 3, Black -> id)
	for i : 0 .. 3
	    Draw.ThickLine (10 + i * 48, MAXY - 58, 10 + i * 48, MAXY - 10, 3, Black -> id)
	end for
    end renderInventory

    body proc render
	var draw := true
	if flinching then
	    draw := Time.Elapsed div 100 mod 2 = 0
	end if
	if draw then
	    if flinching then
		Pic.Draw (ash (state, 0), screenLocation -> x div 1,
		    screenLocation -> y div 1, picMerge)
	    elsif running and moving then
		Pic.Draw (ashRunning (state, frame), screenLocation -> x div 1,
		    screenLocation -> y div 1, picMerge)
	    else
		Pic.Draw (ash (state, frame), screenLocation -> x div 1,
		    screenLocation -> y div 1, picMerge)
	    end if
	end if
	renderInventory
	renderHealthBar
    end render
end Player
