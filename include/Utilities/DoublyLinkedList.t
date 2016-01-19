%Doubly Linked List made by Kevin Wang

%Anything that is going to be in the linked list must be an object
class * Object
    export all

    deferred proc destruct
end Object

%A node that contains the details of the object
class DoublyLinkedNode
    export all

    var prev, next : ^DoublyLinkedNode
    var object : ^Object

    proc construct (p, n : ^DoublyLinkedNode, obj : ^Object)
	prev := p
	next := n
	object := obj
    end construct

    proc setPrev (p : ^DoublyLinkedNode)
	prev := p
    end setPrev

    proc setNext (n : ^DoublyLinkedNode)
	next := n
    end setNext

    proc setObject (obj : ^Object)
	object := obj
    end setObject

    proc destruct
	free object
    end destruct
end DoublyLinkedNode

%The Doubly Linked List
class * DoublyLinkedList
    import DoublyLinkedNode
    export getHead, getLast, getSize,
	add, insertAfter, insertBefore,
	removeInd, remove, clear,
	getObject, setObject

    var head, last : ^DoublyLinkedNode := nil
    var size := 0

    fcn getHead : ^DoublyLinkedNode
	result head
    end getHead

    fcn getLast : ^DoublyLinkedNode
	result last
    end getLast

    fcn getSize : int
	result size
    end getSize

    fcn traverse (l : int) : ^DoublyLinkedNode
	if size = 0 then
	    result nil
	end if
	var ptr : ^DoublyLinkedNode
	if size - l >= l - 1 then
	    ptr := head
	    for i : 1 .. l - 1
		ptr := ptr -> next
	    end for
	else
	    ptr := last
	    for decreasing i : size .. l + 1
		ptr := ptr -> prev
	    end for
	end if
	result ptr
    end traverse

    proc add (obj : ^Object)
	var temp : ^DoublyLinkedNode
	new DoublyLinkedNode, temp
	temp -> construct (last, nil, obj)
	if last ~= nil then
	    last -> setNext (temp)
	end if
	last := temp
	if head = nil then
	    head := temp
	end if
	size += 1
    end add

    proc insertAfter (l : int, obj : ^Object)
	var ptr := traverse (l)
	var temp : ^DoublyLinkedNode
	new DoublyLinkedNode, temp
	temp -> construct (ptr, ptr -> next, obj)
	if ptr -> next ~= nil then
	    ptr -> next -> setPrev (temp)
	else
	    last := temp
	end if
	ptr -> setNext (temp)
	size += 1
    end insertAfter

    proc insertBefore (l : int, obj : ^Object)
	var ptr := traverse (l)
	var temp : ^DoublyLinkedNode
	new DoublyLinkedNode, temp
	temp -> construct (ptr -> prev, ptr, obj)
	if ptr -> prev ~= nil then
	    ptr -> prev -> setNext (temp)
	else
	    head := temp
	end if
	ptr -> setPrev (temp)
	size += 1
    end insertBefore

    proc removeInd (l : int, delete : boolean)
	var ptr := traverse (l)
	if ptr -> prev ~= nil then
	    ptr -> prev -> setNext (ptr -> next)
	else
	    head := ptr -> next
	end if
	if ptr -> next ~= nil then
	    ptr -> next -> setPrev (ptr -> prev)
	else
	    last := ptr -> prev
	end if
	size -= 1
	if delete then
	    ptr -> object -> destruct
	    ptr -> destruct
	end if
	free ptr
    end removeInd

    proc remove (node : ^DoublyLinkedNode, delete : boolean)
	var ptr := node
	if ptr -> prev ~= nil then
	    ptr -> prev -> setNext (ptr -> next)
	else
	    head := ptr -> next
	end if
	if ptr -> next ~= nil then
	    ptr -> next -> setPrev (ptr -> prev)
	else
	    last := ptr -> prev
	end if
	size -= 1
	if delete then
	    ptr -> object -> destruct
	    ptr -> destruct
	end if
	free ptr
    end remove

    proc clear (delete : boolean)
	var ptr := head
	loop
	    exit when ptr = nil
	    var freePtr := ptr
	    ptr := ptr -> next
	    if delete then
		freePtr -> object -> destruct
		freePtr -> destruct
	    end if
	    free freePtr
	end loop
	head := nil
	last := nil
	size := 0
    end clear

    fcn getObject (l : int) : ^Object
	var ptr := traverse (l)
	result ptr -> object
    end getObject

    proc setObject (l : int, obj : ^Object)
	var ptr := traverse (l)
	ptr -> setObject (obj)
    end setObject
end DoublyLinkedList
