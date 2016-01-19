module ItemManager
    import Item, Key, Candy, HealthPack
    export ~.*ItemType, ~.*itemList, add, sweep, clear, update, render

    type ItemType : enum (null, key, candy, healthPack)
    var itemList : ^DoublyLinkedList
    new DoublyLinkedList, itemList

    proc add (itemType : ItemType, loc : ^Vector)
	var temp : ^Item
	case itemType of
	    label ItemType.key :
		new Key, temp
	    label ItemType.candy :
		new Candy, temp
	    label ItemType.healthPack :
		new HealthPack, temp
	    label :
		Error.Halt ("Invalid item type")
	end case
	temp -> construct (loc)
	itemList -> add (temp)
    end add

    proc sweep
	var ptr := itemList -> getHead
	loop
	    exit when ptr = nil
	    if Item (ptr -> object).dead then
		var freePtr := ptr
		ptr := ptr -> next
		itemList -> remove (freePtr, true)
	    else
		ptr := ptr -> next
	    end if
	end loop
    end sweep

    proc clear
	itemList -> clear (true)
    end clear

    proc update (screenLoc : ^Vector)
	var ptr := itemList -> getHead
	loop
	    exit when ptr = nil
	    Item (ptr -> object).setScreenLoc (Vectors.minus (Item (ptr -> object).mapLocation, screenLoc))
	    Item (ptr -> object).update
	    ptr := ptr -> next
	end loop
    end update

    proc render
	var ptr := itemList -> getHead
	loop
	    exit when ptr = nil
	    if Item (ptr -> object).isOnScreen then
		Item (ptr -> object).render
	    end if
	    ptr := ptr -> next
	end loop
    end render
end ItemManager
