module ProjectileManager
    import Projectile
    export ~.*projectileList, add, sweep, clear, update, render

    var projectileList : ^DoublyLinkedList
    new DoublyLinkedList, projectileList

    proc add (loc : ^Vector, velocity : ^Vector)
	var temp : ^Projectile
	new Projectile, temp
	temp -> construct (loc)
	temp -> setVelocity (velocity)
	projectileList -> add (temp)
    end add

    proc sweep
	var ptr := projectileList -> getHead
	loop
	    exit when ptr = nil
	    if Projectile (ptr -> object).dead then
		var freePtr := ptr
		ptr := ptr -> next
		projectileList -> remove (freePtr, true)
	    else
		ptr := ptr -> next
	    end if
	end loop
    end sweep

    proc clear
	projectileList -> clear (true)
    end clear

    proc update (screenLoc : ^Vector)
	var ptr := projectileList -> getHead
	loop
	    exit when ptr = nil
	    Projectile (ptr -> object).setScreenLoc (Vectors.minus (Projectile (ptr -> object).mapLocation, screenLoc))
	    Projectile (ptr -> object).update
	    ptr := ptr -> next
	end loop
    end update

    proc render
	var ptr := projectileList -> getHead
	loop
	    exit when ptr = nil
	    if Projectile (ptr -> object).isOnScreen then
		Projectile (ptr -> object).render
	    end if
	    ptr := ptr -> next
	end loop
    end render
end ProjectileManager
