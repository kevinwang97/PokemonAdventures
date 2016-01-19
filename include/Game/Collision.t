module Collision
    import Entity, Mob, ActiveMob, Player, Projectile, Item, Key, Candy, HealthPack
    export ~.*all

    fcn rectToRect (x1, y1, width1, height1, x2, y2, width2, height2 : real) : boolean
	result x1 + width1 > x2 and x1 < x2 + width2 and y1 + height1 > y2 and y1 < y2 + height2
    end rectToRect

    fcn entityCollide (mV1, mV2 : array 0 .. 5 of ^Vector, loc1, loc2 : ^Vector) : boolean
	result rectToRect (loc1 -> x + mV1 (0) -> x, loc1 -> y + mV1 (0) -> y,
	    mV1 (1) -> x - mV1 (0) -> x, mV1 (2) -> y - mV1 (0) -> y,
	    loc2 -> x + mV2 (0) -> x, loc2 -> y + mV2 (0) -> y,
	    mV2 (1) -> x - mV2 (0) -> x, mV2 (2) -> y - mV2 (0) -> x)
    end entityCollide

    proc collideMobs
	var ptr := mobList -> getHead -> next %avoid Player colliding with itself
	var b1 := mobList -> getObject (1) %Player
	loop
	    exit when ptr = nil
	    if Entity (ptr -> object).isOnScreen and objectclass (ptr -> object) > ActiveMob and
		    entityCollide (Mob (b1).mobVector, ActiveMob (ptr -> object).mobVector,
		    Mob (b1).mapLocation, ActiveMob (ptr -> object).mapLocation) then
		bind b2 to ptr -> object
		if ~Player (b1).flinching then
		    if ActiveMob (b2).velocity -> x > 0 then
			Player (b1).setVelocity (Vectors.newXY
			    (ActiveMob (b2).velocity -> x + 1.5, ActiveMob (b2).velocity -> y + 7))
		    else
			Player (b1).setVelocity (Vectors.newXY
			    (ActiveMob (b2).velocity -> x - 1.5, ActiveMob (b2).velocity -> y + 7))
		    end if
		    Player (b1).takeDamage (ActiveMob (ptr -> object).contactDamage)
		    Player (b1).setLastFlinch (Time.Elapsed)
		    Player (b1).setFlinching (true)
		end if
	    end if
	    ptr := ptr -> next
	end loop
    end collideMobs

    proc collideProjectile
	var ptr := projectileList -> getHead
	var ptr2 := mobList -> getHead -> next % avoid player
	loop
	    exit when ptr = nil
	    var freed := false
	    ptr2 := mobList -> getHead -> next
	    loop
		exit when ptr2 = nil
		if objectclass (ptr2 -> object) > ActiveMob and
			entityCollide (Projectile (ptr -> object).mobVector, ActiveMob (ptr2 -> object).mobVector,
			Projectile (ptr -> object).mapLocation, ActiveMob (ptr2 -> object).mapLocation) then
		    var freePtr := ptr
		    ActiveMob (ptr2 -> object).takeDamage (1)
		    ptr := ptr -> next
		    projectileList -> remove (freePtr, true)
		    freed := true
		    exit
		end if
		ptr2 := ptr2 -> next
	    end loop
	    if ~freed then
		ptr := ptr -> next
	    end if
	end loop
    end collideProjectile

    proc collideItem
	var ptr := itemList -> getHead
	var ptr2 := mobList -> getHead
	loop
	    exit when ptr = nil
	    if objectclass (ptr -> object) > Item and Entity (ptr -> object).isOnScreen and
		    entityCollide (Item (ptr -> object).mobVector, Player (ptr2 -> object).mobVector,
		    Item (ptr -> object).mapLocation, Player (ptr2 -> object).mapLocation) then
		var freePtr := ptr
		var deleteItem := true
		if objectclass (ptr -> object) = Key then
		    var stop := false
		    for i : 0 .. 2
			if Player (ptr2 -> object).inventory (i) = ItemType.null then
			    Player (ptr2 -> object).setInventory (i, ItemType.key)
			    exit
			elsif i = 2 then
			    stop := true
			end if
		    end for
		    exit when stop
		elsif objectclass (ptr -> object) = Candy then
		    var stop := false
		    for i : 0 .. 2
			if Player (ptr2 -> object).inventory (i) = ItemType.null then
			    Player (ptr2 -> object).setInventory (i, ItemType.candy)
			    exit
			elsif i = 2 then
			    stop := true
			end if
		    end for
		    exit when stop
		elsif objectclass (ptr -> object) = HealthPack then
		    if Player (ptr2 -> object).health < Player (ptr2 -> object).startingHealth then
			Player (ptr2 -> object).takeDamage (-1)
		    else
			deleteItem := false
		    end if
		end if
		ptr := ptr -> next
		if deleteItem then
		    itemList -> remove (freePtr, true)
		end if
	    else
		ptr := ptr -> next
	    end if
	end loop
    end collideItem
end Collision
