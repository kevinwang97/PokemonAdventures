class Psyduck
    inherit ActiveMob

    body proc construct (spawn : ^Vector)
	mobVector (BOTTOMLEFT) := Vectors.newXY (10 * 2, 4 * 2)
	mobVector (BOTTOMRIGHT) := Vectors.newXY (35 * 2, 4 * 2)
	mobVector (TOPLEFT) := Vectors.newXY (10 * 2, 40 * 2)
	mobVector (TOPRIGHT) := Vectors.newXY (35 * 2, 40 * 2)
	mobVector (LEFT) := Vectors.newXY (10 * 2, 22 * 2)
	mobVector (RIGHT) := Vectors.newXY (35 * 2, 22 * 2)
	width := Pic.Width (psyduck (0, 0))
	height := Pic.Height (psyduck (0, 0))
	initializeMob (spawn)
	moving := true
	health := 3
	startingHealth := health
	contactDamage := 1
    end construct

    body proc update
	updateState
	updatePosition (-4 * 2, 8 * 2, -8 * 2, -6 * 2)
	if velocity -> x = 0 and state = 0 then
	    state := 1
	    velocity -> setX (3 * Rand.Real + 1.5)
	end if
	if velocity -> x = 0 and state = 1 then
	    state := 0
	    velocity -> setX (- (3 * Rand.Real + 1.5))
	end if
	updateMobAnimation (upper (psyduck, 2))
    end update

    body proc render
	Pic.Draw (psyduck (state, frame), screenLocation -> x div 1, screenLocation -> y div 1, picMerge)
	renderHealthBar
    end render
end Psyduck
