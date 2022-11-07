
class LoadsTestSuite
{
	static message := "Expected {} but produced {}"

	Begin()
	{
		;
	}

	Test_String_Escapes()
	{
		input = "\"\\\/\b\f\n\r\t\u1234"
		expected := """\/`b`f`n`r`t" Chr(0x1234)
		produced := JSON.Load(input)
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Floats()
	{
		input = 1.12345
		expected := 1.12345
		produced := JSON.Load(input)
		Yunit.assert(Abs(produced - expected) < 0.0005, Format(this.message, expected, produced))
	}

	Test_Invalid_Input_Array()
	{
		input = [1}
		try
			JSON.Load(input)
		catch e
			pass = pass
		Yunit.assert(e.message == "Failed to parse JSON (-1,0)", e.message)
		Yunit.assert(e.extra == "Unexpected character at position 3: '}'", e.extra)
	}

	Test_Invalid_Input_Special()
	{
		input = [trne]
		try
			JSON.Load(input)
		catch e
			pass = pass
		Yunit.assert(e.message == "Failed to parse JSON (-1,0)", e.message)
		Yunit.assert(e.extra == "Unexpected character at position 4: 'n'", e.extra)
	}

	Test_Array_Numbers()
	{
		expected := [1, 2, 3]
		produced  = [1, 2, 3]
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Array_Strings()
	{
		expected := ["a", "b", "c"]
		produced  = ["a", "b", "c"]
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Array_Specials()
	{
		; Save default value
		startBoolsAsInts := JSON.BoolsAsInts
		startNullsAsStrings := JSON.NullsAsStrings

		; Test BoolsAsInts True
		JSON.BoolsAsInts := True
		expected := [1, 0]
		produced  = [true, false]
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))

		; Test BoolsAsInts False
		JSON.BoolsAsInts := False
		expected := [JSON.true, JSON.false]
		produced  = [true, false]
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))

		; Test NullsAsStrings True
		JSON.NullsAsStrings := True
		expected := [""]
		produced  = [null]
		produced := JSON.Load(produced)

		; Test NullsAsStrings False
		JSON.NullsAsStrings := False
		expected := [JSON.Null]
		produced  = [null]
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))

		; Restore default value
		JSON.BoolsAsInts := startBoolsAsInts
		JSON.NullsAsStrings := startNullsAsStrings
	}

	Test_Array_Nested()
	{
		expected := [[1, 2], [3, [4, 5], 6], [7, 8]]
		produced  = [[1, 2], [3, [4, 5], 6], [7, 8]]
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Object_Numbers()
	{
		expected := {"key2": 2, "key1": 1}
		produced  = {"key2": 2, "key1": 1}
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Object_Numeric_Keys()
	{
		input  = {1: "failure"}
		try
			JSON.Load(input)
		catch e
			pass = pass
		Yunit.assert(e.message == "Failed to parse JSON (-1,0)", e.message)
		Yunit.assert(e.extra == "Unexpected character at position 2: '1'", e.extra)
	}

	Test_Object_Strings()
	{
		expected := {"key2": "2", "key1": "1"}
		produced  = {"key2": "2", "key1": "1"}
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Object_Nested()
	{
		expected := {"k1": {"k1": 1, "k2": 2}, "k2": {"k1": 3, "k2": {"k1": 4, "k2": 5}, "k3": 6}, "k3": {"k1": 7, "k2": 8}}
		produced  = {"k1": {"k1": 1, "k2": 2}, "k2": {"k1": 3, "k2": {"k1": 4, "k2": 5}, "k3": 6}, "k3": {"k1": 7, "k2": 8}}
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Data_Types()
	{
		expected := [1, 2147483649, 0.1, "a"]
		produced  = [1, 2147483649, 0.1, "a"]
		produced := JSON.Load(produced)
		Yunit.assert(ObjGetCapacity(produced, 1) == "", "1 decoded as string")
		Yunit.assert(ObjGetCapacity(produced, 2) == "", "2147483649 decoded as string")
		Yunit.assert(ObjGetCapacity(produced, 3) == "", "0.1 decoded as string")
		Yunit.assert(ObjGetCapacity(produced, 4) != "", """a"" not decoded as string")
	}

	Test_Big_Ints()
	{
		expected := [9223372036854775807, -9223372036854775808, {-1: -2147483648, 0: 2147483648, 1: -2147483649, "a": 2147483649}]
		produced  = [9223372036854775807, -9223372036854775808, {"-1": -2147483648, "0": 2147483648, "1": -2147483649, "a": 2147483649}]
		produced := JSON.Load(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	End()
	{
		;
	}
}

isEqual(o1, o2)
{
	if (!IsObject(o1) && !IsObject(o2)) ; Neither objects
		return (o1 == o2)
	if (IsObject(o1) ^ IsObject(o2)) ; Only one is an object
		return false
	; else Both objects
	
	; Reference check
	if (o1 == o2)
		return true
	
	; Count check
	if (ObjCount(o1) != ObjCount(o2))
		return false
	
	; Equivalency check
	e1 := o1._NewEnum()
	e2 := o2._NewEnum()
	k1 := v1 := k2 := v2 := ""
	while (e1.Next(k1, v1) && e2.Next(k2, v2))
	{
		if !isEqual(k1, k2)
			return false
		if !isEqual(v1, v2)
			return false
	}
	
	; Enums not dry, mismatched
	if (e1.Next(k1, v1) || e2.Next(k1, v1))
		return false
	
	return true
}
