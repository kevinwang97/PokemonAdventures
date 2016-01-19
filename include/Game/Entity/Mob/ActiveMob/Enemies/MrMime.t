class MrMime
    inherit ActiveMob

    body proc construct (spawn : ^Vector)
	mobVector (BOTTOMLEFT) := Vectors.newXY (20 * 2, 4 * 2)
	mobVector (BOTTOMRIGHT) := Vectors.newXY (37 * 2, 4 * 2)
	mobVector (TOPLEFT) := Vectors.newXY (20 * 2, 46 * 2)
	mobVector (TOPRIGHT) := Vectors.newXY (37 * 2, 46 * 2)
	mobVector (LEFT) := Vectors.newXY (20 * 2, 25 * 2)
	mobVector (RIGHT) := Vectors.newXY (37 * 2, 25 * 2)
	width := Pic.Width (mrMime (0, 0))
	height := Pic.Height (mrMime (0, 0))
	initializeMob (spawn)
	moving := true
	health := 3
	startingHealth := health
	contactDamage := 2
    end construct

    body proc update
	updateState
	updatePosition (-4 * 2, 8 * 2, -18 * 2, -8 * 2)
	if velocity -> x = 0 and state = 0 then
	    state := 1
	    velocity -> setX (3.25 * Rand.Real + 2.5)
	end if
	if velocity -> x = 0 and state = 1 then
	    state := 0
	    velocity -> setX (- (3.25 * Rand.Real + 2.5))
	end if
	updateMobAnimation (upper (mrMime, 2))
    end update

    body proc render
	Pic.Draw (mrMime (state, frame), screenLocation -> x div 1, screenLocation -> y div 1, picMerge)
	renderHealthBar
    end render
end MrMime
