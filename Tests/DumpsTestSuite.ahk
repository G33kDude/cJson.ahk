
class DumpsTestSuite
{
	static message := "Expected {} but produced {}"

	Begin()
	{
	}

	Test_Invalid_Input_Num()
	{
		expected = Input must be object
		try
			produced := cJson.Dumps(42)
		catch e
			produced := e.message
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Invalid_Input_String()
	{
		expected = Input must be object
		try
			produced := cJson.Dumps("string")
		catch e
			produced := e.message
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Object_Empty()
	{
		expected = []
		produced := cJson.Dumps({})
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Numbers()
	{
		expected = [3, 2, 1]
		produced := cJson.Dumps([3, 2, 1])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Strings()
	{
		expected = ["a", "1", ""]
		produced := cJson.Dumps(["a", "1", ""])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Object_Numbers()
	{
		expected = {"key1": 1, "key2": 2}
		produced := cJson.Dumps({"key2": 2, "key1": 1})
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Object_Strings()
	{
		expected = {"key1": "1", "key2": "2"}
		produced := cJson.Dumps({"key2": "2", "key1": "1"})
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Empty()
	{
		expected = []
		produced := cJson.Dumps([])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Nested()
	{
		expected = [[1, 2], [3, [4, 5], 6], [7, 8]]
		produced := cJson.Dumps([[1, 2], [3, [4, 5], 6], [7, 8]])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Com()
	{
		expected = \["Unknown_Object_\d+"\]
		produced := cJson.Dumps([ComObjCreate("WScript.Shell")])
		Yunit.assert(produced ~= expected, Format(this.message, expected, produced))
	}

	Test_Array_Specials()
	{
		expected = [true, false, null]
		produced := cJson.Dumps([cJson.True, cJson.False, cJson.Null])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Floats()
	{
		expected = [0.500000, -0.750000, "0.5", 85070591730234615865843651857942052864.000000]
		produced := cJson.Dumps([1/2, -3/4, 0.5, (0xFFFFFFFFFFFFFFFF*1.0)**2])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Emoji()
	{
		expected =
		( LTrim Join%A_Space%
		["\uD83D\uDCCE\uD83D\uDC1F\uD83D\uDC9D\uD83D\uDC24\uD83D\uDD3C\uD83C\uDFE1\uD83D\uDC53
		\uD83C\uDF69\uD83C\uDF05\uD83C\uDF33\uD83D\uDC14\uD83C\uDFE9\uD83C\uDF4E
		\uD83D\uDCF5\uD83C\uDF6D\uD83C\uDF16\uD83D\uDD20\uD83C\uDF5A"]
		)
		produced := cJson.Dumps(["📎🐟💝🐤🔼🏡👓 🍩🌅🌳🐔🏩🍎 📵🍭🌖🔠🍚"])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	End()
	{
	}

}
