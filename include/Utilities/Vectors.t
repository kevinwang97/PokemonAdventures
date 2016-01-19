module * Vectors
    export ~.*Vector, newXY, newMagAng, clone, change, ~.*nullVector,
	plus, minus, scalarMult, unit

    class Vector
	export all

	var x, y : real

	proc construct (xParam, yParam : real)
	    x := xParam
	    y := yParam
	end construct

	proc setX (xParam : real)
	    x := xParam
	end setX

	proc setY (yParam : real)
	    y := yParam
	end setY

	fcn isEqualTo (v : ^Vector) : boolean
	    result x = v -> x and y = v -> y
	end isEqualTo

	fcn magnitude : real
	    result sqrt (x ** 2 + y ** 2)
	end magnitude

	fcn dot (v : ^Vector) : real
	    result x * v -> x + y * v -> y
	end dot

	proc destruct
	    var v := self
	    free v
	end destruct

	proc render
	    put x, " ", y
	end render
    end Vector

    fcn newXY (xParam, yParam : real) : ^Vector
	var tempVector : ^Vector
	new Vector, tempVector
	tempVector -> construct (xParam, yParam)
	result tempVector
    end newXY

    fcn newMagAng (mag, ang : real) : ^Vector
	result newXY (cosd (ang) * mag, sind (ang) * mag)
    end newMagAng

    fcn clone (v : ^Vector) : ^Vector
	result newXY (v -> x, v -> y)
    end clone

    proc change (var original : ^Vector, changeTo : ^Vector)
	var temp := original
	original := changeTo
	temp -> destruct
    end change

    var nullVector := newXY (0, 0)

    fcn plus (v1, v2 : ^Vector) : ^Vector
	result newXY (v1 -> x + v2 -> x, v1 -> y + v2 -> y)
    end plus

    fcn minus (v1, v2 : ^Vector) : ^Vector
	result newXY (v1 -> x - v2 -> x, v1 -> y - v2 -> y)
    end minus

    fcn scalarMult (v : ^Vector, s : real) : ^Vector
	result newXY (v -> x * s, v -> y * s)
    end scalarMult

    fcn unit (v : ^Vector) : ^Vector
	if v -> magnitude = 0 then
	    result clone (nullVector)
	end if
	result newXY (v -> x / v -> magnitude, v -> y / v -> magnitude)
    end unit
end Vectors
