%-------------------------------------------------------------%
%KEVIN WANG'S ICS3UG SUMMATIVE                                %
%POKEMON ADVENTURES                                           %
%-------------------------------------------------------------%
%Last edited January 24, 2013                                 %
%Read the README file and the word document for more details  %
%-------------------------------------------------------------%

include "include/Utilities/Utilities"
include "include/GUI/GUI"

%Global Constants
const *VERSION := "1.1.0"
const *CREATOR := "Kevin Wang"
var *timeScore : array 0 .. 5 of real
var *currentLevel : int

include "include/Game/Game"
include "include/MapEditor.t"

Screen.setInit (MAXX, MAXY, "Pokemon Adventures")

module Game
    import File,
	HoverButton, HoverTextButton, TextField, %GUI
	Sprites, GameManager %Game-related modules
    export all

    var title := Pic.FileNew ("sprites/title.jpg")
    var mapEditorPic := Pic.FileNew ("sprites/mapEditor.jpg")
    var gamePic := Pic.FileNew ("sprites/help.jpg")
    var titleFont := Font.New ("Pokemon Solid:54:Bold")
    var normalBigFont := Font.New ("Pokemon Solid:34:Bold")
    var normalFont := Font.New ("Pokemon Solid:20")
    var tinyFont := Font.New ("Pokemon Solid:12")
    var titleGreen := Color.constructNotSaved (99 / 255, 171 / 255, 62 / 255)
    var titleRed := Color.constructNotSaved (233 / 255, 29 / 255, 39 / 255)

    proc unload
	Pic.Free (title)
	Font.Free (titleFont)
	Font.Free (normalBigFont)
	Font.Free (normalFont)
	Font.Free (tinyFont)
	Color.destruct (titleGreen)
	Color.destruct (titleRed)
    end unload

    process music
	Music.PlayFileLoop ("music/Pokemon Theme.mp3")
    end music

    proc messageScreen (fontType : string)
	var dots := ""
	var message := "Please install the " + fontType + " font"
	var animatedMessage := message + dots
	var lastUpdate := Time.Elapsed
	var continueButton : ^HoverButton

	new HoverButton, continueButton
	continueButton -> initFast (Vectors.newXY (400, 200),
	    Vectors.newXY (560, 240), "CONTINUE", normalFont,
	    White, Black, titleGreen)

	loop
	    cls
	    Pic.Draw (title, 0, 0, picCopy)
	    MouseSystem.update
	    if Time.Elapsed - lastUpdate > 500 then
		if dots = "..." then
		    dots := ""
		else
		    dots += "."
		end if
		lastUpdate := Time.Elapsed
	    end if
	    animatedMessage := message + dots
	    Fonts.render (animatedMessage, 0, 100, MAXX, MAXY,
		AlignX.center, AlignY.center, normalBigFont, Black)
	    continueButton -> update
	    continueButton -> render
	    exit when continueButton -> selected and Window.GetActive = -1
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	free continueButton
    end messageScreen

    proc run
	loop
	    var curTime := Time.Elapsed
	    cls
	    MouseSystem.update
	    KeyboardSystem.update
	    GameManager.update
	    GameManager.render
	    if KeyboardSystem.pressed (KEY_ESC)| GameManager.gameOver then
		GameManager.unload
		exit
	    end if
	    View.Update
	    setscreen ("Title:" + intstr (Time.Elapsed - curTime))
	    Time.DelaySinceLast (1000 div FPS)
	end loop
    end run

    proc loadCustomMap
	var textField : ^TextField
	var buttons : array 1 .. 2 of ^HoverButton

	new TextField, textField
	textField -> initFast (Vectors.newXY (300, 280),
	    Vectors.newXY (660, 320), "Please enter map name", normalFont)

	new HoverButton, buttons (1)
	buttons (1) -> initFast (Vectors.newXY (400, 120),
	    Vectors.newXY (560, 160), "SUBMIT", normalFont,
	    White, Black, titleGreen)

	new HoverButton, buttons (2)
	buttons (2) -> initFast (Vectors.newXY (400, 60),
	    Vectors.newXY (560, 100), "BACK", normalFont,
	    White, Black, titleRed)

	loop
	    cls
	    Pic.Draw (title, 0, 0, picCopy)
	    MouseSystem.update
	    exit when buttons (2) -> selected
	    KeyboardSystem.update
	    textField -> update
	    textField -> render
	    for i : 1 .. 2
		buttons (i) -> update
		buttons (i) -> render
	    end for
	    if buttons (1) -> selected| textField -> checkSubmitted and
		    File.Exists ("maps/custom/" + textField -> getString + ".map") and
		    Window.GetActive = -1 then
		GameManager.load (false, "maps/custom/" + textField -> getString + ".map")
		run
		exit
	    end if
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	free textField
	for i : 1 .. 2
	    free buttons (i)
	end for
    end loadCustomMap

    proc loadMap
	var selections : array 0 .. 5 of ^Vector
	var levelLoc : array 0 .. 5 of ^Vector
	var velocityX := 0.0
	var font := Font.New ("Pokemon Solid:30:Bold")
	var buttons : array 1 .. 2 of ^HoverTextButton

	for i : 0 .. 5
	    selections (i) := Vectors.newXY (300 * i, 135)
	    levelLoc (i) := Vectors.newXY ((300 * i + 300 * (i + 1) - Font.Width ("Level " + intstr (i), font)) / 2,
		(MAXY - Fonts.getHeight (font)) / 2)
	end for

	new HoverTextButton, buttons (1)
	buttons (1) -> initFull (Vectors.newXY (40, MAXY - 90),
	    Vectors.newXY (120, MAXY - 50), "BACK", normalFont,
	    Black, Grey, 20)

	new HoverTextButton, buttons (2)
	buttons (2) -> initFull (Vectors.newXY (MAXX - 120, MAXY - 90),
	    Vectors.newXY (MAXX - 40, MAXY - 50), "LOAD", normalFont,
	    Black, Grey, 20)

	loop
	    cls
	    Pic.Draw (title, 0, 0, picCopy)
	    MouseSystem.update
	    exit when buttons (1) -> selected
	    for i : 0 .. 5
		Draw.FillBox (selections (i) -> x div 1, selections (i) -> y div 1, selections (i) -> x div 1 + 300, 405, Black -> id)
		Draw.Box (selections (i) -> x div 1, selections (i) -> y div 1, selections (i) -> x div 1 + 300, 405, White -> id)
		Font.Draw ("Level " + intstr (i), levelLoc (i) -> x div 1, levelLoc (i) -> y div 1 + 20,
		    font, White -> id)
		Font.Draw ("Fastest Time " + realstr (timeScore (i), 2), levelLoc (i) -> x div 1, levelLoc (i) -> y div 1 - 20,
		    tinyFont, Yellow -> id)
	    end for
	    if MouseSystem.clicking (MouseState.left) then
		velocityX := - (prevMouseState.x - mouseState.x)
	    else
		velocityX *= 0.95
	    end if
	    for i : 0 .. 5
		selections (i) -> setX (velocityX + selections (i) -> x)
		levelLoc (i) -> setX (velocityX + levelLoc (i) -> x)
		if selections (0) -> x > 0 then
		    var difference := selections (0) -> x
		    for j : 0 .. 5
			selections (j) -> setX (selections (j) -> x - difference)
			levelLoc (j) -> setX (levelLoc (j) -> x - difference)
		    end for
		elsif selections (upper (selections)) -> x + 300 < MAXX then
		    var difference := MAXX - (selections (upper (selections)) -> x + 300)
		    for j : 0 .. 5
			selections (j) -> setX (selections (j) -> x + difference)
			levelLoc (j) -> setX (levelLoc (j) -> x + difference)
		    end for
		end if
		if MouseSystem.clicked (MouseState.left) and inRect (selections (i) -> x, 135, selections (i) -> x + 300, 405) then
		    currentLevel := i
		    GameManager.load (true, "maps/level_" + intstr (i) + ".map")
		    run
		    exit
		end if
	    end for
	    Fonts.render ("LEVEL SELECT", 0, 405, MAXX, MAXY,
		AlignX.center, AlignY.center, titleFont, Black)
	    Fonts.render ("<- DRAG ->", 0, 0, MAXX, 135,
		AlignX.center, AlignY.center, font, Black)
	    for i : 1 .. 2
		buttons (i) -> update
		buttons (i) -> render
	    end for
	    if buttons (2) -> selected then
		loadCustomMap
	    end if
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	Font.Free (font)
	for i : 1 .. 2
	    free buttons (i)
	end for
	for i : 0 .. 5
	    selections (i) -> destruct
	    levelLoc (i) -> destruct
	end for
    end loadMap

    proc createMap
	var textField : array 1 .. 3 of ^TextField
	var buttons : array 1 .. 2 of ^HoverButton

	new TextField, textField (1)
	textField (1) -> initFast (Vectors.newXY (300, 360),
	    Vectors.newXY (660, 400), "Please Enter Map Name", normalFont)

	new TextField, textField (2)
	textField (2) -> initFast (Vectors.newXY (300, 280),
	    Vectors.newXY (660, 320), "# Columns (16 - 99)", normalFont)

	new TextField, textField (3)
	textField (3) -> initFast (Vectors.newXY (300, 200),
	    Vectors.newXY (660, 240), "# Rows (10 - 99)", normalFont)

	new HoverButton, buttons (1)
	buttons (1) -> initFast (Vectors.newXY (400, 120),
	    Vectors.newXY (560, 160), "SUBMIT", normalFont,
	    White, Black, titleGreen)

	new HoverButton, buttons (2)
	buttons (2) -> initFast (Vectors.newXY (400, 60),
	    Vectors.newXY (560, 100), "BACK", normalFont,
	    White, Black, titleRed)

	loop
	    cls
	    Pic.Draw (title, 0, 0, picCopy)
	    MouseSystem.update
	    exit when buttons (2) -> selected
	    KeyboardSystem.update
	    for i : 1 .. 2
		buttons (i) -> update
		buttons (i) -> render
	    end for
	    for i : 1 .. 3
		textField (i) -> update
		textField (i) -> render
	    end for
	    if buttons (1) -> selected and strintok (textField (2) -> getString) and
		    strintok (textField (3) -> getString) and strint (textField (2) -> getString) >= 16 and
		    strint (textField (3) -> getString) >= 10 and strint (textField (2) -> getString) <= 99 and
		    strint (textField (3) -> getString) <= 99 then
		MapEditor.createNew (textField (1) -> getString, strint (textField (2) -> getString) - 1, strint (textField (3) -> getString) - 1)
		exit
	    end if
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	for i : 1 .. 3
	    free textField (i)
	end for
	for i : 1 .. 2
	    free buttons (i)
	end for
    end createMap

    proc editExisting
	var textField : ^TextField
	var buttons : array 1 .. 2 of ^HoverButton

	new TextField, textField
	textField -> initFast (Vectors.newXY (300, 280),
	    Vectors.newXY (660, 320), "MAP NAME", normalFont)

	new HoverButton, buttons (1)
	buttons (1) -> initFast (Vectors.newXY (400, 120),
	    Vectors.newXY (560, 160), "SUBMIT", normalFont,
	    White, Black, titleGreen)

	new HoverButton, buttons (2)
	buttons (2) -> initFast (Vectors.newXY (400, 60),
	    Vectors.newXY (560, 100), "BACK", normalFont,
	    White, Black, titleRed)

	loop
	    cls
	    Pic.Draw (title, 0, 0, picCopy)
	    MouseSystem.update
	    exit when buttons (2) -> selected
	    KeyboardSystem.update
	    for i : 1 .. 2
		buttons (i) -> update
		buttons (i) -> render
	    end for
	    textField -> update
	    textField -> render
	    if buttons (1) -> selected and File.Exists ("maps/custom/" + textField -> getString + ".map") then
		MapEditor.editExisting (textField -> getString)
		exit
	    end if
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	free textField
	for i : 1 .. 2
	    free buttons (i)
	end for
    end editExisting

    proc mapEditorHelp
	var back : ^HoverButton

	new HoverButton, back
	back -> initFast (Vectors.newXY (400, 60),
	    Vectors.newXY (560, 100), "BACK", normalFont,
	    White, Black, titleRed)

	loop
	    cls
	    Pic.Draw (title, 0, 0, picCopy)
	    MouseSystem.update
	    exit when back -> selected
	    Font.Draw ("Select an entity from side bar then click desired grid location", 10, 510, tinyFont, Black -> id)
	    Font.Draw ("Change spawn location by pressing \"s\" and clicking desired grid location", 10, 485, tinyFont, Black -> id)
	    Font.Draw ("Set teleporter location by pressing \"t\" and clicking desired grid location", 10, 460, tinyFont, Black -> id)
	    Font.Draw ("Clear tiles (and teleporter) from a grid location by pressing \"Shift\" and clicking desired grid location", 10, 435, tinyFont, Black -> id)
	    Font.Draw ("Clear items and mobs from a grid location by pressing \"Ctrl\" and clicking desired grid location", 10, 410, tinyFont, Black -> id)
	    Font.Draw ("Drag map around by clicking right mouse key and dragging. AVOID SPAWNING MONSTERS DIRECTLY UNDERNEATH A TILE.", 10, 385, tinyFont, Red -> id)
	    Font.Draw ("SELECTION ->", 100, 235, tinyFont, Black -> id)
	    Font.Draw ("<- GRID", 760, 235, tinyFont, Black -> id)
	    Pic.Draw (mapEditorPic, 240, 110, picCopy)
	    back -> update
	    back -> render
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	free back
    end mapEditorHelp

    proc edit
	var buttons : array 1 .. 4 of ^HoverButton

	new HoverButton, buttons (1)
	buttons (1) -> initFast (Vectors.newXY (340, 340),
	    Vectors.newXY (620, 380), "CREATE NEW", normalFont,
	    White, Black, Grey)

	new HoverButton, buttons (2)
	buttons (2) -> initFast (Vectors.newXY (340, 280),
	    Vectors.newXY (620, 320), "EDIT EXISTING", normalFont,
	    White, Black, Grey)

	new HoverButton, buttons (3)
	buttons (3) -> initFast (Vectors.newXY (340, 220),
	    Vectors.newXY (620, 260), "EDITOR HELP", normalFont,
	    White, Black, Grey)

	new HoverButton, buttons (4)
	buttons (4) -> initFast (Vectors.newXY (400, 60),
	    Vectors.newXY (560, 100), "BACK", normalFont,
	    White, Black, titleRed)

	loop
	    cls
	    Pic.Draw (title, 0, 0, picCopy)
	    MouseSystem.update
	    exit when buttons (4) -> selected
	    KeyboardSystem.update
	    for i : 1 .. 4
		buttons (i) -> update
		buttons (i) -> render
	    end for
	    if buttons (1) -> selected then
		createMap
	    elsif buttons (2) -> selected then
		editExisting
	    elsif buttons (3) -> selected then
		mapEditorHelp
	    end if
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	for i : 1 .. 4
	    free buttons (i)
	end for
    end edit

    proc getLevel
	var fileNo : int
	open : fileNo, "data", read
	read : fileNo, timeScore
	close : fileNo
    end getLevel

    proc help
	var back : ^HoverButton

	new HoverButton, back
	back -> initFast (Vectors.newXY (400, 60),
	    Vectors.newXY (560, 100), "BACK", normalFont,
	    White, Black, titleRed)

	loop
	    cls
	    Pic.Draw (title, 0, 0, picCopy)
	    MouseSystem.update
	    exit when back -> selected
	    Font.Draw ("Move with arrow keys (double jump by tapping up twice) and run by clicking \"ctrl\"", 10, 510, tinyFont, Black -> id)
	    Font.Draw ("Throw a pokeball by pressing \"shift\"", 10, 485, tinyFont, Black -> id)
	    Font.Draw ("Pick up a key and unlock the locked tile by pressing \"z\"", 10, 460, tinyFont, Black -> id)
	    Font.Draw ("After picking up three candies and capturing all Pokemon, stand on the teleporter and press \"enter\" to teleport to next level", 10, 435, tinyFont, Black -> id)
	    Font.Draw ("Press \"esc\" to exit level", 10, 410, tinyFont, Black -> id)
	    Font.Draw ("Remember: Inventory can only hold three items, choose items wisely...", 10, 385, tinyFont, Red -> id)
	    Pic.Draw (gamePic, 240, 110, picCopy)
	    back -> update
	    back -> render
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	free back
    end help

    proc main
	var menuButton : array 1 .. 4 of ^HoverButton

	new HoverButton, menuButton (1)
	menuButton (1) -> initFast (Vectors.newXY (400, 220),
	    Vectors.newXY (560, 260), "START", normalFont,
	    White, Black, titleGreen)
	new HoverButton, menuButton (2)
	menuButton (2) -> initFast (Vectors.newXY (400, 160),
	    Vectors.newXY (560, 200), "HELP", normalFont,
	    White, Black, Grey)
	new HoverButton, menuButton (3)
	menuButton (3) -> initFast (Vectors.newXY (400, 100),
	    Vectors.newXY (560, 140), "EDIT", normalFont,
	    White, Black, Grey)
	new HoverButton, menuButton (4)
	menuButton (4) -> initFast (Vectors.newXY (400, 40),
	    Vectors.newXY (560, 80), "QUIT", normalFont,
	    White, Black, titleRed)

	fork music
	getLevel

	loop
	    cls
	    Pic.Draw (title, 0, 0, picCopy)
	    MouseSystem.update
	    for i : 1 .. 4
		menuButton (i) -> update
		menuButton (i) -> render
	    end for
	    Fonts.render ("POKÉMON ADVENTURES", 0, 200, MAXX, MAXY,
		AlignX.center, AlignY.center, titleFont, Black)
	    Fonts.render ("Version: " + VERSION, 0, 0, MAXX, MAXY,
		AlignX.right, AlignY.top, defFontId, Black)
	    Fonts.render ("By: " + CREATOR, 0, 0, MAXX, MAXY,
		AlignX.left, AlignY.top, defFontId, Black)
	    if menuButton (1) -> selected and Window.GetActive = -1 then
		loadMap
	    elsif menuButton (2) -> selected and Window.GetActive = -1 then
		help
	    elsif menuButton (3) -> selected and Window.GetActive = -1 then
		edit
	    elsif menuButton (4) -> selected and Window.GetActive = -1 then
		exit
	    end if
	    View.Update
	    Time.DelaySinceLast (1000 div FPS)
	end loop

	for i : 1 .. 4
	    free menuButton (i)
	end for
    end main
end Game

%Main Program
MouseSystem.initialize
if ~Fonts.isInstalled ("Pokemon Solid") then
    Game.messageScreen ("Pokemon Solid")
end if
Sprites.loadAll
Game.main
Game.unload
Sprites.unloadAll
Music.PlayFileStop
Window.Hide (defWinId)
