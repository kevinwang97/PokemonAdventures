%TileMap Module includes loading sprites and loading a map
%By: Kevin Wang
module Tiles
    export ~.*TILESIZE, ~.*Tile, ~.*var tiles,
	~.*tileLocNotSolid, ~.*tileIdNotSolid, ~.*tileId, ~.*setTileId, render

    %PUBLIC VARIABLES-----------------
    const TILESIZE := 32 * SCALE
    type Tile : int
    var tiles : flexible array 0 .. -1, 0 .. -1 of Tile

    fcn tileIdNotSolid (t : Tile) : boolean
	if t >= 21 then
	    result false
	end if
	result t = 2 or t = 3 or t = 5 or t >= 11
    end tileIdNotSolid

    fcn tileLocNotSolid (loc : ^Vector) : boolean
	var tileGridLoc := Vectors.scalarMult (loc, 1 / TILESIZE)
	var iX := tileGridLoc -> x div 1
	var iY := tileGridLoc -> y div 1
	tileGridLoc -> destruct
	result tileIdNotSolid (tiles (iX, iY))
    end tileLocNotSolid

    fcn tileId (loc : ^Vector) : Tile
	var tileGridLoc := Vectors.scalarMult (loc, 1 / TILESIZE)
	var iX := tileGridLoc -> x div 1
	var iY := tileGridLoc -> y div 1
	tileGridLoc -> destruct
	result tiles (iX, iY)
    end tileId

    proc setTileId (x, y, newId : int)
	tiles (x, y) := newId
    end setTileId

    proc render (t : Tile, location : ^Vector)
	if t = 0 then
	    return
	end if
	Pic.Draw (tileSprites (t), location -> x * TILESIZE div 1, location -> y * TILESIZE div 1, picMerge)
    end render
end Tiles
