module * MapEditor
    import HoverButton
    export createNew, editExisting

    var smallTiles : array 1 .. 21 of int
    var itemPic : array 1 .. 3 of int
    var grid : flexible array 0 .. -1, 0 .. -1 of Tile
    var gridLoc : flexible array 0 .. -1, 0 .. -1 of ^Vector
    var spawn : ^Vector
    var otherGrid : flexible array 1 .. 4, 0 .. -1, 0 .. -1 of boolean
    var velocity : ^Vector
    var selectOther : int
    var selection : int

    fcn loadItem (path : string) : int
	var temp := Pic.FileNew (path)
	temp := Pic.Scale (temp, 32, 32)
	Pic.SetTransparentColor (temp, Magenta -> id)
	result temp
    end loadItem

    proc loadAll
	var tempPic := Pic.FileNew ("sprites/tileset.gif")
	Pic.Draw (tempPic, 1, 1, picCopy)
	Pic.Free (tempPic)
	for i : 1 .. upper (smallTiles)
	    smallTiles (i) := Pic.New (i * 32 + 1, 32 + 1, i * 32 + 32, 64)
	    Pic.SetTransparentColor (smallTiles (i), Magenta -> id)
	end for
	itemPic (1) := loadItem ("sprites/key.gif")
	itemPic (2) := loadItem ("sprites/candy.gif")
	itemPic (3) := loadItem ("sprites/healthPack.gif")
	velocity := Vectors.clone (nullVector)
	selectOther := -1
	selection := 1
	spawn := Vectors.clone (nullVector)
	for i : 0 .. upper (gridLoc, 1)
	    for j : 0 .. upper (gridLoc, 2)
		gridLoc (i, j) := Vectors.newXY (i * TILESIZE + 200, j * TILESIZE)
	    end for
	end for
	for i : 1 .. 4
	    for j : 0 .. upper (gridLoc, 1)
		for k : 0 .. upper (gridLoc, 2)
		    otherGrid (i, j, k) := false
		end for
	    end for
	end for
    end loadAll

    proc unloadAll
	for i : 1 .. upper (smallTiles)
	    Pic.Free (smallTiles (i))
	end for
	for i : 1 .. 3
	    Pic.Free (itemPic (i))
	end for
	for i : 0 .. upper (grid, 1)
	    for j : 0 .. upper (grid, 2)
		gridLoc (i, j) -> destruct
	    end for
	end for
	new grid, 0, -1
	new gridLoc, 0, -1
	new otherGrid, 4, 0, -1
	velocity -> destruct
    end unloadAll

    proc fixBounds
	if gridLoc (0, 0) -> x > 200 then
	    var difference := gridLoc (0, 0) -> x - 200
	    for i : 0 .. upper (gridLoc, 1)
		for j : 0 .. upper (gridLoc, 2)
		    gridLoc (i, j) -> setX (gridLoc (i, j) -> x - difference)
		end for
	    end for
	elsif gridLoc (upper (gridLoc, 1), upper (gridLoc, 2)) -> x + TILESIZE < MAXX then
	    var difference := MAXX - (gridLoc (upper (gridLoc, 1), upper (gridLoc, 2)) -> x + TILESIZE)
	    for i : 0 .. upper (gridLoc, 1)
		for j : 0 .. upper (gridLoc, 2)
		    gridLoc (i, j) -> setX (gridLoc (i, j) -> x + difference)
		end for
	    end for
	end if
	if gridLoc (0, 0) -> y > 0 then
	    var difference := gridLoc (0, 0) -> y
	    for i : 0 .. upper (gridLoc, 1)
		for j : 0 .. upper (gridLoc, 2)
		    gridLoc (i, j) -> setY (gridLoc (i, j) -> y - difference)
		end for
	    end for
	elsif gridLoc (upper (gridLoc, 1), upper (gridLoc, 2)) -> y + TILESIZE < MAXY then
	    var difference := MAXY - (gridLoc (upper (gridLoc, 1), upper (gridLoc, 2)) -> y + TILESIZE)
	    for i : 0 .. upper (gridLoc, 1)
		for j : 0 .. upper (gridLoc, 2)
		    gridLoc (i, j) -> setY (gridLoc (i, j) -> y + difference)
		end for
	    end for
	end if
    end fixBounds

    proc writeMap (fileName : string)
	var fileNo : int
	var numEntities : array 1 .. 4 of int := init (0, 0, 0, 0)

	for i : 0 .. upper (grid, 1)
	    for j : 0 .. upper (grid, 2)
		for k : 1 .. 4
		    if otherGrid (k, i, j) then
			numEntities (k) += 1
		    end if
		end for
	    end for
	end for

	open : fileNo, "maps/custom/" + fileName + ".map", put
	put : fileNo, upper (grid, 2) + 1, " ", upper (grid, 1) + 1
	for decreasing i : upper (grid, 2) .. 0
	    for j : 0 .. upper (grid, 1)
		put : fileNo, grid (j, i), " " ..
	    end for
	    put : fileNo, ""
	end for
	put : fileNo, "\n", spawn -> x, " ", spawn -> y
	for i : 1 .. 4
	    put : fileNo, "\n", numEntities (i), "\n"
	    for j : 0 .. upper (grid, 1)
		for k : 0 .. upper (grid, 2)
		    if otherGrid (i, j, k) then
			put : fileNo, j, " ", k
		    end if
		end for
	    end for
	end for
	close : fileNo
    end writeMap

    proc edit (mapName : string)
	var saveButton : ^HoverButton
	var font := Font.New ("Pokemon Solid:20")

	new HoverButton, saveButton

	saveButton -> initFast (Vectors.newXY (20, 10),
	    Vectors.newXY (180, 50), "SAVE", font,
	    White, Black, Grey)

	loop
	    cls
	    MouseSystem.update
	    KeyboardSystem.update
	    saveButton -> update
	    if MouseSystem.clicking (MouseState.right) then
		velocity := Vectors.newXY (mouseState.x - prevMouseState.x, mouseState.y - prevMouseState.y)
	    else
		velocity := Vectors.scalarMult (velocity, 0.95)
	    end if
	    for i : 0 .. upper (gridLoc, 1)
		for j : 0 .. upper (gridLoc, 2)
		    gridLoc (i, j) := Vectors.plus (velocity, gridLoc (i, j))
		    if gridLoc (i, j) -> x >= 200 - TILESIZE and gridLoc (i, j) -> x <= MAXX and gridLoc (i, j) -> y >= 0 - TILESIZE and gridLoc (i, j) -> y <= MAXY then
			Pic.Draw (tileSprites (grid (i, j)), gridLoc (i, j) -> x div 1, gridLoc (i, j) -> y div 1, picMerge)
			if otherGrid (1, i, j) then
			    Pic.Draw (key, gridLoc (i, j) -> x div 1, gridLoc (i, j) -> y div 1, picMerge)
			end if
			if otherGrid (2, i, j) then
			    Pic.Draw (candy, gridLoc (i, j) -> x div 1, gridLoc (i, j) -> y div 1, picMerge)
			end if
			if otherGrid (3, i, j) then
			    Pic.Draw (healthPack, gridLoc (i, j) -> x div 1, gridLoc (i, j) -> y div 1, picMerge)
			end if
			if otherGrid (4, i, j) then
			    Draw.FillOval (gridLoc (i, j) -> x div 1 + 32, gridLoc (i, j) -> y div 1 + 32, 12, 12, Red -> id)
			end if
			if spawn -> x = i and spawn -> y = j then
			    Draw.FillOval (gridLoc (i, j) -> x div 1 + 32, gridLoc (i, j) -> y div 1 + 32, 12, 12, Blue -> id)
			end if
		    end if
		    if mouseState.x >= 200 and mouseState.x <= MAXX and mouseState.y >= 0 and mouseState.y <= MAXY then
			if MouseSystem.clicking (MouseState.left) and nowState (KEY_SHIFT) and
				inRect (gridLoc (i, j) -> x div 1, gridLoc (i, j) -> y div 1, gridLoc (i, j) -> x div 1 + TILESIZE, gridLoc (i, j) -> y div 1 + TILESIZE) then
			    grid (i, j) := 0
			elsif MouseSystem.clicking (MouseState.left) and nowState (KEY_CTRL) and
				inRect (gridLoc (i, j) -> x div 1, gridLoc (i, j) -> y div 1, gridLoc (i, j) -> x div 1 + TILESIZE, gridLoc (i, j) -> y div 1 + TILESIZE) then
			    for k : 1 .. 4
				otherGrid (k, i, j) := false
			    end for
			elsif MouseSystem.clicking (MouseState.left) and nowState ('t') and
				inRect (gridLoc (i, j) -> x div 1, gridLoc (i, j) -> y div 1, gridLoc (i, j) -> x div 1 + TILESIZE, gridLoc (i, j) -> y div 1 + TILESIZE) then
			    grid (i, j) := 21
			elsif MouseSystem.clicking (MouseState.left) and nowState ('s') and
				inRect (gridLoc (i, j) -> x div 1, gridLoc (i, j) -> y div 1, gridLoc (i, j) -> x div 1 + TILESIZE, gridLoc (i, j) -> y div 1 + TILESIZE) then
			    spawn := Vectors.newXY (i, j)
			elsif MouseSystem.clicking (MouseState.left) and inRect (gridLoc (i, j) -> x div 1, gridLoc (i, j) -> y div 1, gridLoc (i, j) -> x div 1 + TILESIZE, gridLoc (i, j) -> y div 1 +
				TILESIZE) then
			    if selection ~= -1 then
				grid (i, j) := selection
			    else
				otherGrid (selectOther, i, j) := true
			    end if
			end if
		    end if
		end for
	    end for
	    fixBounds
	    for i : 1 .. upper (gridLoc, 1)
		if gridLoc (i, 0) -> x div 1 >= 200 and gridLoc (i, 0) -> x div 1 <= MAXX then
		    Draw.Line (gridLoc (i, 0) -> x div 1, 0, gridLoc (i, 0) -> x div 1, MAXY, Black -> id)
		end if
	    end for
	    for i : 1 .. upper (gridLoc, 2)
		if gridLoc (0, i) -> y div 1 >= 0 and gridLoc (0, i) -> y div 1 <= MAXY then
		    Draw.Line (200, gridLoc (0, i) -> y div 1, MAXX, gridLoc (0, i) -> y div 1, Black -> id)
		end if
	    end for
	    Draw.FillBox (0, 0, 200, MAXY, Grey -> id)
	    for i : 1 .. 10
		for j : 0 .. 1
		    Pic.Draw (smallTiles (i + (j * 10)), 100 * j + 32, 500 - 40 * (i - 1), picMerge)
		    if MouseSystem.clicked (MouseState.left) and
			    inRect (100 * j + 32, 500 - 40 * (i - 1), 100 * j + 64, 500 - 40 * (i - 1) + 32) then
			selection := i + (j * 10)
			selectOther := -1
		    end if
		end for
	    end for
	    for i : 1 .. 2
		for j : 0 .. 1
		    if i = 2 and j = 1 then
			Draw.FillOval (148, 78, 8, 8, Red -> id)
		    else
			Pic.Draw (itemPic (i + (j * 2)), 100 * j + 32, 100 - 40 * (i - 1), picMerge)
		    end if
		    if MouseSystem.clicked (MouseState.left) and
			    inRect (100 * j + 32, 100 - 40 * (i - 1), 100 * j + 64, 100 - 40 * (i - 1) + 32) then
			selectOther := i + (j * 2)
			selection := -1
		    end if
		end for
	    end for
	    saveButton -> render
	    if saveButton -> selected then
		writeMap (mapName)
		exit
	    end if
	    Draw.Box (200, 0, MAXX, MAXY, Black -> id)
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	free saveButton
	Font.Free (font)
	unloadAll
    end edit

    proc createNew (fileName : string, x, y : int)
	new grid, x, y
	new gridLoc, x, y
	new otherGrid, 4, x, y

	loadAll

	for i : 0 .. upper (gridLoc, 1)
	    for j : 0 .. upper (gridLoc, 2)
		grid (i, j) := 0
	    end for
	end for

	edit (fileName)
    end createNew

    proc editExisting (fileName : string)
	var fileNo : int

	open : fileNo, "maps/custom/" + fileName + ".map", get
	var rows, columns : int
	get : fileNo, rows, columns

	new grid, columns - 1, rows - 1
	new gridLoc, columns - 1, rows - 1
	new otherGrid, 4, columns - 1, rows - 1

	loadAll

	for decreasing i : upper (grid, 2) .. 0
	    for j : 0 .. upper (grid, 1)
		get : fileNo, grid (j, i)
	    end for
	end for

	var spawnX, spawnY : int
	get : fileNo, spawnX, spawnY
	spawn := Vectors.newXY (spawnX, spawnY)

	for i : 1 .. 4
	    var numEntity : int
	    get : fileNo, numEntity
	    for j : 1 .. numEntity
		var x, y : int
		get : fileNo, x, y
		otherGrid (i, x, y) := true
	    end for
	end for
	close : fileNo

	edit (fileName)
    end editExisting
end MapEditor
