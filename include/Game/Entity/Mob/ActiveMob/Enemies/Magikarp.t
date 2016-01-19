class Magikarp
    inherit ActiveMob

    body proc construct (spawn : ^Vector)
	mobVector (BOTTOMLEFT) := Vectors.newXY (7 * 2, 12 * 2)
	mobVector (BOTTOMRIGHT) := Vectors.newXY (31 * 2, 12 * 2)
	mobVector (TOPLEFT) := Vectors.newXY (7 * 2, 33 * 2)
	mobVector (TOPRIGHT) := Vectors.newXY (31 * 2, 33 * 2)
	mobVector (LEFT) := Vectors.newXY (7 * 2, 22 * 2)
	mobVector (RIGHT) := Vectors.newXY (31 * 2, 22 * 2)
	width := Pic.Width (magikarp (0, 0))
	height := Pic.Height (magikarp (0, 0))
	initializeMob (spawn)
	moving := true
	health := 1
	startingHealth := health
	contactDamage := 1
    end construct

    body proc update
	updateState
	updatePosition (-12 * 2, 15 * 2, -7 * 2, -2 * 2)
	if velocity -> x = 0 and state = 0 then
	    state := 1
	    velocity -> setX (1)
	end if
	if velocity -> x = 0 and state = 1 then
	    state := 0
	    velocity -> setX (-1)
	end if
	updateMobAnimation (upper (magikarp, 2))
    end update

    body proc render
	Pic.Draw (magikarp (state, frame), screenLocation -> x div 1, screenLocation -> y div 1, picMerge)
	renderHealthBar
    end render
end Magikarp
