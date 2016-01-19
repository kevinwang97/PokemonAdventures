%Module containing all entity sprites
%By: Kevin Wang
module Sprites
    export ~.*CHARACTERSCALE, ~.*PROJECTILESCALE, ~.*ITEMSCALE,
	~.*tileSprites, %tile sprites
	~.*ash, ~.*ashRunning, %character sprites
	~.*electrode, ~.*gengar, ~.*psyduck, ~.*mrMime, ~.*magikarp, %enemy sprites
	~.*pokeball, %projectile sprites
	~.*key, ~.*candy, ~.*healthPack,  %item sprites
	~.*blackHealthBar, ~.*greenHealthBarColr, %health bar sprite
	~.*greyInventory,
	loadAll, unloadAll

    %PUBLIC VARIABLES-----------------
    const CHARACTERSCALE := 3
    const PROJECTILESCALE := 2
    const ITEMSCALE := 3
    type CharacterSprite : array 0 .. 1, 0 .. 2 of int
    type EnemySprite : array 0 .. 1, 0 .. 6 of int
    type Projectile : array 0 .. 1, 0 .. 3 of int
    type Item : int
    var tileSprites : array 0 .. 30 of int
    var ash, ashRunning : CharacterSprite
    var electrode, gengar, psyduck, mrMime, magikarp : EnemySprite
    var pokeball : Projectile
    var key, candy, healthPack : Item
    var blackHealthBar : int
    var greenHealthBarColr := Color.construct (5 / 255, 195 / 255, 5 / 255)
    var greyInventory : int

    proc loadTiles
	var tempPic := Pic.FileNew ("sprites/tileset.gif")
	Pic.Draw (tempPic, 1, 1, picCopy)
	Pic.Free (tempPic)
	for i : 0 .. 21
	    tileSprites (i) := Pic.New (i * 32 + 1, 32 + 1, i * 32 + 32, 64)
	    tileSprites (i) := Pic.Scale (tileSprites (i), 32 * SCALE, 32 * SCALE)
	    Pic.SetTransparentColor (tileSprites (i), Magenta -> id)
	end for
	for i : 22 .. upper (tileSprites)
	    tileSprites (i) := Pic.New ((i - 22) * 32 + 1, 1, (i - 22) * 32 + 32, 32)
	    tileSprites (i) := Pic.Scale (tileSprites (i), 32 * SCALE, 32 * SCALE)
	    Pic.SetTransparentColor (tileSprites (i), Magenta -> id)
	end for
    end loadTiles

    proc loadSprites (var picArray : array 0 .. *, 0 .. * of int, picPath : string, scale : int)
	var tempPic := Pic.FileNew (picPath)
	var height := Pic.Height (tempPic)
	Pic.Draw (tempPic, 1, 1, picCopy)
	Pic.Free (tempPic)
	for i : 0 .. upper (picArray, 2)
	    picArray (0, i) := Pic.New (i * height + 1, 1, i * height + height, height)
	    picArray (0, i) := Pic.Scale (picArray (0, i), height * scale, height * scale)
	    picArray (1, i) := Pic.Mirror (picArray (0, i))
	    Pic.SetTransparentColor (picArray (0, i), Magenta -> id)
	    Pic.SetTransparentColor (picArray (1, i), Magenta -> id)
	end for
    end loadSprites

    fcn loadItem (picPath : string, scale : int) : Item
	var tempPic := Pic.FileNew (picPath)
	tempPic := Pic.Scale (tempPic, Pic.Height (tempPic) * scale, Pic.Height (tempPic) * scale)
	Pic.SetTransparentColor (tempPic, Magenta -> id)
	result tempPic
    end loadItem

    fcn loadHealthBar (colr : ^Colr) : int
	Draw.FillBox (1, 1, 100, 10, Color.use (colr))
	result Pic.New (1, 1, 100, 10)
    end loadHealthBar

    fcn loadInventory : int
	var inventoryGrey := Color.constructNotSaved (40 / 255, 40 / 255, 40 / 255)
	Draw.FillBox (1, 1, 145, 49, Color.use (inventoryGrey))
	result Pic.New (1, 1, 145, 49)
    end loadInventory

    proc unloadSprite (p : int)
	var temp := p
	Pic.Free (temp)
    end unloadSprite

    proc unloadTiles
	for i : 0 .. upper (tileSprites)
	    unloadSprite (tileSprites (i))
	end for
    end unloadTiles

    proc unloadSprites (p : array 0 .. *, 0 .. * of int)
	for i : 0 .. upper (p, 1)
	    for j : 0 .. upper (p, 2)
		unloadSprite (p (i, j))
	    end for
	end for
    end unloadSprites

    proc loadAll
	loadTiles
	loadSprites (ash, "sprites/ash.gif", CHARACTERSCALE)
	loadSprites (ashRunning, "sprites/ashrunning.gif", CHARACTERSCALE)
	loadSprites (electrode, "sprites/electrode.gif", 1)
	loadSprites (gengar, "sprites/gengar.gif", 2)
	loadSprites (psyduck, "sprites/psyduck.gif", 2)
	loadSprites (mrMime, "sprites/mrmime.gif", 2)
	loadSprites (magikarp, "sprites/magikarp.gif", 2)
	loadSprites (pokeball, "sprites/pokeball.gif", PROJECTILESCALE)
	key := loadItem ("sprites/key.gif", ITEMSCALE)
	candy := loadItem ("sprites/candy.gif", ITEMSCALE)
	healthPack := loadItem ("sprites/healthPack.gif", ITEMSCALE)
	blackHealthBar := loadHealthBar (Black)
	greyInventory := loadInventory
    end loadAll

    proc unloadAll
	unloadTiles
	unloadSprites (ash)
	unloadSprites (ashRunning)
	unloadSprites (electrode)
	unloadSprites (gengar)
	unloadSprites (psyduck)
	unloadSprites (mrMime)
	unloadSprites (magikarp)
	unloadSprites (pokeball)
	unloadSprite (key)
	unloadSprite (candy)
	unloadSprite (blackHealthBar)
	unloadSprite (greyInventory)
	Color.destruct (greenHealthBarColr)
    end unloadAll
end Sprites
