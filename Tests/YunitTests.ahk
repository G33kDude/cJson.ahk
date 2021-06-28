#NoEnv
SetBatchLines, -1

#include ../cJson.ahk
#include ../Lib/Yunit
#Include Yunit.ahk
#Include Window.ahk
#Include StdOut.ahk
#Include JUnit.ahk
#Include OutputDebug.ahk

MCLib.CompilerPrefix := "C:\TDM-GCC-64\bin\x86_64-w64-mingw32-"

Yunit.Use(YunitStdOut, YunitWindow, YunitJUnit, YunitOutputDebug).Test(LoadsTestSuite, DumpsTestSuite)

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

	End()
	{
	}

	; Nothing

; com := ComObjCreate("WScript.Shell")

; obj := {80085: 1, -42: 2, "aah": "bbg", 3.3: 4.5, "IE": ie, 5: "5", "emoji": "📎🐟💝🐤🔼🏡👓 🍩🌅🌳🐔🏩🍎 📵🍭🌖🔠🍚 📗🌇🍵🔌💹🕠 🕣🐟🍰🕟🏆🐛 🔈🐎📖👶🌠📁 👻🌴🔼🎭🐣🍰 🔬🍵📛🍪 🌠📇💷🕑 🎋👬🔢🗼🕦 🕀🏁🔊🔛 👙🏠🔃🐹💆 🐗💪🌎🔅🐶📮👧 👄📮💄💜🍠🏇. 🔰👠🎵🌌🌿 🔁📲🍏📴🎧💡 🕐👟🎁🐡 🏡🕣🏤🔊🍆🌑 🐫🍰💱👮🐞 🕃🐠👨👭🍁🕕👉 💑💚💶🐎🏦👗🕡 🔎📠🌋🐁 🌗🐡🎥👆🕑📌🌗📲 👳🎤💆🌓📛💴🎆 🔑📱🔃🍆🐺👊💢 💿📯🐝🍰. 📧🎳🎐📛🎱 🕘🏨🏆🍚🔆🔟🏦 🐳🕐🎷🔐🐆📶 💏🗼📓💄🐻🌓🔘 🍄🎭📗📅🎶 🎱📈💰🍠👹"}

; obj := ["abc"]

; obj := [objTrue, objFalse, objNull]
; obj := {1: 1, 3: 3 }
; obj := {(objTrue): "E"}

; obj := {({}): ComObjCreate("WScript.Shell")}

; msgbox, % cJson.Dumps([cJson.True, cJson.False, cJson.Null])
}

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
		produced := cJson.Loads(input)
		Yunit.assert(produced == expected, Format(this.message, expected, produced))
	}

	Test_Floats()
	{
		input = 1.12345
		expected := 1.12345
		produced := cJson.Loads(input)
		Yunit.assert(Abs(produced - expected) < 0.0005, Format(this.message, expected, produced))
	}

	Test_Invalid_Input_Array()
	{
		input = [1}
		try
			cJson.Loads(input)
		catch e
			pass = pass
		Yunit.assert(e.message == "Failed to parse JSON (-1,0)", e.message)
		Yunit.assert(e.extra == "Unexpected character at position 3: '}'", e.extra)
	}

	Test_Invalid_Input_Special()
	{
		input = [trne]
		try
			cJson.Loads(input)
		catch e
			pass = pass
		Yunit.assert(e.message == "Failed to parse JSON (-1,0)", e.message)
		Yunit.assert(e.extra == "Unexpected character at position 4: 'n'", e.extra)
	}

	Test_Array_Numbers()
	{
		expected := [1, 2, 3]
		produced  = [1, 2, 3]
		produced := cJson.Loads(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Array_Strings()
	{
		expected := ["a", "b", "c"]
		produced  = ["a", "b", "c"]
		produced := cJson.Loads(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Array_Specials()
	{
		expected := [cJson.true, cJson.false, cJson.null]
		produced  = [true, false, null]
		produced := cJson.Loads(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Array_Nested()
	{
		expected := [[1, 2], [3, [4, 5], 6], [7, 8]]
		produced  = [[1, 2], [3, [4, 5], 6], [7, 8]]
		produced := cJson.Loads(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Object_Numbers()
	{
		expected := {"key2": 2, "key1": 1}
		produced  = {"key2": 2, "key1": 1}
		produced := cJson.Loads(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Object_Strings()
	{
		expected := {"key2": "2", "key1": "1"}
		produced  = {"key2": "2", "key1": "1"}
		produced := cJson.Loads(produced)
		Yunit.assert(isEqual(produced, expected), Format(this.message, expected, produced))
	}

	Test_Object_Nested()
	{
		expected := {"k1": {"k1": 1, "k2": 2}, "k2": {"k1": 3, "k2": {"k1": 4, "k2": 5}, "k3": 6}, "k3": {"k1": 7, "k2": 8}}
		produced  = {"k1": {"k1": 1, "k2": 2}, "k2": {"k1": 3, "k2": {"k1": 4, "k2": 5}, "k3": 6}, "k3": {"k1": 7, "k2": 8}}
		produced := cJson.Loads(produced)
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
	if (IsObject(obj1) ^ IsObject(obj2)) ; Only one is an object
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
	while (e1.Next(k1, v1) && e2.Next(k2, v2))
	{
		if !isEqual(k1, k2)
			return false
		if !isEqual(v1, v2)
			return false
	}
	
	; Enums not dry, mismatched
	if (enum1.Next(k1, v1) || enum2.Next(k1, v1))
		return false
	
	return true
}
