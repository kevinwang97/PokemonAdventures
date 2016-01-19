class Gengar
    inherit ActiveMob

    body proc construct (spawn : ^Vector)
	mobVector (BOTTOMLEFT) := Vectors.newXY (13 * 2, 7 * 2)
	mobVector (BOTTOMRIGHT) := Vectors.newXY (43 * 2, 7 * 2)
	mobVector (TOPLEFT) := Vectors.newXY (13 * 2, 47 * 2)
	mobVector (TOPRIGHT) := Vectors.newXY (43 * 2, 47 * 2)
	mobVector (LEFT) := Vectors.newXY (13 * 2, 28 * 2)
	mobVector (RIGHT) := Vectors.newXY (43 * 2, 28 * 2)
	width := Pic.Width (gengar (0, 0))
	height := Pic.Height (gengar (0, 0))
	initializeMob (spawn)
	%HARD CODED
	moving := true
	health := 6
	startingHealth := health
	contactDamage := 3
    end construct

    body proc update
	updateState
	updatePosition (-7 * 2, 8 * 2, -12 * 2, -12 * 2)
	if velocity -> x = 0 and state = 0 then
	    state := 1
	    velocity -> setX (2.25 * Rand.Real + 2)
	end if
	if velocity -> x = 0 and state = 1 then
	    state := 0
	    velocity -> setX (- (2.25 * Rand.Real + 2))
	end if
	updateMobAnimation (upper (gengar, 2))
    end update

    body proc render
	Pic.Draw (gengar (state, frame), screenLocation -> x div 1, screenLocation -> y div 1, picMerge)
	renderHealthBar
    end render
end Gengar
