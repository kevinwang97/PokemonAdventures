%Enemy mob class
%By: Kevin Wang
class Electrode
    inherit ActiveMob

    body proc construct (spawn : ^Vector)
	mobVector (BOTTOMLEFT) := Vectors.newXY (1, 1)
	mobVector (BOTTOMRIGHT) := Vectors.newXY (55, 1)
	mobVector (TOPLEFT) := Vectors.newXY (1, 55)
	mobVector (TOPRIGHT) := Vectors.newXY (55, 55)
	mobVector (LEFT) := Vectors.newXY (1, 28)
	mobVector (RIGHT) := Vectors.newXY (55, 28)
	width := Pic.Width (electrode (0, 0))
	height := Pic.Height (electrode (0, 0))
	initializeMob (spawn)
	%HARD CODED
	moving := true
	health := 2
	startingHealth := health
	contactDamage := 1
    end construct

    body proc update
	updateState
	updatePosition (-1, 8, -1, 8)
	if velocity -> x = 0 and state = 0 then
	    state := 1
	    velocity -> setX (1.75 * Rand.Real + 1.75)
	end if
	if velocity -> x = 0 and state = 1 then
	    state := 0
	    velocity -> setX (- (1.75 * Rand.Real + 1.75))
	end if
	updateMobAnimation (upper (electrode, 2))
    end update

    body proc render
	Pic.Draw (electrode (state, frame), screenLocation -> x div 1, screenLocation -> y div 1, picMerge)
	renderHealthBar
    end render
end Electrode
