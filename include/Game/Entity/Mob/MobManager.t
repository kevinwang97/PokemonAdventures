%Mob manager that contains all mobs except the player
%By: Kevin Wang
module MobManager
    import Mob, ActiveMob, Player, Electrode, Gengar, Psyduck, MrMime, Magikarp
    export ~.*MobType, ~.*mobList, add, sweep, clear, update, render

    %PRIVATE VARIABLES-----------------
    type MobType : enum (player, electrode, gengar, psyduck, mrMime, magikarp)
    var mobList : ^DoublyLinkedList
    new DoublyLinkedList, mobList

    proc add (mobType : MobType, loc : ^Vector)
	var temp : ^Mob
	case mobType of
	    label MobType.player :
		new Player, temp
	    label MobType.electrode :
		new Electrode, temp
	    label MobType.gengar :
		new Gengar, temp
	    label MobType.psyduck :
		new Psyduck, temp
	    label MobType.mrMime :
		new MrMime, temp
	    label MobType.magikarp :
		new Magikarp, temp
	    label :
		Error.Halt ("Invalid mob type")
	end case
	temp -> construct (loc)
	mobList -> add (temp)
    end add

    proc sweep
	var ptr := mobList -> getHead
	loop
	    exit when ptr = nil
	    if Mob (ptr -> object).dead and objectclass (ptr -> object) ~= Player then %any other node
		var freePtr := ptr
		ptr := ptr -> next
		mobList -> remove (freePtr, true)
	    else
		ptr := ptr -> next
	    end if
	end loop
    end sweep

    %Kills all mobs and frees them
    proc clear
	mobList -> clear (true)
    end clear

    proc update (screenLoc : ^Vector)
	var ptr := mobList -> getHead
	loop
	    exit when ptr = nil
	    Mob (ptr -> object).setScreenLoc (Vectors.minus (Mob (ptr -> object).mapLocation, screenLoc))
	    Mob (ptr -> object).update
	    ptr := ptr -> next
	end loop
    end update

    proc render
	var ptr := mobList -> getLast
	loop
	    exit when ptr = nil
	    if Mob (ptr -> object).isOnScreen then
		Mob (ptr -> object).render
	    end if
	    ptr := ptr -> prev
	end loop
    end render
end MobManager
