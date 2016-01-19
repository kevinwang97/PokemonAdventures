class HealthPack
    inherit Item

    body proc construct (spawn : ^Vector)
	initializeEntity (spawn)
	width := Pic.Width (healthPack)
	height := Pic.Height (healthPack)
	angle := 0
	mobVector (BOTTOMLEFT) := Vectors.newXY (3 * ITEMSCALE, 4 * ITEMSCALE)
	mobVector (BOTTOMRIGHT) := Vectors.newXY (14 * ITEMSCALE, 4 * ITEMSCALE)
	mobVector (TOPLEFT) := Vectors.newXY (3 * ITEMSCALE, 13 * ITEMSCALE)
	mobVector (TOPRIGHT) := Vectors.newXY (14 * ITEMSCALE, 13 * ITEMSCALE)
	mobVector (LEFT) := Vectors.newXY (3 * ITEMSCALE, 8 * ITEMSCALE)
	mobVector (RIGHT) := Vectors.newXY (14 * ITEMSCALE, 8 * ITEMSCALE)
    end construct

    body proc render
	Pic.Draw (healthPack, screenLocation -> x div 1,
	    screenLocation -> y div 1, picMerge)
    end render
end HealthPack
