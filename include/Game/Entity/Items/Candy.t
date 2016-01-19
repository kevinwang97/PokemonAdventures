class Candy
    inherit Item

    body proc construct (spawn : ^Vector)
	initializeEntity (spawn)
	width := Pic.Width (candy)
	height := Pic.Height (candy)
	angle := 0
	mobVector (BOTTOMLEFT) := Vectors.newXY (4 * ITEMSCALE, 4 * ITEMSCALE)
	mobVector (BOTTOMRIGHT) := Vectors.newXY (13 * ITEMSCALE, 4 * ITEMSCALE)
	mobVector (TOPLEFT) := Vectors.newXY (4 * ITEMSCALE, 12 * ITEMSCALE)
	mobVector (TOPRIGHT) := Vectors.newXY (13 * ITEMSCALE, 12 * ITEMSCALE)
	mobVector (LEFT) := Vectors.newXY (4 * ITEMSCALE, 8 * ITEMSCALE)
	mobVector (RIGHT) := Vectors.newXY (13 * ITEMSCALE, 8 * ITEMSCALE)
    end construct

    body proc render
	Pic.Draw (candy, screenLocation -> x div 1,
	    screenLocation -> y div 1, picMerge)
    end render
end Candy
