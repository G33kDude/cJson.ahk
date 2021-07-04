
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
