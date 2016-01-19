%Projectile Class
%By: Kevin Wang
class Projectile
    inherit Entity

    body proc construct (spawn : ^Vector)
	mobVector (BOTTOMLEFT) := Vectors.clone (nullVector)
	mobVector (BOTTOMRIGHT) := Vectors.newXY (16 * PROJECTILESCALE, 0)
	mobVector (TOPLEFT) := Vectors.newXY (0, 16 * PROJECTILESCALE)
	mobVector (TOPRIGHT) := Vectors.newXY (16 * PROJECTILESCALE, 16 * PROJECTILESCALE)
	mobVector (LEFT) := Vectors.newXY (0, 8 * PROJECTILESCALE)
	mobVector (RIGHT) := Vectors.newXY (16 * PROJECTILESCALE, 8 * PROJECTILESCALE)
	width := Pic.Width (pokeball (0, 0))
	height := Pic.Height (pokeball (0, 0))
	initializeEntity (spawn)
    end construct

    body proc update
	updateAnimation (upper (pokeball, 2))
	checkHorizontalCollision (0, 0)
	if velocity -> x = 0 then
	    dead := true
	end if
    end update

    body proc render
	Pic.Draw (pokeball (state, frame), screenLocation -> x div 1,
	    screenLocation -> y div 1, picMerge)
    end render
end Projectile
