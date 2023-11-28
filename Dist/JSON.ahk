;
; cJson.ahk 2.0.0-git-built
; Copyright (c) 2023 Philip Taylor (known also as GeekDude, G33kDude)
; https://github.com/G33kDude/cJson.ahk
;
; MIT License
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
#Requires AutoHotkey v2.0

class JSON
{
	static version := "2.0.0-git-built"

	static BoolsAsInts {
		get => this.lib.bBoolsAsInts
		set => this.lib.bBoolsAsInts := value
	}

	static NullsAsStrings {
		get => this.lib.bNullsAsStrings
		set => this.lib.bNullsAsStrings := value
	}

	static EscapeUnicode {
		get => this.lib.bEscapeUnicode
		set => this.lib.bEscapeUnicode := value
	}

	static fnCastString := Format.Bind('{}')

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

	
	static _LoadLib32Bit() {
		static lib, code := Buffer(6624), codeB64 := ""
		. "ubgAVYnlV1aNlbAA/v//U4HsnAEAAACLRRSLdQhIx4W0AJD2FAB4XVAMiYWcADCKAhSIBIWjABSLBolUJBgUjZUBkAASCMdE2CQQAAAAAA4MAIYB"
		. "DgAE3BMAAIk0JBD/UBSLAr6D7BgAg/r/dSm6ChUAAABmD74ChMAAD4TzAwAAhdsAdAyLC415AokAO2aJAesFi0UAEP8AQuvcMcBIjb24ADi5BABR"
		. "8yCrjX2cuQAtAGY0x4UBFQgBEgIJjb0CyAUliUWYMcDzIKuLBo2NARONfYCYiUwkGIl8AKuEvdgDqwTHhcAACaIcAITHRaAErCAEXqochAMQhAsM"
		. "hAcIgQMRAmYYMcCCNI2V6EeAIgFBgSuD7CSFP43uvQEMg0IANxiAQYN/g0JO+IAEgGABGggAA0fgzYAFJgFHs0MI/4NDgSw/ikMBDJBDBTOAQgEZ"
		. "CADox4UAQAouQyBCHoEqT1YfwCxDIAAbZoPCXgMgdQmDvdAAAgB1rlmABAFAggTwggRSgASBwSIDdRODvRAAApVAHKRABgJAE3U/ioOe5EAclYMD"
		. "DYEg6wrDAouBJwGJGMAUjVWoxIkQiwaDvYIXi0AUCA+Fr4MsFI1VuBkCqkW4BDrWq9CLVZqo0qpHGCeAIX3IBaoyjQEkiwYFWoGgjU1KyAZXTBdX"
		. "6aeGK4ikjX1ELIhAwqqoxYS7DS7FhNCGhMEfAczMAsyjADMAA0W4ZgA/A4CGMsiAJkXAQV/ChVXIuMdF0PVg4QcwQBRgJI8HQaIko0EhDwl0XUMm"
		. "lHQY1CXg4ACJXMAHQHXIwf4fieAKjQBFyIkEJIl1zAjo5hGiLA6LA40AUAKJE2bHACKCAAQHMf/pHgeiAwIbQzwBixMZwIMA4OCNSgKDwHsgiQtm"
		. "iQJEBYC9kYGVALpOIBN1boFExiggE8Ijx4WY5EigIqy9OMUCgQFIiQFYiQESaIcBD7ZCoImFlFmgAOm5YAIAEhWgHHEoAokzoBxCgx916WTriEIR"
		. "6+7gIuEHA5APhV8FACW9cGFgGA+EUoIBghEPhGGxgksPhC9BsEYfLAAZY4ENAxkPhSqhA2JfSMCD+AEPhmniAWEYKGaD+OAL0qA6i4UGQOABwitF"
		. "uMH4H1iJRbzBLYIsuIAs6OqEIEj/giCNQgcgV2CBQcEdDECJhWDgALglwki1QQKNlQEnicEIiZVQgUqljX3YQ4AFASUMQI214QCJG+ReQAOs4k2B"
		. "TciNjRFBHsdFsOJMRaiL1IUggWIQg2GobU2ZYqFmXAQk/1KhjolAuGgPhKbBLw5gKKIs6TbTwAEVMS4EMYQpD4QVwcbroVMk0AVHO32QGA+PlUAE"
		. "ulGgLsTr56MH34uFQSEBLZR1HEAHESlU6YEAFMXjBHogBBR1SXRYJV+ZwTGFMMEnIDLyDoM/lsKBCKkKvAACulNhkOCD+Al1KMxqBBfIaiEiCutN"
		. "ulxDBgh1TiroDaMD4Q3eD8AaX+W1JQfUEg+/Ag9aJKULXZMkOnILfA7kAy2AASksiwMkF/UBOsAXS/0JYCVQBPEAQAIgAAzpO/AAMAOLdRCLBXEC"
		. "QFUaRcKJBuk2HsABAhUWmhMhLukvYbMBCQ+FxYETQgG6ImugDzsF2MBcdSSdlVsOgAI/E5NbunACA7LQCgPd/A8DBgN2AgMa1AoDrA8DBgOLdRgB"
		. "ggsEJI1WAYu1g2FDsFMQiXQkDDAPoWAACOh19uAMaDAEXUIbHkob0jzAFinAFukSRDACunvTHQUPhRLGE3B9vII38g8QQ9ICATiIjY14AjiIIaIz"
		. "RbihxAALx0VOjOEAZTghYYgFUAHAD/9fPzk/OTI58g8RRRKQgDkxwKA5i1WAAGaLFAJmhdIPKISY+zwRETARdRCA/waDwALr1t8nZ9sn7h4xEMkL"
		. "AierNzDbcAYzQCaRAFU6CfAkEi/j0A6RQwjrFdIVVAExAfQV3ACuUQZUEgOhBh8DOwQIEwNSxkxSArlmUHVKLvAJdu9pwH3jaWADfw97DzHJO00Y"
		. "fbK6okeKAuO2MD8gcAMAFIszjUYCiQMjMANiAWaJBlYm1EEE68eiAI1l9In4IFteX13Dsb2/EzAAgABWob1hH3UMAItdCGbHBhQAFMdGYxxGUh2L"
		. "A2YBwAxFpI1K92aDIPkXD4f2MB+J+ADT6InBgOEBdBAKi0WkMBuJA+sA1maD+lsPhbWdcsKkJY+yAZGmocgwJntgJfUlyCQkb60vJWxei6BFwI1V"
		. "tPBjjLOFCMdFtIMspIsAi3R9pDOSsO2QtMhzBDyPscfAj9INpA13E7oREYDT6oDiAXQaQw3C30ANXQ+EvzGxcSuKtsEDdKAnHCTogWKJwGaFhtAF"
		. "jX3cYjY4jVXYUKaACGAIddiox0XgkQeLZJG07w48JBhvD/y0oQrztD4JaUAaRgi1JVICHBoMEFSJ+uMLEeML4uALLEQPhJIuE4PIgCw6kF0PhdDB"
		. "hcICYArBYTIGCQDpwFARoALYIg+F0R3hG1BgKWBYhIlWMSEIAOnVERDAg/p7D4UVMd4BHurYDB7MCx7YP0M/Qw8eVQIeffJCAxAdZnBfSAmTJ4Y8"
		. "Ugr4fQ+EFo2RAIF+hCMBIg+EJj6QABAO6fOiAcl0CPONepGlg/lcD0KFEZ1mi0oC0AAi5HUhoGX+IgAQ4A3ACwCLE414/maLChGyAcbp3XIO+Vx1"
		. "gXAPQP5cAOvX0ABCL9MALwDrydAAYqHTAAgA67vQAGbTAFAMAOut0ABu0wAKKADrn9AActMADQAU65HQAHTTAAkA68KD0AB1D4VNYBlgCFjHRZhy"
		. "2TFv/oEKUAD+izvB4gSJfRCkZolQsAkPjXkA0GaD/wl3BAFA+usgjXm/wAAFAHcGjVQKyesRBI15kAb/BQ+H/zFBm1QKqaAnYQODxwAC/02YiTt1"
		. "rwTpFiFMiUj+6Q0hcSBGCIn50B8pwSCJSPxmxzCziRNk6duQmI1CQAYAc5YCwXAeLQ+UwLS2AAjBiE2kD4TLAAEAAGbHBhQAwr8AQADHRggAKAAw"
		. "AgwBMIsDZoM4LQB1CIPAAoPP/wSJAwA8iwBmg/gIMHUTC6CDAwLrEFiD6DEANggPhwBU/v//iwtmiwABZolFooPoMAEAKgl3OWtGDAoAg8ECiUWU"
		. "uAoBAGT3ZgiJC4lVAJyJRZiLRZQBAEWcD79FopkDAEWYE1Wcg8DQAIPS/4lGCIlWiAzrtQKFLnQTAX0AEIPi32aD+kUQdEXpygF3wAK5QQG2iQPf"
		. "bggAxQUAAN1eCIsTZosCAgV2ymvJCoPCAAKJE4lNmNtFApgAkZjefZjcRlIIACjr1YAfiYAuPjgUdQsJIAE0gDItdBAKxkWkAHj6K3UOBQIVAoAE"
		. "LQ+HbP0Q//8xwIF0EYPqgYAJ+gl3D2vAAXIAD7/SiQsB0OsQ4zHJuoFPOch0AAZr0gpB6/aAUH2kAN0AbFWBRnSABN756wLeyYE5AhaAHxR1I4n4"
		. "iwBODJmLRggPrwDPD6/CAcGJ+EmAlAHKA4bpEYAmMcLAABUFD4XogAUBJSB9pNpNpAAh6dcRAAi5axWA54P6dAB1QWYPvgGEwAGAmxNBZjsCD4UQ"
		. "vfz//wKF6+WASD24EwBLdA6APAMTAX0BKetKQAMJAKGS2IAG6ZwABLlwwxKoZnVFzRJxzxIVxRIpyIXrZIMU0EAI60yEuXbDE24PhTHAD1XNFB3J"
		. "FMDCFA+ADwgQAKHgFIB4RgjrGhZDE9TABoADixCJAAQk/1IEUDHABOncQAu6EwCAAADT6onRgOEBD0iExfsAoVWkAhTpApAAA41FyIkcJACJRCQE"
		. "6N34/8D/hcAPhavBCAF7AI1K92aD+Rd30jHEEIDiQBCNQAdCfQDr24sTg8j/ZmCDOn11dgIUwiGJEH4I64SAMzoPhUJihQqJdCQEQBnoSntEGElB"
		. "GEXQgAUIZIk8Ax8cAgLWBx0TGQcddJYDHMG4LHWJEQID6dP6AC9l9FuAXl9dw5CQkIFq/8UAPwAfAB8AHwAfAB8AHwABDwAwMTIzNDU2ADc4OUFC"
		. "Q0RFAEYAAEgAYQBzAABNAGUAdABoEABvAGSgBCJVbgBrbm93bl9PYgBqZWN0XwAAUFQAdaAEaGADUyIFAEAATwB3AG7gAnJFYAZwYAMAAF8gAEUR"
		. "YAJ1AG2gAQ0KABgJACIFCCYKVHlwAGVfAHRydWUAAGZhbHNlAG51hGxsxwNWYWx14AMB6A0AAFWJ5VdWAI1VtI19vFODAOx8i3UIi10QCMdFtAKy"
		. "BolUJBAUjVUMwAAIx0TEJBBibUQkDGK3oEsB4QGJNCT/UBSLCAO5AyEGUwyD7IAYZsdF2AgAgJ8IyItDYI/UjVW4AIlF0ItFDIlFIOAxwPOrYGPH"
		. "RQLAAFMAiUW4iwbVIAkgJAsc5AAYIguADz+hDsEMoQ5kAyN+qQ8YgwDsJGaDOwl1DDPgDeR0CFCHWGIcU4GU7KwhFEUAr0XmAAEBoAVQBIsAicGJ"
		. "CNOBwSADgIPTAECD+wAPhq0CE6BgjX2wMcCiGiEWmACJVaSNTYiJRYisocQAgsdFmCIkABCJTCQYjU2sjMdFQZhA20WYFIAD/rQkJOoaQAXiGWQD"
		. "8xlhFwgYMcAgGotVkGYAixQCZoXSD4QCi0ADhfZ0DIsOAI1ZAokeZokRgOsFi30Q/wdgdkjr1rkAlgC7wdyFEMB5K78BAZm7MAGhCU2ESff/KdMA"
		. "ZolcTb6FwHUA6YtNhIPpAmYAx0RNvi0A6xAAmUn3+4PCMGYEiVTCA/AByY1EhA2+wdGF0nQaFg4y3kArMcCDK2Mrg+wADItdDIt9CIsAdRCF23QO"
		. "iwMEjVAClwAiAOsjEP8G6x9g2CJ1K5WwASKxAQSQAVwAAQIAQAIiAIPHAmaIiwdmEAjZ6TrQESCDBgLr6wADXHUKGAAD8Q0DXADrzQuhf9IB090B"
		. "YgDrrx3QAQzSAdB82wFmAOuikdABCnUb0AGX3QEgbgDpcP+gYoP4AA11H4XbD4RyQ9AATQJyAOlLQwIJBUMCTU8CAnQA6SYRYAGAPbySZQuNUALg"
		. "QFZedxHrQo1EUIGgACF2BhAEHxx3M3AI0DPbA3UA6wYDQBByXFwkBA+3kgdwIeg9kATp0NCOASADD4sTjUoCiUALZokC6b0gAf8YBum2kwG7FwL/"
		. "BgiDxAx1MDHAieURwRoQi1XwGhCLTQAIic5mwekEgyTmD+BxtuRwJGaJAHRF8ECD+AR1DOS4sS+AIBGLCo1AcQKJMmaLoAFmBIkxQAUDg+gBczDk"
		. "g8QQYSByYg=="
		if (32 != A_PtrSize * 8)
			throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if IsSet(lib)
			return lib
		if !DllCall("Crypt32\CryptStringToBinary", "Str", codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(3955), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
			throw Error("Failed to convert MCL b64 to binary")
		if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", code, "UInt", 6624, "Ptr", buf, "UInt", buf.Size, "UInt*", &DecompressedSize := 0, "UInt"))
			throw Error("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
		for import, offset in Map(['OleAut32', 'SysFreeString'], 5340) {
			if !(hDll := DllCall("GetModuleHandle", "Str", import[1], "Ptr"))
				throw Error("Could not load dll " import[1] ": " OsError().Message)
			if !(pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", import[2], "Ptr"))
				throw Error("Could not find function " import[2] " from " import[1] ".dll: " OsError().Message)
			NumPut("Ptr", pFunction, code, offset)
		}
		for offset in [30, 91, 116, 249, 392, 522, 643, 755, 779, 800, 933, 1094, 1248, 1449, 1823, 1956, 2007, 2258, 2264, 2307, 2313, 2356, 2362, 2485, 2539, 2815, 2865, 2892, 2970, 3151, 3234, 3632, 4567, 4606, 4633, 4643, 4682, 4716, 4723, 4766, 4779, 4794, 5835, 6392, 6564]
			NumPut("Ptr", NumGet(code, offset, "Ptr") + code.Ptr, code, offset)
		if !DllCall("VirtualProtect", "Ptr", code, "Ptr", code.Size, "UInt", 0x40, "UInt*", &old := 0, "UInt")
			throw Error("Failed to mark MCL memory as executable")
		lib := {
			code: code,
		dumps: (this, pObjIn, ppszString, pcchString, bPretty, iLevel) =>
			DllCall(this.code.Ptr + 0, "Ptr", pObjIn, "Ptr", ppszString, "IntP", pcchString, "Int", bPretty, "Int", iLevel, "CDecl Ptr"),
		loads: (this, ppJson, pResult) =>
			DllCall(this.code.Ptr + 3036, "Ptr", ppJson, "Ptr", pResult, "CDecl Int")
		}
		lib.DefineProp("bBoolsAsInts", {
			get: (this) => NumGet(this.code.Ptr + 5048, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5048)
		})
		lib.DefineProp("bEscapeUnicode", {
			get: (this) => NumGet(this.code.Ptr + 5052, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5052)
		})
		lib.DefineProp("bNullsAsStrings", {
			get: (this) => NumGet(this.code.Ptr + 5056, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5056)
		})
		lib.DefineProp("fnCastString", {
			get: (this) => NumGet(this.code.Ptr + 5060, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5060)
		})
		lib.DefineProp("fnGetArray", {
			get: (this) => NumGet(this.code.Ptr + 5064, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5064)
		})
		lib.DefineProp("fnGetMap", {
			get: (this) => NumGet(this.code.Ptr + 5068, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5068)
		})
		lib.DefineProp("objFalse", {
			get: (this) => NumGet(this.code.Ptr + 5072, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5072)
		})
		lib.DefineProp("objNull", {
			get: (this) => NumGet(this.code.Ptr + 5076, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5076)
		})
		lib.DefineProp("objTrue", {
			get: (this) => NumGet(this.code.Ptr + 5080, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5080)
		})
		return lib
	}
	
	
	static _LoadLib64Bit() {
		static lib, code := Buffer(6960), codeB64 := ""
		. "a7gAQVdBVkFVQVQAVVdWU0iB7GgAAgAASI0FiBYBADCJ00SJTCRcQEiJzUSKbAEchAgkkAAAXIsBTIlAxkiNlCSMATSJQFQkKEG5AQEUjYAVHhUA"
		. "AEyNA04Qx0QkIAAMAP9QBCiLA1aD+v91LgUASj4AumYPvgKEIMAPhGIEADiF2wB0D0iLC0yNQQACTIkDZokB6wAC/wZI/8Lr2SBFMeS5BgA6RTEA"
		. "yUUxwESJ4EgQjbwkmAAQTI20hCSwAXTHhCTAAWbZAADzqwIrAL/uAIcBKaLIAqGEJKACFoQCOQcBDwE5AEzzq0iLRbUADIwCFGYAJQEQCAARQEwk"
		. "MEiJ6QEh4L0EMrgEMoQ3AngAcUCBCQUBBDgBBEyJdCQo4wF8AQ//UDCAMQVfgDVYjQVggEsECMCBQ+j3hEsCMgA2+ItPAbIBCYRTuwBIgLYwBjsE"
		. "qwEcEAA474FfASSAX6RHhIIbCSSCVA3AEyjABQALTI0dtQ4UyR8AJIEGTImcJP4YwAHCI4QhgR+BE4Mf20UlwBVdwBVmg4NoA3XKCkAC0EEKdV4B"
		. "BQE9MwMFAlp1TgEFAR4DdUoQQAIwAQVBvMCqAKR1OQCU7RMHlBFBsOEalOsGQbwBEEA8QDpCQEVAQYP8AgM6TFuEBcGYGIATQbQAgRWLEEAoD4WB"
		. "SEyJREQkKMBDTYnwgB8o3hJERMAIg8LGvtAAR4EOdYW+Q0gqZwFQVyqDJzDvAA8DvwIpQW2MAgVCZBBaSnxBrkxHW+nFgnQ9Vv8AKYFv6IJt6YTs"
		. "iZNAWCEcifcCeTHSgDi/IQQiXYYYhA+jRiJmlGMQ3aAFQKEwxD8BIANBSWABLiBgAUEDYQQ4ZARMib604gbEBnVoQBhhDwPFi89gKKQWQEeAKP4R"
		. "Q0dhNEgJdFvjKXQbdyndBYUmSeA1idpIiawZogHoT6AxoAYPhLACBwEqA0iNUAJIAIkTZscAIgDpFp5hAkAKGwBDAUiLIBMZwIPgIHJKAgCDwHtI"
		. "iQtmiUICwQuAfCRcIZ+uUWASD4WpxkpYYBMxYO1FD7b1QidBSrhjQALhN7wkcGVOwwGIXcsBoMsBwQbGAYQCC0jdwE9wgQEBCYEBeIEBIjIVgAFg"
		. "gQHQJANo6bc7wSjgGB1KI8Ai4yZ144jpSv8AAAbr7GEqFaENAwAZBWBWvCTAEUE0D4SboAGF7Q/EhIQjVg+EUQEB6SUSLGEgqhBgRITtDwSFTsAD"
		. "QY1EJP9Ag/gBD4aSoAGLUWMVZoP4gAsBIDtI8GOEJHihCCAzwUaBjxPhACM06LXAKf/FSEKLQRuLfCRoQ2BI0IuMJEgBK9KhTeEk9AxAAQeowhGg"
		. "l6SgASrgDEAPKIxiBCEEwU11oQlwwVHgBFwi2kQHmJHgAA8QlEIHDylEbNXgA1gEB2ABB9gIBwIs3IsBxAkiXQBXKPhZYikwEZQkSIAFAFmJxwKF"
		. "gICI/v//SJiE6TMgLP8G6behAaVgNRp1NesuADXvgSykhJtgBesfoQUwtQUY/8c7wKrADQ+PbQEhC40VCg8AAOs64GAI2WAeQUkhMnUlXVEEEQww"
		. "wjNQGmBQAumC1hE+g/gUdUivAm+kAoAcoQIEHPSABqIizUsig6s1wtOCfw5CBQk8dS0vPC88AAvxBetOxZADTpMDCHUqISFoB7ItICjrYS8UKRQE"
		. "IRR4SA+/tDQEKKVBYyjo7jTzC68O0QMvkQGgB5gBIjqSL4QU/WEWUASBQgFAAiAA6QIQASSLBnAC/8ARAkXCgIkG6e78///SFGYN0QdhMOkEYAKx"
		. "EA8GhQMTYwFIOw27C6myEmsNsG4npWPhAARXvxKmY2ADZGMDOWoDqqtvA2wDPWMDCGoDc28DR2kDgBkxJkWJ8TMU/wLAcEcg6KL1///E6TiTDgh1"
		. "GCUNhBoShBAc6RqBBY0Vn8IM0hwFD4Xx9lMRNXF4b/IPEPVCxGCANyjjZGVBaQ1DCqOUgQMxQD1xAAVmReECEWmSOYsB/3OUoASjR5VvAQVPabVw"
		. "kQHA8g8RhCQIAzzxSAiUJPBBNIsUAmZAhdIPhEn7nxKJghGSEoPAAuvPjym3jykUIXQSrLARUQMUPTRk3vpBW+nXYACnPAkMdRAFMVAO/1AQ64oU"
		. "0hcOVQH/FXtwEh/XWAQDkhUOA1EB/xVKL4EVhFczAjVvupABdTXV0QlzP3J9NHJaPw85DzYjMg8gAiwvAkxMfZUlMAdJMAfr5EAD3f8SBgAYgcQR"
		. "y1teXwBdQVxBXUFeQThfw5AKAJbNYZtJuIQAJhMeZscCFIAfAMtIidZIx0IIAWMhE2aLCmaD+RAgD4f7Mq7ASNMA6KgBdAlIg8IJcRfr3cABWw+F"
		. "u78RaEAqYGnzxuABIijQEYMsiRNgK6ElgFO1vRMEAIAoJ1QkaEjBxOUJNCdMjaQzyQ8nWceySIsgghJTVFDYjVgFgQl0fjOcTIB2YKhIiwcQA1zD"
		. "afkVLSMX2NAjZosIwQ13FABIiepI0+qA4kWSDcCQDQPr4JABXQgPhLyREYXJD4QCs3IE8kiJ2ei7U4BjgGqFk+IfBzM5TNSJZPGvtMILi2EJQAf9"
		. "ADSoRNKxADHXBNNhAX81BYUAMPwOZoM+CXWgHkiLTggkKRIXCyYdFAv3DHbiUAAsD0yEMeAwIByDyPBGOjBdD4XyEHWEG2bHhAYJ4Ax+COkCQAEh"
		. "4AIiD4UXgu5CAoMgAsBaA0iJRghgAhAIAOnkkm75ew/chQ6QD38ecB74oQV9HnK/fx7B538efx54Hqxjcx62DQ+GWODxkAB9WA+E7ZEAsRnkIwEi"
		. "mA+EVpAA8A7pB1ENgIXJdPNMjUDyM0CD+VwPhQ2CSUgCArECdSZmx0L+GiIgDMDSDnERiwNMAI1C/hu3AGaLCGaD+SJ1QL/p5gAAAACgXAB1CGbH"
		. "Qv5cABTr0gBoLwNoLwDrCsQANGIDNAgA67aFADRmAzQMAOuoABpCbgMaCgDrmgAaciEDGg0A64wAGnR1AgsBGgkA6Xv//0L/ACB1D4VDABJIQIPA"
		. "BEG5BAB4SAyJAwEhAIGLQv5MAIsDweAEZolCAP5mQYsIRI1RANBmQYP6CXcFoEQB0OskAA+/AQ8ABXcGjUQIyesKEwAQnwIQD4fu/gT//wAUqUmD"
		. "wAIBAT9MiQNB/8l1CKrpCgF3iUr+6QIBAXaLVghMicEBAH0CSCnRiUr8CGZBx4NB6eECAAAAjUHQZoP4CRBBD5bAAFUtD5QAwEEIwA+EuAFBgE7H"
		. "BhQAugAEABBIx0YIAAMASIuAA2aDOC11C4ImWIPK/4AigQmLgKX4CDB1DoYTgwMC6xA2g+gxAAsID4cCRQBUSIsLSA+/EAFEjUiBb/kJdwAXTGtO"
		. "CApIg4DBAkiJC0mNgHZASIlGCOvXgzEuhHQUAiwIg+HfgEsgRXRW6fACLMACBEG5AkmJA/JIDwQqRoC8BgUA8g8IEUYIADFmiwGDBOgwAWh3wEVr"
		. "yYQKmIEv8g8qwIAxAPJBDyrJ8g9eQMHyD1hGCEIM6wbMAjKAY4M+FHUQhw8UQSCBRXQJRTHBR5grdQdEDMAGMckAPgGEGw+HYP3//0xVQCBBhyAP"
		. "QCBJACCYAEyJCwHB6+FFBDHJwVUARDnJdAAIa8AKQf/B6wLzQCfI8g8QRgggRYTAdAbBJ+sEmPIPWUApQCCLDgAdAhQAVg+vVghIiTBWCOktABCC"
		. "IgUPbIX8wAKAD8KACwQ06QbpwW3BoFNIjQ0kIQCbZg++AQAWGEgAixNI/8FmOwJQD4W2/AGjwkAxEyDr4IA9xoEkdBJNgD0DAnqBA+nGwcfHJAYJ"
		. "gHwNJoCJ6auRA8xmdU0AFtADEhZqXQsWbQIWDwYWQYbrSnBFFbBAB+tYwdIPRIUkAQ6NDX+TFQaFixU2wytIiwWtACatgBMIAIPAchZFFmYACAhI"
		. "iU6AbwH/UAgQMcDp1MKL+kjTAOqA4gEPhJn7E4JxoTjpfWABTIniAEiJ2ei/+P//YIXAD4WXwQMlPyCUdxgoB3wnB+vcoAPQOg+FaUYC8oAIAAMU"
		. "6HfkCE/iCJQkoAGgD0mJ8EiJ6egmzAAWRwt2K6AALA9EhHCidBODyICFOhh9dSlkHcMZiW4ITOk5AQSlEHTUJRC1EEiBxLCAC1teX4BdQVzDkJCQ"
		. "ISP/CQD9AR8AHwAfAB8AHwAfAD8fAB8AHwAfAB8ABwAwMQAyMzQ1Njc4OUBBQkNERUagQwAAYQBzAE0AZQCAdABoAG8AZKAEACJVbmtub3duAF9P"
		. "YmplY3RfoAAAUAB1oARoYAMCUyIFAABPAHcAKm7gAnJgBnBgAwAAil8gAEVgAnUAbaABwA0KAAkAIgUIJgoAVHlwZV8AdHIAdWUAZmFsc2UgAG51"
		. "bGzHA1ZhHGx14APoDQsAU0iBBuzBW0SyiwFMicMgSImUJLihAY1UICRUTI2EgwGJVAAkKDHSSImMJGEhVsdEJFThB+AAIOHhAP9QKIsgqoMDoKQ1"
		. "YQdYIK5IAASiDmaJQEQkcEiLQ4CzhAwkiAACYX5EJHhIFovkCwAFYCLPiYQk7pCiDwEGQARYoBKhCCBvW6YQ8ABAwgKAADiFADCTBQkRev9QEFw7"
		. "CYBuZItLc0QQkNA2sQ5bA4E2BABXVlNIg+yQMEG7E4ABuwozEFBIhcBmcAQuUT/SAEyNTCQGeTRBFLsUwAG/MQZImYkE/kSQQvf7KdZmAEOJdFn+"
		. "Sf/LATADdeaD6QJIYwLBsANEBi0A6xhESJljAoPCMHACFAJZZALoSGPJSAEIyUwB0GcBZoXAAHQdTYXSdA9JAIsSTI1KAk2JYApmiQLrgICwcsGI"
		. "AuvbQBSDxDAgQiNhC9EKIEiJcATSdIARSIsCSI1IkEQACmbHACIA6ymJMAPrJIBrInUxAQJqJgMCBNABXKATUAJAxAIiUAXDAmYgTJAICNTpUmAf"
		. "QYMAAkTr6WADXHUcYQPvtW8DAvCVx6GAEwLNHwKgAmIA66UQAgwTAoKrHwICZgDrgxACKAp1HxECiR8CAm4IAOleEpf4DXUjMUACD4RgklWOAnIA"
		. "1Ok1gwIJhAI3jwKBAhB0AOkMkAGAPbIA+v//AHQLjUgC4CBbXncR6zyNREiBoAAhdgZQBB8Udy0xCRcfBAJ1AATrBBESD7cL6E4dgXW8sZDAAvBr"
		. "CkyNiEkCTAEbAemlYAE58BfpneQB3hkTHcQgBeknkOAcGDHATI0MHbNhbKAmCEmJyghmwekgB+IPZkcAD74UE2ZFiRQIQUj/UCD4BHXhKrgQdgDx"
		. "BRXgB2ZFQIsUQUyNWTAIGhBmRIkRNAboAXMC3VIjGMM="
		if (64 != A_PtrSize * 8)
			throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if IsSet(lib)
			return lib
		if !DllCall("Crypt32\CryptStringToBinary", "Str", codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(3980), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
			throw Error("Failed to convert MCL b64 to binary")
		if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", code, "UInt", 6960, "Ptr", buf, "UInt", buf.Size, "UInt*", &DecompressedSize := 0, "UInt"))
			throw Error("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
		for import, offset in Map(['OleAut32', 'SysFreeString'], 5744) {
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
			DllCall(this.code.Ptr + 3296, "Ptr", ppJson, "Ptr", pResult, "CDecl Int")
		}
		lib.DefineProp("bBoolsAsInts", {
			get: (this) => NumGet(this.code.Ptr + 5344, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5344)
		})
		lib.DefineProp("bEscapeUnicode", {
			get: (this) => NumGet(this.code.Ptr + 5360, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5360)
		})
		lib.DefineProp("bNullsAsStrings", {
			get: (this) => NumGet(this.code.Ptr + 5376, "Int"),
			set: (this, value) => NumPut("Int", value, this.code.Ptr + 5376)
		})
		lib.DefineProp("fnCastString", {
			get: (this) => NumGet(this.code.Ptr + 5392, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5392)
		})
		lib.DefineProp("fnGetArray", {
			get: (this) => NumGet(this.code.Ptr + 5408, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5408)
		})
		lib.DefineProp("fnGetMap", {
			get: (this) => NumGet(this.code.Ptr + 5424, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5424)
		})
		lib.DefineProp("objFalse", {
			get: (this) => NumGet(this.code.Ptr + 5440, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5440)
		})
		lib.DefineProp("objNull", {
			get: (this) => NumGet(this.code.Ptr + 5456, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5456)
		})
		lib.DefineProp("objTrue", {
			get: (this) => NumGet(this.code.Ptr + 5472, "Ptr"),
			set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 5472)
		})
		return lib
	}
	
	static _LoadLib() {
		return A_PtrSize = 4 ? this._LoadLib32Bit() : this._LoadLib64Bit()
	}

	static Dump(obj, pretty := 0)
	{
		if !IsObject(obj)
			throw Error("Input must be object")
		size := 0
		this.lib.dumps(ObjPtr(obj), 0, &size, !!pretty, 0)
		buf := Buffer(size*5 + 2, 0)
		bufbuf := Buffer(A_PtrSize)
		NumPut("Ptr", buf.Ptr, bufbuf)
		this.lib.dumps(ObjPtr(obj), bufbuf, &size, !!pretty, 0)
		return StrGet(buf, "UTF-16")
	}

	static Load(json) {
		_json := " " json ; Prefix with a space to provide room for BSTR prefixes
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

	static True {
		get {
			static _ := {value: true, name: 'true'}
			return _
		}
	}

	static False {
		get {
			static _ := {value: false, name: 'false'}
			return _
		}
	}

	static Null {
		get {
			static _ := {value: '', name: 'null'}
			return _
		}
	}
}

