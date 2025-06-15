;
; cJson.ahk 2.1.0-git-built
; Copyright (c) 2023 Philip Taylor (known also as GeekDude, G33kDude)
; https://github.com/G33kDude/cJson.ahk
;
; 0BSD License
;
; Permission to use, copy, modify, and/or distribute this software for
; any purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL
; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
; OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE
; FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
; DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
; AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
; OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;
#Requires AutoHotkey v2.0

class JSON
{
    static version := "2.1.0-git-built"

    /**
     * When true, Boolean values in the JSON will be decoded as numbers 1 and 0
     * for true and false respectively.
     *
     * When false, Boolean values in the JSON will be decoded as references to
     * {@link JSON.True} and {@link JSON.False} for true and false respectively.
     *
     * By default, this property is true.
     */
    static BoolsAsInts {
        get => this.lib.bBoolsAsInts
        set => this.lib.bBoolsAsInts := value
    }

    /**
     * When true, null values in the JSON will be decoded as ''.
     *
     * When false, null values in the JSON will be decoded as references to
     * {@link JSON.Null}.
     *
     * By default, this property is true.
     */
    static NullsAsStrings {
        get => this.lib.bNullsAsStrings
        set => this.lib.bNullsAsStrings := value
    }

    /**
     * When true, unicode values in the JSON will be encoded using backslash
     * escape sequences, such as '💩' will be encoded as "\ud83d\udca9". This
     * is to improve compatibility with external systems.
     *
     * When false, unicode values will be left as their original characters.
     *
     * By default, this property is true.
     */
    static EscapeUnicode {
        get => this.lib.bEscapeUnicode
        set => this.lib.bEscapeUnicode := value
    }

    /**
     * Utility function for the MCode to convert non-string values to string.
     */
    static fnCastString := Format.Bind('{}')

    /**
     * Constructor
     */
    static __New() {
        this.lib := this._LoadLib()

        ; Populate globals
        this.lib.objTrue := ObjPtr(this.True)
        this.lib.objFalse := ObjPtr(this.False)
        this.lib.objNull := ObjPtr(this.Null)

        this.lib.fnGetMap := ObjPtr(Map)
        this.lib.fnGetArray := ObjPtr(Array)

        this.lib.fnCastString := ObjPtr(this.fnCastString)
    }

    /**
     * Internal function to load the MCode
     */
	
	static _LoadLib32Bit() {
		static lib, code := Buffer(6712), codeB64 := ""
		. "wrgAVYnlV1ZTgewAbAEAAItFFIsAdQiLXQyJhcwQ/v//igIoiIXTAQAUiwZmg/gDdQAci0YIiVwkBACJRcjB+B+JRQDMi0UQiUQkCCCNRcjrFABC"
		. "FHUeGwEiAUIBKgBYBCToAGEWAADpVQYAOgAAQAgKQAGaACCcFwUAIDQDIAUPhbEAAAAAMcCNfcy5AgMACfIPEEYI8wCrjUW4jU2oxxRFuAASAAB+"
		. "oZwTIAAAx0W8AQ6LEACJTCQYjU3IZhUAHwUAFdAAzADHRCwkIAEdAAccAjRMJKoUAAsQBBsMBBsIhAMCBIIRBCTyDxFFAMD/UhgxwIPsACSLVbBm"
		. "ixQCAGaF0g+EkwUAAACF23QMiwuNAHECiTNmiRHrAAWLdRD/BoPAQALr1rpUFYJfCQB0M2YPvgKEwAR0GAQWeQKJO2YEiQEAFkUQ/wBCZOvgi5Dp"
		. "HIArAIS6ImQAIDsFsABrdSQxAyEPhB+NOQcj3LpqaQIYqAoY7gBjFhhvFQIYrAoYvRgMixCNHI3YAH9ARQFPjY3c6QADx4VBAXSAEgFTBE9WDAFV"
		. "wAgIAVK0ABj/EFIUi5XBDoPsGICD+v91KbqIwUctBB0PBx1NR9xAfr3oTQAOuQFkwH19rIKBZjTHhUEFCIEEQgKNvQL4RQmJRagxwPNGqwBRAwXH"
		. "hfBAAfwKFAGIsEEmiwiJfAkAiH2ogAEUjb0I4v/ANFQkBE2IUYcBM9nAP/9RAISFJIUBEAIDY4CIAB+NvRgABIUgfTiojY3BA0AswQkIAGjHhRDA"
		. "ARTAPwOqi+sDVYIiKIEiTKsiwaaGIvsBEIoiOIwiwQOAIsEJgSL6MMABvEBGiSIuZUATFhAngBWDEAAOZoPiLQN1EAmDvQAACwB1WddAAoEfQgIg"
		. "QgJSQAKBEEADdRODvUBBAseUhdSgBgKgCnU/6kKe9yAO9UKDBkER6wpjAWvBE6FFSEYgveIKYx9NAJiLEItSFA+F00GEwldNuMCDmhxXYRvQ0otV"
		. "mPJWV/gTIZbeyMQyIlHBEgVPyEEqX04JTU7ptGYXiI19uJHiFEWIrEEYRZjFB78pGaoYp0REqWAaA6mNYRONgaUDQamgFcdFwMEx4wapYQ6LTZg0"
		. "qaEO4QnLfUOhDAkCKHRgnqIWyw0hxB6gHCAHDosDjQBQAokTZscAIkIAZAcx/+nTw4kbAeM/AYsTGcCD4ADgjUoCg8B7iZALZokCRAWAvQHaSAC6"
		. "uiASdWhBR1gxRUfHhcikSyAkvWhLxQKBAXiIAX2IJgGYiSQBD7YC5ImFxKAArOmpYAJAERXHqUIjHxB16euOghDr7maAg32YAw+FHUAogIN9oAAP"
		. "hBMhASK9AhAPhEZiTA+EdhQB8sYdLIAXwQyDFw8MhQ+hA6JgSIP4AagPhk7C9xhBKEDgJqwQi8IRIAEMBSmFgRp5YSkK+AABwh1jAnAgiAQMQMUr"
		. "iUWQjXUIiI2VkRHzpYlVwICNfdiNtTEQQEQRYQAMQIlkLqWNfTa8ciVBJcgAN1QkiUWwuIuFUNEv5CS4r3iPD0ZFJKh4gySJx4WgN5rH0RXq4AVC"
		. "FOnu4ACbfxZzFi50FhQTD4RhAArrkSck7wLpRzt9kBgPj7AgArq9oBXE6+fTA9+LhSEQU49loAMRqSfpgcEycgJ6nVKPSc8p4gGpfoVgBBi0UQ0T"
		. "HstBBFkFxQABZLq/dIR1KCwz7XngQosSBetNusgjAwhMdSq5lfYGPQ5gDWhL3xLTEgfUEg+/Ag+JzIXgoBAxOIXkcZ8JDLuRAQEFkAAbDg90BC2A"
		. "AVgpiwO0F/UBOlAYXRL9ECdQBPEAQAIguADpTfAAMAMglItxAgJA5RpFwokG6TB7wQEVGAkgAtIMACVRIQic6xXiDlQBMQEVtDBt7FGLAy0UA3Af"
		. "A1QBFgOOUoYqUgIJQlB1LqAM0nY/RcB9M0VgHxUbFYAxyTtNGH26YiUsigJztPAcIHADFIvAM41GAokDMANiAQhmiQZ2HdRB68cBogCNZfSJ+Fte"
		. "QF9dw5CQkHG6v1Ds/3//wbqckSN1AAyLXQhmxwYUKADHRkOsRoI0iwMCZvAMRaSNSvdmQIP5Fw+H9mA2iQD40/iJwYDhASB1CotFpBCriQMA69Zm"
		. "g/pbD4U6taJDpAVAsgEBhKGgP9A4wDtKYa9gXzxfPItF0MCNVbTAmNigECA9DMdFgW2AQqSLAIuEfaSAcRSNVbBueYJUaHk8JP9QFABsI9INpA13"
		. "E7oREdP6oIDiAXUaQw3fQA2wXQ+EvyGjUbu2gQRCdBAsHCTouEFDwIgPhYbQBY193LJLOI1V2PB6gAhgCHXYmMdF4PKisQcUiyALfe8OGG8PGHAg"
		. "fqIKE3A+0glAGkYI5SVSAhwaDKgQifrjCxHjC+LgCwgsD4RRmosTg8hBsCw6XQ+F3WDAgwzCAmAK0TMGCQDphs3QFaACIg+FADJRkqQQNIPAwDWJ"
		. "VjEhEAgA6dUREIP6e1gPhRVyPAAe2AwepL0LHthvWm9aDx4CHn3S0ioDEB1m0DxIkyeGScFSCvh9D4SakQBxXMKRIwEiD4RLkAAQDgTpAMANZoXJ"
		. "dPMEjXpBgYP5XA+FQgkgB2aLSgLQACLkdSEAQ/4iABDgDcALAIsTjXj+ZosKEbIBxunncg75bnQIWn8qcABidEp/IZDo+S90OqEEdZ0hwQNcAOvB"
		. "0ABmdUKP0QAMAOuz0AB0QZDag/l1dDhQAHIID4VxIm5A/g0AhOuVcQAvAOuNcQAQCADrhXEACgDp9nokAvAXb6AAAAlgmEJzBTFN/iELUP6LO8EA"
		. "4gSJfaRmiVABUAoPjXnQZoP/AAl3BAH66yCNBHm/wAAFdwaNVIAKyesRjXmf4QCID4f1wXhUCqlAKAFhA4PHAv9NmIkgO3Wv6QwhB4lIWP7pAxEh"
		. "MJL5cCApgMGJSPxmxweBByTp3vAfjUJABvgJBA+WUA76LQ+UwAAIwYhNpA+EzhthFBFCvyIcbUKDOC0Adcy2AAiDwAKDz/+JAAOLA2aLAGaDAPgw"
		. "dRPHRggAEQAAx0YMATCDAwIg61iD6DEAbAgPAIdK/v//iwtmAIsBZolFooPoAjAAVAl3OWtGDAAKg8ECiUWUuAIKAGT3ZgiJC4kAVZyJRZiLRZQA"
		. "AUWcD79FopkAA0WYE1Wcg8AA0IPS/4lGCIkQVgzrtQDqgzguBHQTAX0Qg+LfZoCD+kV0RenNAXcQwAK5AQAHiQPfAG4IZscGBQDdgF4IixNmiwIF"
		. "dgDKa8kKg8ICiYATiU2Y20WYAJGAmN59mNxGCAAoFOvVAD+JAF0+FHUOCwlAAWgAZS10CsaERaQA8PordQUCFQMCgAQtD4di/f//RDHAgXQRg+qA"
		. "CfogCXcPa8ABcg+/ANKJCwHQ6+MxBMm6gU85yHQGawDSCkHr9oB9pBQA3QBsVYFGdAfeovmBQwXeyQE7FgAhABR1I4n4i04MAJmLRggPr88PQK/C"
		. "AcGJ+ACWAZLKg4fpEQAoMcAAFTAFD4XogAWBJn2kSNpNpAAh6dcACLkIZBUAAVp0dUFmIA++AYTAAJ0TQQBmOwIPhbD8/wL/gobr5YA9kBOpgEx0"
		. "DoB6A4DjCIFThOtKgAYJAKGwAA0k6ZwACLlpgyVmdWpFzRJkzxIVxRKIhusKZIMUqEAI60y5b2HDE24PhSTAD80UEBXJFJjCFA+ADwgAoaYkwA0A"
		. "QOsWQxOswAYBgAOLEIkEJP9SQARQMcDp3EALugDs/3//0/qJ0YCA4QEPhbj7wKEkVaQCFOmDAAONRQDIiRwkiUQkBADo0Pj//4XADwyFnsEIwXuN"
		. "SvdmIIP5F3cxxBCA4g1AEIBABwJ+69uLEwCDyP9mgzp9dQZ2AhTCIYl+COuEIYAzOg+FVYUKiXSkJARAGehuRBg8QRhERdCABQiJPAMfjygCAAAK"
		. "HRMHHXWWIwMcgbksdYkCA+nGAvoAL2X0W15fXfjDkJBBasUAPwA/AB8ALx8AHwAfAA0AEGAATwAAdwBuAFAAcgDgbwBwAHOfBggAwVioUAB1oAZo"
		. "6gIGYAAgUwBlAHTsBTAxADIzNDU2Nzg5QEFCQ0RFRqJgGKHgAhkAAPrgAE/gAArf4AAV4AAiVW5rAG5vd25fVmFsAHVlXwB0cnVlAABmYWxzZQBu"
		. "gHVsbABIAGHgDmpNogxoYBdkYAlmBk9AYmplY3RfsRtfRSAARWACdQBtoAENYAoACQAixQXmB1QMeXBADmobVYnlVwBWjVW0jX28UwCD7HyLdQiL"
		. "XRAQx0W0YQOLBolAVCQUjVUMwAAIqMdEJOEqAOAADAFQCeAABLShcTQk/1AgFIsDuQMhBlMMAIPsGGbHRdgIIgBArsiLQyCe1I0AVbiJRdCLRQyA"
		. "iUXgMcDzq8BxCMdFwGBhAIlFuNSLBiAJICQLHOQAgCW3gAOAD6EOBKQOZAMIoQ4HoQ9iBKEPGIPsJGZggzsJdQzgDUSDCIZQ52ZiHFOB7KwhFDJF"
		. "wL1F5gABoAVQBACLAInBidOBwQEgA4CD0wCD+wAID4atAhOgjX2wDDHAohohFpiJVaQAjU2IiUWsoZwJ4Q9FmCIkEIlMJEAYjU2sx0WhpgDpQAuY"
		. "FIADtCQk6hpABT/iGWQD5hnkAOMZYRcYMQLAIBqLVZBmixSAAmaF0g+Ei0ADAIX2dAyLDo1ZAAKJHmaJEesFIIt9EP8HwITr1hS5FMADu4HrhcB5"
		. "RCu/AQGZuzChCU0AhEn3/ynTZokAXE2+hcB16YsATYSD6QJmx0QATb4tAOsQmUkA9/uDwjBmiVQBwgPwAcmNRA2+oYHghdJ0GhYO3qAVDDHAwxWz"
		. "FYPsDIsAXQyLfQiLdRAAhdt0DosDjVABslIAIgDrKf8GROslkHMNfixQACJUdUcQAk4RAgTwAVwCAGECQAIiAIPHIAJmiwdmcAjT6YZBMBKwAgcP"
		. "jsdgDEiNUPhib4e6wAAPQLfS/ySVPOJk+CBcdArppfGABgIU679gBfdtBVwA6wqncAHffQFiAOuPBXABx30BZgDpdP8R8FvbdKytAW4A6QpZowGR"
		. "rQFyAOk+MaIBD4RycADtAXQAROkfYAGAPZSSbQsIjVDg8AxedxHrEEKNUIGgACF2BnHADB93M8AFoDTbA3UYAOsD8A1yZFwkBEgPtwdAIug8kATp"
		. "BskAlyADD4sTjUoAAokLZokC6bZhIAH/BumvkwGLGAIg/waDxAx0GzHARInlgRsQi1WwGxAAi00Iic5mwemQBIPmD9B5tigBFgCJdEXwQIP4BBh1"
		. "5LhxMEAhEYsKgI1xAokyZougAQhmiTEwBQOD6AFgc+SDxBAhIeE2kA=="
		if (32 != A_PtrSize * 8)
			throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if IsSet(lib)
			return lib
		if !DllCall("Crypt32\CryptStringToBinary", "Str", codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(3988), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
			throw Error("Failed to convert MCL b64 to binary")
		if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", code, "UInt", 6712, "Ptr", buf, "UInt", buf.Size, "UInt*", &DecompressedSize := 0, "UInt"))
			throw Error("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
		for import, offset in Map(['OleAut32', 'SysFreeString'], 5300) {
			if !(hDll := DllCall("GetModuleHandle", "Str", import[1], "Ptr"))
				throw Error("Could not load dll " import[1] ": " OsError().Message)
			if !(pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", import[2], "Ptr"))
				throw Error("Could not find function " import[2] " from " import[1] ".dll: " OsError().Message)
			NumPut("Ptr", pFunction, code, offset)
		}
		for offset in [185, 329, 394, 400, 443, 449, 492, 498, 567, 595, 617, 730, 800, 873, 939, 1012, 1068, 1153, 1264, 1292, 1313, 1427, 1459, 1490, 1608, 1634, 1780, 1969, 2189, 2316, 2449, 2500, 2760, 2810, 2837, 2915, 3099, 3155, 3182, 3235, 3402, 3580, 3636, 4528, 4567, 4594, 4604, 4643, 4677, 4684, 4727, 4740, 4755, 5436, 5440, 5444, 5448, 5452, 5456, 5665, 5783, 5911, 6299, 6481, 6652]
			NumPut("Ptr", NumGet(code, offset, "Ptr") + code.Ptr, code, offset)
		if !DllCall("VirtualProtect", "Ptr", code, "Ptr", code.Size, "UInt", 0x40, "UInt*", &old := 0, "UInt")
			throw Error("Failed to mark MCL memory as executable")
		lib := {
			code: code,
		dumps: (this, pObjIn, ppszString, pcchString, bPretty, iLevel) =>
			DllCall(this.code.Ptr + 0, "Ptr", pObjIn, "Ptr", ppszString, "IntP", pcchString, "Int", bPretty, "Int", iLevel, "CDecl Ptr"),
		loads: (this, ppJson, pResult) =>
			DllCall(this.code.Ptr + 2984, "Ptr", ppJson, "Ptr", pResult, "CDecl Int")
		}
		lib.DefineProp("bBoolsAsInts", {
			get: (this) => NumGet(this.code.Ptr + 5008, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5008)
		})
		lib.DefineProp("bEscapeUnicode", {
			get: (this) => NumGet(this.code.Ptr + 5012, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5012)
		})
		lib.DefineProp("bNullsAsStrings", {
			get: (this) => NumGet(this.code.Ptr + 5016, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5016)
		})
		lib.DefineProp("fnCastString", {
			get: (this) => NumGet(this.code.Ptr + 5020, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5020)
		})
		lib.DefineProp("fnGetArray", {
			get: (this) => NumGet(this.code.Ptr + 5024, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5024)
		})
		lib.DefineProp("fnGetMap", {
			get: (this) => NumGet(this.code.Ptr + 5028, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5028)
		})
		lib.DefineProp("objFalse", {
			get: (this) => NumGet(this.code.Ptr + 5032, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5032)
		})
		lib.DefineProp("objNull", {
			get: (this) => NumGet(this.code.Ptr + 5036, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5036)
		})
		lib.DefineProp("objTrue", {
			get: (this) => NumGet(this.code.Ptr + 5040, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5040)
		})
		return lib
	}
	
	
	static _LoadLib64Bit() {
		static lib, code := Buffer(7104), codeB64 := ""
		. "crgAQVdBVkFVQVQAVVdWU0iB7BgAAgAAiwFEiUwAJGhJic9AimwBATjUTInGZoP4AAN1FkhjQQhIAI2MJOABAABIJImEAhzrCgA2FHUAFEiNSQhJ"
		. "ifAATIni6GcYAAAg6TYMAAAAMgh1AA5Ii0kI6AMZBQAmIgMmBQ+F2gAAAADyDxBBCDEIwLkGAAtFMclIEI28JMgAUEUxwCBIjZQksAFjx4QMJPAA"
		. "BwEA86tIi0gNTRQAFI2EAidmWwAcAQcFBooBLugELkiAiwFIiVQkMAFKwQOuVCQoMdIEUAEkYEjHRCRAAioABDgLAQSAAyCBDPIPEYREJNCABP9Q"
		. "MABGiwiUJLiBN4sUAmYAhdIPhFwLAAAATYXkdBFJiwwAJEyNQQJNiQQAJGaJEesC/wYASIPAAuvNSI0IFc8VAnUJdC5mgA++AoTAdB0QGQIBAhn/"
		. "wuvbSY0gTwjphAWBW0kIIEg7DbQTAXQVmQmAInUpgyAPhOMKqxI8hiLXABxbAxxlChyqqiAcMgMOMgoOcR4OCI0FBUAMSI1UJFh8QbmCVQBjgANg"
		. "TICNLfwSAABMAGxjQgSBYEyJ6oFZgVv/CFAoi4ANg/r/dZmAaRXRwHbFHWYE3B0sMduCjcGMkIOPidhgTI20JKgAA8EbwHHCdYQkuEODQI/ECwVa"
		. "vsI5vEMIwCqYggWEB4IRwQNBEInY86tJWItPCIGYwQUIQgzYPcQUsMQUhBcCPQA7iUQgJDBNieiPlUyJmHQkKMWWgJSJ2IW88cC0jQVNACQCBAEP"
		. "QbL3BCSCG4Ad8AomwbNBBAco+8EJAygIwbnFvYUhgVilIvZioDVJERABCkARAgsADP/BBksRIQJHEeEEQBFfEEgQRGaDYzEDdQogAci5QQR1X4EC"
		. "oRyDAviCAkZOgQKhBgN1DyABKEXhB7vglQB1OaBHkxtAF6VHKKACvEfrBbsX4Qekj2EbOOABg/sCP4MZQUlhi0FJApFAGotAkCgPhcGiBT03wVqP"
		. "AD7BWcVeo5dNifDmW07QIIehByVc7xFnFIT/YQV6FAqjQZiBEaEUQxRFToehAqIDwhGNBYoPWZu06dIDGIhAEeE3mIACPwMYwDeBAaIGYBnhFkyJ"
		. "+vdudtDnEuQQoAihEmm1iEyJtCQWBfsOJ7X+A+EoYAFBqwE3C7SIt760PgPFiSAsoRbgSOArjxBjYa5DOQl0Yx+vAa+LNkdO2sTYoGAkYAcPhAJp"
		. "4LJJiwQkSI0AUAJJiRQkZsdgACIA6VWgAkELHACD+wFJixQkGQDAg+DgSI1KAkCDwHtJiQygDAKhoQyAfCRoAaskgBPYD4Wigk4hOlAADSIp0SFv"
		. "vCRoxQFMhAHDAn6AqwRhHcgBgTTGASNVMXT/SABBWMEBIQyBAWADgQHjG0QkUEAPtmLF4ABs6aXhfOAXHwesEWARkxN14elR/zEAAAbr7FEV0QUD"
		. "DxyFX7AX0AARcQAPhIJR0ACF/w+EcuMsWA+EPfETuxIs4Q8lgWApQITtD4U6AAIAjUP/g/gBD4YdQTCLwGHAIDMXTIn5AESLTCRs/8f/AsBACiDo"
		. "XPf//4pIIAKoQjhUJFhwJwPhJIEQDEBIi4wkokCCKrwkoPMmiyCGc3Ec8SNIi8AP0QJRFAywQA8QjHID4QGI4gEj0F1wAA8olBICDymtZyAIIAnh"
		. "A1BhKdh2Mf9zLNFAZCxjAWAsooWBAoItgz9gWU8PEZQk+FMrkEGJxYXQQJz+YA4ImOkE0BT/BunNT9AAkiWfGZUZ6zFgGe9JARWEr9AC6yLxAjQD"
		. "/wL1AkH/xUQ7rBGSFg+PfdEGjRWV6g3Qm95wBNeAEMEiQp4aJ5EEE+4uAjNjhCSyWHAC6d5ADFKfTM8Cb8YCQDXBAsQ0U3BAAiLVb7ADzzRxXyAJ"
		. "BCAJUZN1Ni/PO8872xEcMQbrUFvxgwWnLGEhqAeIoAfrFmUPFQsVBAEVSA+/e3Qz0AuIkQoiBBIj0ADoXo3wCS8PIg/xAzKxAS1FvAE6ci+EFP1B"
		. "F1ACBFMBQAIgAOkBSSABiwaQAv/AIQJFwMKJBunt/DAB5hgYCXUQxQxAJ/9QEIzrFDW1UwH/FZogmjcAAyFDBwNwDwNUAf8VXmkAA4UzMwIlSoGA"
		. "rXWqODEMej9NfTVNYJ8UbZsUJpEUQQIwTwL/KACUfY6gBwmgB+vigANI2/8G8FGBxJHIWwBeX11BXEFdQeBeQV/DkAIAlspBmEBJuP/Z///ALP8Q"
		. "ZscCFHA4y0iJINZIx0IIA8ATZoKLsMn5IA+HCcAEAEyJwEjT+KgBAHUJSIPCAkiJCBPr3cABWw+FyT9RUyBZQBDDgOABwsbwB52xPRMSeBBCslkF"
		. "K8AFDEi9dQdXxlQkaEw8jaTTpKPGT0BYj0iL1rwSJYEDXJCXJEEZsVpJw3hMjWFbiwcQA1xtI0b5UgWQEqpQCRi0SCCLA2aLCGEOdxQASInqSNP6"
		. "gOJFMg7AMA4D6+CQAV0ED4QBlmaFyQ+EArfCBPJIidnosVMADLBHhZxyIAdgDkx8iWQgBqAGoEwhnrSbXK1gDzSxEGABoGQBSBB+L7EOlAKfeoUA"
		. "MIwPZoOAPgl1HkiLTgGMNfEpElcLHVQLNw124iFQACwPhC2yFhODAMj/ZoM6XQ+Fhv6R0mMcZscGCeAIMH4I6Q5AAeACIg9EhSPRW41CAiACBAnx"
		. "BIlG4KkGCADpgumCS/l7D4UA0A9bXx9QHwrQAF4fNUEBv29fH18fXxBaH6xTHwYODwyGX6DOkAB9D4T0C5EAQRrrIwEiD4RdB5AAQA+jDYXJdPNM"
		. "QI1AAkyJA9ABXEgPhRRS6UgCsQJ1QCZmx0L+InAMwAMiD8ERiwNMjUL+QZMGInW/6e3TD24QdFp/KnAAYnRKAH9Ht4AUZoP5L3Q6AFAAXHWWZsdC"
		. "/lyIAOu8AGhmdYgBaBAMAOuuADR0dDMRABR1dDgAFHIPhRBq////AXQNAOsikAEOLwDrAloIAITrgAEOCgDpdQRECAkA6QFaSIPABABBuQQAAABI"
		. "iQIDAS4AAGaLQv4ATIsDweAEZokAQv5mQYsIRI0AUdBmQYP6CXdABUQB0OskAA+/AQEPBXcGjUQIyRTrEwAQnwIQD4fnCP7//wAUqUmDwAICAT9M"
		. "iQNB/8kQdarpAwF4iUr+BOn6ACFIi1YITASJwQB9Akgp0YkgSvxmQccDg+nhAAIAAI1B0GaDQPgJQQ+WwABsLQAPlMBBCMAPhAS4AYBOxwYUALpB"
		. "AAQASMdGCAADAABIiwNmgzgtdWILgiaDyv+AIoEJiyIAgCEwdQ6GE4MDQALrNoPoMQALCAgPhz4CQwtID78QAUSNSIFv+Ql3ABdMa04ICkiDgMEC"
		. "SIkLSY2AdkBIiUYI69eDMS6EdBQCLAiD4d+ASyBFdFbp8AIswAIEQbkCSYkD8kgPCCpGCIBSBQDyDwgRRggAMWaLAYME6DABaHfARWvJhAqYgS/y"
		. "DyrAgDEA8kEPKsnyD15AwfIPWEYIghjrBswCZIBjgz4UdRCHDxRBIIFFdAlFMcFHmCt1B0QMwAYxyQA+AYQbD4dZ/f//TFVAIEGHIA9AIEkAIJgA"
		. "TIkLAcHr4UUEMcnBVQBEOcl0AAhrwApB/8HrAvNAJ8jyDxBGCCBFhMB0BsEn6wSY8g9ZQClAIIsOAB0CFABWD69WCEiJMFYI6S0AEIIiBQ9shfzA"
		. "AoAPwoALBDTpBunBbQCrdVNIjQ1CXwCbZg++AQAWGABIixNI/8FmO6ACD4Wv/AGjwkAxQBPr4IA9zIEkdJoSgD0DAnqBA+nGAAElQAQJgHwNLICJ"
		. "6aurAQTBxE0AFgsTFlYLFppzAhYPBhZBhutwRRUStkAH61iAFG4PhUIdAQ6NDboDkhX/CvuKFTzDK0iLBTOxwQvHBggAg8ByFkUWImwACEiJToBv"
		. "Af9AUAgxwOnUwov6AEjT+oDiAQ+FJpLCE0Jx6XbAAkyJAOJIidnopfj/wP+FwA+FkMEDJT8oIHcYKAd1Jwfr3KGgAzoPhWJGAvKACCkAA+hd5AhI"
		. "4giUJAKgoA9JifBIielM6FIAFkcLdiugACwID4RwgYOLE4PIgP9mgzp9dSlkHcHDGYluCOk5AQSlEAR11CUQtUiBxLABgAtbXl9dQVzD/pAFAOEj"
		. "CQD9AR8AHwAfAP8fAB8AHwAfAB8AHwAfABkAAhBgAE8AdwBuAABQAHIAbwBwAI5znwYIAAFpUAB1oAYKaPIDBmAAUwBlAAZ0XwkCADAxMjM0ADU2"
		. "Nzg5QUJDqERFRmECEiBVkmAAqlBgALJgADFgAG9gAAAiVW5rbm93bgBfVmFsdWVfAAB0cnVlAGZhbABzZQBudWxsAKhIAGHgEk2iD2hgGwZkYAlm"
		. "Bk9iamVjVHRfsR9fIABFYAJ1BABtoAENCgAJAMYixQXmB1R5cEAObh9AVlNIgeyoYXyNDDWQoLAExIsBTIlAw0iJlCTIQgNUICRUTI2EgwGJVEQk"
		. "KAJ2jCTA4AHHWEQkVIEEcAAgcQD/eFAoiwBewwFAW8EDWAchPAACYgdmiUQkcIhIi0OwYoQkiCIZYkggAXhIiwQGgAJg4YJwiYQkkOIHAQMgAp5Y"
		. "YAlRBCBVYwgx0sEC1kDCAoAAOIUAMAUJAYMk/1AAZTsJcHeLSxljTRCQwD8xD1tewwJXABCD7DBBuxMJ8AC7CrMPSIXAZgXgAy6xR9JMjUwkQAZ5"
		. "NEG7FMABv0GhBUiZif5E8Er3APsp1mZDiXRZEP5J/8swA3XmgyDpAkhjwbADRAZALQDrGEiZYwKDJMIwcAIUWWQC6EgAY8lIAclJAckBAW9mhcB0"
		. "HU2FANJ0D0mLEkiNAEoCSYkKZokCCuvwiAABcOvaMcDwSIPEMJBKYEriCvAXAYAE0nQRSIsCSASNSABNCmbHACLWADIDgBx7gBxmoFKQVISEjkJt"
		. "+A1/I1AAEAcPjhHwAI1I+AlCcIcEwAAPt8lIAGMMjkgB8f/hESACInQLUABcdC2s6eehDlAGGlMGBCAGBlxwF6AGQAIiAOkCLLADQYMAAukjCyFj"
		. "cALyfwICXADpCzEG4QHT7wECYgDpyuVUBrTvAQJms3ThAYKV7wECbgDpp+MBGA+EcnJgLgJyAOkahCUCTy8CIQJ0AOsAZIA9E/r//wAgdAuNSOCQ"
		. "EV53QBHrOY1IgaAAIUR2BuAQH3cqQQgXQe8DAnUA6wRhEA9QtwvoT0F6F5ECDwBIiwpMjUkCTAWxHAFzGYPDAulmx9GcnxuUG4PEKCAptmgDAQDQ"
		. "HhgxwEyNHQaTwXagKAhJicpmBMHpMAfiD2ZHDwC+FBNmRYkUQQRI/0Ai+AR14bgLgEYSExUgCGZFixQQQUyNWXAIGmZEhIkRZAboAXPdQiUAGMM="
		if (64 != A_PtrSize * 8)
			throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if IsSet(lib)
			return lib
		if !DllCall("Crypt32\CryptStringToBinary", "Str", codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(4031), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
			throw Error("Failed to convert MCL b64 to binary")
		if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", code, "UInt", 7104, "Ptr", buf, "UInt", buf.Size, "UInt*", &DecompressedSize := 0, "UInt"))
			throw Error("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
		for import, offset in Map(['OleAut32', 'SysFreeString'], 5728) {
			if !(hDll := DllCall("GetModuleHandle", "Str", import[1], "Ptr"))
				throw Error("Could not load dll " import[1] ": " OsError().Message)
			if !(pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", import[2], "Ptr"))
				throw Error("Could not find function " import[2] " from " import[1] ".dll: " OsError().Message)
			NumPut("Ptr", pFunction, code, offset)
		}
		if !DllCall("VirtualProtect", "Ptr", code, "Ptr", code.Size, "UInt", 0x40, "UInt*", &old := 0, "UInt")
			throw Error("Failed to mark MCL memory as executable")
		lib := {
			code: code,
		dumps: (this, pObjIn, ppszString, pcchString, bPretty, iLevel) =>
			DllCall(this.code.Ptr + 0, "Ptr", pObjIn, "Ptr", ppszString, "IntP", pcchString, "Int", bPretty, "Int", iLevel, "CDecl Ptr"),
		loads: (this, ppJson, pResult) =>
			DllCall(this.code.Ptr + 3248, "Ptr", ppJson, "Ptr", pResult, "CDecl Int")
		}
		lib.DefineProp("bBoolsAsInts", {
			get: (this) => NumGet(this.code.Ptr + 5328, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5328)
		})
		lib.DefineProp("bEscapeUnicode", {
			get: (this) => NumGet(this.code.Ptr + 5344, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5344)
		})
		lib.DefineProp("bNullsAsStrings", {
			get: (this) => NumGet(this.code.Ptr + 5360, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5360)
		})
		lib.DefineProp("fnCastString", {
			get: (this) => NumGet(this.code.Ptr + 5376, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5376)
		})
		lib.DefineProp("fnGetArray", {
			get: (this) => NumGet(this.code.Ptr + 5392, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5392)
		})
		lib.DefineProp("fnGetMap", {
			get: (this) => NumGet(this.code.Ptr + 5408, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5408)
		})
		lib.DefineProp("objFalse", {
			get: (this) => NumGet(this.code.Ptr + 5424, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5424)
		})
		lib.DefineProp("objNull", {
			get: (this) => NumGet(this.code.Ptr + 5440, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5440)
		})
		lib.DefineProp("objTrue", {
			get: (this) => NumGet(this.code.Ptr + 5456, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5456)
		})
		return lib
	}
	
	static _LoadLib() {
		return A_PtrSize = 4 ? this._LoadLib32Bit() : this._LoadLib64Bit()
	}

    static Stringify(obj) => this.Dump(obj)
    static DumpFile(obj, path, pretty := 0, encoding?)
        => FileOpen(path, "w", encoding?).Write(this.Dump(obj, pretty))

    /**
     * Convert an object to a JSON string
     *
     * @param obj The object to convert
     * @param pretty Whether to pretty-print the JSON string (default: 0)
     *
     * @return The JSON string
     */
    static Dump(obj, pretty := 0)
    {
        variant_buf := Buffer(24, 0)  ; Make a buffer big enough for a VARIANT.
        var := ComValue(0x400C, variant_buf.ptr)  ; Make a reference to a VARIANT.
        var[] := obj

        size := 0
        this.lib.dumps(variant_buf, 0, &size, !!pretty, 0)
        buf := Buffer(size*5 + 2, 0)
        bufbuf := Buffer(A_PtrSize)
        NumPut("Ptr", buf.Ptr, bufbuf)
        this.lib.dumps(variant_buf, bufbuf, &size, !!pretty, 0)

        ; If a VARIANT contains a string or object, it must be explicitly freed
        ; by calling VariantClear or assigning a pure numeric value:
        var[] := 0
        return StrGet(buf, "UTF-16")
    }

    static Parse(json) => this.Load(json)
    static LoadFile(path, options?) => this.Load(FileRead(path, options?))

    /**
     * Parse a JSON string into an object
     *
     * @param json The JSON string to parse
     *
     * @return The parsed object
     */
    static Load(json) {
        ; Prefix with a space to provide room for BSTR prefixes
        _json := " " (json is VarRef ? %json% : json)
        pJson := Buffer(A_PtrSize)
        NumPut("Ptr", StrPtr(_json), pJson)

        pResult := Buffer(24)

        if r := this.lib.loads(pJson, pResult)
        {
            throw Error("Failed to parse JSON (" r ")", -1
            , Format("Unexpected character at position {}: '{}'"
            , (NumGet(pJson, 'UPtr') - StrPtr(_json)) // 2, Chr(NumGet(NumGet(pJson, 'UPtr'), 'Short'))))
        }

        result := ComValue(0x400C, pResult.Ptr)[] ; VT_BYREF | VT_VARIANT
        if IsObject(result)
            ObjRelease(ObjPtr(result))
        return result
    }

    /**
     * Object to act as a stand-in for JSON's "true" as AHK has no native
     * boolean type.
     *
     * @see {@link JSON.BoolsAsInts}
     */
    static True {
        get {
            static _ := {value: true, name: 'true'}
            return _
        }
    }

    /**
     * Object to act as a stand-in for JSON's "false" as AHK has no native
     * boolean type.
     *
     * @see {@link JSON.BoolsAsInts}
     */
    static False {
        get {
            static _ := {value: false, name: 'false'}
            return _
        }
    }

    /**
     * Object to act as a stand-in for JSON's "null" as AHK has no native
     * null type.
     *
     * @see {@link JSON.NullsAsStrings}
     */
    static Null {
        get {
            static _ := {value: '', name: 'null'}
            return _
        }
    }
}

