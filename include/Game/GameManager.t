%GameScreen module renders and updates the entire game
%By: Kevin Wang
module GameManager
    import Tiles, Mob, ActiveMob, ItemManager, ProjectileManager, MobManager, Collision, Player
    export load, unload, gameOver, update, render

    %PRIVATE VARIABLES-----------------
    %How many tiles the screen can hold
    const GRIDDIMENSION := Vectors.newXY (ceil (MAXX / TILESIZE), ceil (MAXY / TILESIZE))
    %Vector for the center of the screen (does not change because screen size never changes)
    const SCREENCENTER := Vectors.newXY (MAXX / 2, MAXY / 2)
    %Smooth transition of camera following player
    const RESPONSIVENESS := 0.075
    %Location on Screen
    var location := Vectors.newXY (0, 0)
    %Background pic
    var bg := Pic.FileNew ("sprites/background.jpg")
    var font := Font.New ("Pokemon Solid:20:Bold")
    var teleportToNext : boolean
    var startTime : int

    proc load (teleToNextLevel : boolean, file : string)
	%Tiles
	var fileNo : int
	var columns, rows : int
	open : fileNo, file, get
	get : fileNo, rows, columns
	new tiles, columns - 1, rows - 1
	for decreasing y : upper (tiles, 2) .. 0
	    for x : 0 .. upper (tiles, 1)
		get : fileNo, tiles (x, y)
	    end for
	end for
	%Player
	var playerSpawnX, playerSpawnY : int
	get : fileNo, playerSpawnX, playerSpawnY
	MobManager.add (MobType.player, Vectors.newXY (playerSpawnX * TILESIZE, playerSpawnY * TILESIZE))
	%Keys
	var numKeys : int
	get : fileNo, numKeys
	for i : 1 .. numKeys
	    var spawnX, spawnY : int
	    get : fileNo, spawnX, spawnY
	    ItemManager.add (ItemType.key, Vectors.newXY (spawnX * TILESIZE, spawnY * TILESIZE))
	end for
	%Candies
	var numCandies : int
	get : fileNo, numCandies
	for i : 1 .. numCandies
	    var spawnX, spawnY : int
	    get : fileNo, spawnX, spawnY
	    ItemManager.add (ItemType.candy, Vectors.newXY (spawnX * TILESIZE, spawnY * TILESIZE))
	end for
	%Health Packs
	var numHealthPacks : int
	get : fileNo, numHealthPacks
	for i : 1 .. numHealthPacks
	    var spawnX, spawnY : int
	    get : fileNo, spawnX, spawnY
	    ItemManager.add (ItemType.healthPack, Vectors.newXY (spawnX * TILESIZE, spawnY * TILESIZE))
	end for
	%Mobs
	var numMobs : int
	get : fileNo, numMobs
	for i : 1 .. numMobs
	    var random := Rand.Int (0, 4)
	    var spawnX, spawnY : int
	    get : fileNo, spawnX, spawnY
	    if random = 0 then
		MobManager.add (MobType.electrode, Vectors.newXY (spawnX * TILESIZE, spawnY * TILESIZE))
	    elsif random = 1 then
		MobManager.add (MobType.gengar, Vectors.newXY (spawnX * TILESIZE, spawnY * TILESIZE))
	    elsif random = 2 then
		MobManager.add (MobType.psyduck, Vectors.newXY (spawnX * TILESIZE, spawnY * TILESIZE))
	    elsif random = 3 then
		MobManager.add (MobType.mrMime, Vectors.newXY (spawnX * TILESIZE, spawnY * TILESIZE))
	    elsif random = 4 then
		MobManager.add (MobType.magikarp, Vectors.newXY (spawnX * TILESIZE, spawnY * TILESIZE))
	    end if
	end for
	close : fileNo
	teleportToNext := teleToNextLevel
	startTime := Time.Elapsed
    end load

    proc unload
	new tiles, -1, 0
	MobManager.clear
	ProjectileManager.clear
	ItemManager.clear
    end unload

    proc fixBoundaries
	if location -> x < 0 then
	    location -> setX (0)
	elsif location -> x > (upper (tiles, 1) + 1) * TILESIZE - MAXX then
	    location -> setX ((upper (tiles, 1) + 1) * TILESIZE - MAXX)
	end if
	if location -> y < 0 then
	    location -> setY (0)
	elsif location -> y > (upper (tiles, 2) + 1) * TILESIZE - MAXY then
	    location -> setY ((upper (tiles, 2) + 1) * TILESIZE - MAXY)
	end if
    end fixBoundaries

    fcn gameOver : boolean
	result ActiveMob (mobList -> getObject (1)).health <= 0
    end gameOver

    proc writeLevel
	var fileNo : int
	open : fileNo, "data", write
	write : fileNo, timeScore
	close : fileNo
    end writeLevel

    proc update
	Vectors.change (location, Vectors.plus (location, Vectors.scalarMult (Vectors.minus
	    (Vectors.minus (Mob (mobList -> getObject (1)).mapLocation, SCREENCENTER), location), RESPONSIVENESS)))
	fixBoundaries
	collideMobs
	collideProjectile
	collideItem
	MobManager.update (location)
	MobManager.sweep
	ProjectileManager.update (location)
	ProjectileManager.sweep
	ItemManager.update (location)
	ItemManager.sweep
	if teleportToNext and Player (mobList -> getHead -> object).teleport and
		Player (mobList -> getHead -> object).allCandies and mobList -> getSize = 1 then
	    if timeScore (currentLevel) > (Time.Elapsed - startTime) / 1000 then
		timeScore (currentLevel) := (Time.Elapsed - startTime) / 1000
	    end if
	    if currentLevel ~= 5 then
		currentLevel += 1
		writeLevel
		unload
		load (true, "maps/level_" + intstr (currentLevel) + ".map")
		Player (mobList -> getHead -> object).resetTeleport
	    else
		Player (mobList -> getObject (1)).takeDamage (99)
		Player (mobList -> getHead -> object).resetTeleport
	    end if
	elsif Player (mobList -> getHead -> object).teleport and Player (mobList -> getHead -> object).allCandies and
		~teleportToNext then
	    Player (mobList -> getObject (1)).takeDamage (99)
	    Player (mobList -> getHead -> object).resetTeleport
	elsif Player (mobList -> getHead -> object).teleport then
	    Player (mobList -> getHead -> object).resetTeleport
	end if
    end update

    proc render
	Pic.Draw (bg, (0 - location -> x / 20) div 1, (0 - location -> y / 2.5) div 1, picCopy)
	%Draws the tiles that are within the screen range
	for x : max (location -> x div TILESIZE, 0) .. min ((location -> x / TILESIZE + GRIDDIMENSION -> x) div 1, upper (tiles, 1))
	    for y : max (location -> y div TILESIZE, 0) .. min ((location -> y / TILESIZE + GRIDDIMENSION -> y) div 1, upper (tiles, 2))
		Tiles.render (tiles (x, y), Vectors.newXY (x - location -> x / TILESIZE, y - location -> y / TILESIZE))
	    end for
	end for
	Font.Draw ("Time: " + realstr ((Time.Elapsed - startTime) / 1000, 2), MAXX - 180,
	    MAXY - 40, font, Black -> id)
	ItemManager.render
	ProjectileManager.render
	MobManager.render
    end render
end GameManager
