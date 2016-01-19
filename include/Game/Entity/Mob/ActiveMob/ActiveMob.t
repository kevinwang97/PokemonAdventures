%Base class for all active mob classes
%By: Kevin Wang
class ActiveMob
    inherit Mob
    export startingHealth, health, contactDamage, takeDamage

    %PUBLIC VARIABLES-----------------
    var startingHealth, health : int
    var contactDamage : int

    proc takeDamage (d : int)
	health -= d
	if health <= 0 then
	    dead := true
	end if
    end takeDamage

    proc renderHealthBar
	var midPointX := (screenLocation -> x + screenLocation -> x + width) / 2
	var percentHealth := health / startingHealth
	var pic := Pic.New (round (midPointX - 50), screenLocation -> y div 1 + height + 5,
	    round (midPointX + 49), screenLocation -> y div 1 + height + 14)
	var blendedPic := Pic.Blend (blackHealthBar, pic, 35)
	Pic.Draw (blendedPic, round (midPointX - 50), screenLocation -> y div 1 + height + 5, picCopy)
	Draw.FillBox (round (midPointX - 50), screenLocation -> y div 1 + height + 5,
	    round (midPointX - 50) + (99 * percentHealth) div 1, screenLocation -> y div 1 + height + 15, greenHealthBarColr -> id)
	Draw.Box (round (midPointX - 50), screenLocation -> y div 1 + height + 5,
	    round (midPointX + 49), screenLocation -> y div 1 + height + 15, Black -> id)
	Pic.Free (pic)
	Pic.Free (blendedPic)
    end renderHealthBar
end ActiveMob
