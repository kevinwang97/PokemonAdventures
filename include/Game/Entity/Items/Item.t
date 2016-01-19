class Item
    inherit Entity

    var angle : real

    body proc update
	if angle = 360 then
	    angle := 0
	end if
	angle += 0.15
	setMapLoc (Vectors.newXY (mapLocation -> x, mapLocation -> y + 0.5 * sin (angle)))
    end update
end Item
