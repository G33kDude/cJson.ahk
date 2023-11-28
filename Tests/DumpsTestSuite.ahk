#Requires AutoHotkey v2.0

class DumpsTestSuite
{
	Begin()
	{
		this.message := "Expected {} but produced {}"
	}

	Test_Invalid_Input_Num()
	{
		expected := 'Input must be object'
		try
			produced := JSON.Dump(42)
		catch as e
			produced := e.message
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Invalid_Input_String()
	{
		expected := 'Input must be object'
		try
			produced := JSON.Dump("string")
		catch as e
			produced := e.message
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Object_Empty()
	{
		expected := '{}'
		produced := JSON.Dump(Map())
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Numbers()
	{
		expected := '[3,2,1]'
		produced := JSON.Dump([3, 2, 1])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Strings()
	{
		expected := '["a","1",""]'
		produced := JSON.Dump(["a", "1", ""])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Object_Numbers()
	{
		expected := '{"key1":1,"key2":2}'
		produced := JSON.Dump(Map("key2", 2, "key1", 1))
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Object_Strings()
	{
		expected := '{"key1":"1","key2":"2"}'
		produced := JSON.Dump(Map("key2", "2", "key1", "1"))
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Empty()
	{
		expected := '[]'
		produced := JSON.Dump([])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Nested()
	{
		expected := '[[1,2],[3,[4,5],6],[7,8]]'
		produced := JSON.Dump([[1, 2], [3, [4, 5], 6], [7, 8]])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Array_Com()
	{
		expected := '\["Unknown_Object_\d+"\]'
		produced := JSON.Dump([ComObject("WScript.Shell")])
		Yunit.assert(produced ~= expected, Format(this.message, expected, produced))
	}

	Test_Array_Specials()
	{
		expected := '[true,false,null]'
		produced := JSON.Dump([JSON.True, JSON.False, JSON.Null])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Floats()
	{
		expected := '[0.5,-0.75,0.5,3.4028236692093846e+38]'
		produced := Json.Dump([1/2, -3/4, 0.5, 2.0**128])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Emoji()
	{
		expected := (
			'["\uD83D\uDCCE\uD83D\uDC1F\uD83D\uDC9D\uD83D\uDC24\uD83D\uDD3C\uD83C\uDFE1\uD83D\uDC53'
			' \uD83C\uDF69\uD83C\uDF05\uD83C\uDF33\uD83D\uDC14\uD83C\uDFE9\uD83C\uDF4E'
			' \uD83D\uDCF5\uD83C\uDF6D\uD83C\uDF16\uD83D\uDD20\uD83C\uDF5A"]'
		)
		produced := JSON.Dump(["📎🐟💝🐤🔼🏡👓 🍩🌅🌳🐔🏩🍎 📵🍭🌖🔠🍚"])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Escape_Unicode()
	{
		JSON.EscapeUnicode := False
		expected := '["📎🐟💝🐤🔼🏡👓 🍩🌅🌳🐔🏩🍎 📵🍭🌖🔠🍚"]'
		produced := JSON.Dump(["📎🐟💝🐤🔼🏡👓 🍩🌅🌳🐔🏩🍎 📵🍭🌖🔠🍚"])
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Big_Numbers()
	{
		expected := (
			'{"-9223372036854775808":0,"-2147483649":0,"-2147483648":0,"0":['
			'-9223372036854775808,-2147483649,-2147483648,2147483647,2147483648,9223372036854775807'
			'],"2147483647":0,"2147483648":0,"9223372036854775807":0}'
		)
		produced := Map(-9223372036854775808, 0 ; 32-bit 0
		, -2147483649, 0                     ; 32-bit 2147483647
		, -2147483648, 0                     ; 32-bit -2147483648
		, 0, [-9223372036854775808, -2147483649, -2147483648, 2147483647, 2147483648, 9223372036854775807]
		, 2147483647, 0                      ; 32-bit 2147483647
		, 2147483648, 0                      ; 32-bit -2147483648
		, 9223372036854775807, 0)            ; 32-bit -1

		produced := JSON.Dump(produced)
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Garbage_Collection()
	{
		deleted := false
		sample := [[{__Delete: ((*) => deleted := true)}]]
		JSON.Dump(sample)
		sample := ""
		Yunit.Assert(deleted, "Was not deleted!")
	}

	End()
	{
	}

}
