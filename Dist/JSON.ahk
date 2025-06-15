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
		. "v7gAVYnlV1ZTgewAbAEAAItFFIsAdQiLXQyJhcwQ/v//igIoiIXTAQAUiwZmg/gDdQAci0YIiVwkBACJRcjB+B+JRQDMi0UQiUQkCCCNRcjrFABC"
		. "FHUeGwEiAUIBKgBYBCToAGEWAADpVQYAOgAAQAgKQAGaACCcFwUAIDQDIAUPhbEAAAAAMcCNfcy5AgMACfIPEEYI8wCrjUW4jU2oxxRFuAASAAB+"
		. "oZwTIAAAx0W8AQ6LEACJTCQYjU3IZhUAHwUAFdAAzADHRCwkIAEdAAccAjRMJKoUAAsQBBsMBBsIhAMCBIIRBCTyDxFFAMD/UhgxwIPsACSLVbBm"
		. "ixQCAGaF0g+EkwUAAACF23QMiwuNAHECiTNmiRHrAAWLdRD/BoPAQALr1rpUFYJfCQB0M2YPvgKEwAR0GAQWeQKJO2YEiQEAFkUQ/wBCZOvgi5Dp"
		. "HIArAIS6ImQAIDsFsABrdSQxAyEPhB+NOQcj3LpqaQIYqAoY7gBjFhhvFQIYrAoYvRgMixCNHI3YAH9ARQFPjY3c6QADx4VBAXSAEgFTBE9WDAFV"
		. "wAgIAVK0ABj/EFIUi5XBDoPsGICD+v91KbqIwUctBB0PBx1NR9xAfr3oTQAOuQFkwH19rIKBZjTHhUEFCIEEQgKNvQL4RQmJRagxwPNGqwBRAwXH"
		. "hfBAAQAJgShFsEEmiwiJfAkAiH2ogAEUjb0I4v/ANFQkBE2IUYcBM9nAP/9RAISFJIUBEAIDY4CIAB+NvRgABIUgfTiojY3BA0AswQkIAGjHhRDA"
		. "ARiAIwOqi+sDVYIiKIEiTKsiwaaGIvsBEIoiOIwiwQOAIsEJgSLyMMABwBSLIi5lQBMWECeAFYMQAA5mg+ItA3UQCYO9AAALAHVZ10ACgR9CAiBC"
		. "AlJAAoEQQAN1E4O9QEECx5SF1KAGAqAKdT/qQp73IA71QoMGQRHrCmMBa8EToUVIRiC94gpjH00AmIsQi1IUD4XTQYTCV024wIOaHFdhG9DSi1WY"
		. "8lZX+BMhlt7IxDIiUcESBU/IQSpfTglNTum0ZheIjX240eIURYisAluYxQcpGd+qGKdERKlgGgOpjWETgaXGA0GpoBXHRcDBMQap8WEOi02YNKmh"
		. "DuEJfUPloQwJAih0YJ6iFsshxAYeoBwgBw6LA41QAAKJE2bHACIAoWQHMf/p08OJG+M/AAGLExnAg+DgAI1KAoPAe4kLSGaJAkQFgL0B2gCkurog"
		. "EnVoQUdYRUeYx4XIpEsgJL1oxQKlgQF4iAF9iCYBmCQBRA+2AuSJhcSgAOlWqWACQBEVx6lCIx91COnrjoIQ6+5mg0B9mAMPhR1AKINAfaAAD4QT"
		. "IQG9EQIQD4RGYkwPhBQ7AfLGHSyAF8EMgxcPhQYPoQOiYEiD+AEPVIZOwvcYQShA4CYQ1ovCESABDAUphYEaYSk8CvgAAcIdYwJwIIgMAkDFK4lF"
		. "kI11iASNlZER86WJVYDgjX3YjbUxEEBEYQAIDECJZC6ljX28G3IlQSXIADdUJIlFuNiLhVDRL+QkuK94D0ZHRSSoeIMkiceFoDfHzdEV6uAFQhTp"
		. "7uAAfxZNcxYudBYUEw+EYQDrBZEnJO8C6Uc7fRhID4+wIAK6vaAV6+Ln0wPfi4UhEFOPoAOyEakn6YHBMnICelKPTknPKeIBqX6FYAQYUVoNEx7L"
		. "QQRZBcUAAboyv3SEdSgsM+154IshEgXrTbrIIwMIdaYquZX2Bj0OYA1o3xIl0xIH1BIPvwIPiYXm4KAQMTiF5HGfCQyRAV0BBZAAGw4PdAQtgAEp"
		. "LIsDtBf1ATpQGF39CRAnUATxAEACIABc6U3wADADIJSLcQJAgeUaRcKJBukwwQE9FRgJIALSDAAlUSEI604V4g5UATEBFbQwbVF2iwMtFANwHwNU"
		. "ARYDUkeGKlICCUJQdS6gDHZpP0XAfTNFYB8VGxUxQMk7TRh9umIlihYCc7TwHCBwAxSLM2CNRgKJAzADYgFmhIkGdh3UQevHogAAjWX0ifhbXl8g"
		. "XcOQkJBxur/sKP9//8G6nJEjdQwAi10IZscGFAAUx0ZDrEaCNIsDZgHwDEWkjUr3ZoMg+RcPh/ZgNon4ANP4icGA4QF1EAqLRaQQq4kD6wDWZoP6"
		. "Ww+FtZ2iQ6QFQLIBAYShoNA4H8A7SmGvYF88XzyLRcBojVW0wJjYoBAgPccGRYFtgEKkiwCLfUKkgHEUjVWwbnlUwWh5PCT/UBQAbNINEaQNdxO6"
		. "ERHT+oBQ4gF1GkMN30ANXVgPhL8ho1G7toEEdCEQLBwk6LhBQ8APRIWG0AWNfdyyS40cVdjweoAIYAh12MfMReDyorEHFIsgC+8OPhhvDxhwIH6i"
		. "ChNwPglpQBpGCOUlUgIcGgwQVIn64wsR4wvi4AsshA+EUZqLE4PIsCwgOl0Phd1gwIPCBgJgCtEzBgkA6c1D0BWgAiIPhQAyUaRJEDSDwMA1iVYx"
		. "IQgIAOnVERCD+nsPrIUVcjwAHtgMHqQLHl7Yb1pvWg8eAh590tIDlRAdZtA8SJMnhklSCmD4fQ+EmpEAcVyRYSMBIg+ES5AAEA7pAgDADWaFyXTz"
		. "jQJ6QYGD+VwPhQkhIAdmi0oC0AAidXIhAEP+IgAQ4A3AC4uAE414/maLCrIBCMbp53IO+W50WoR/KnAAYnRKf5DokPkvdDqhBHWdwQMQXADrwdAA"
		. "ZnWPodEADADrs9AAdJDaIIP5dXQ4UAByDwSFcSJuQP4NAOtClXEALwDrjXEACAgA64VxAAoA6Xr7JALwF2+gAAAJYJhCczFNAv4hC1D+izvB4oAE"
		. "iX2kZolQUAoAD4150GaD/wkAdwQB+usgjXkCv8AABXcGjVQKQMnrEY15n+EAD8SH9cF4VAqpQChhAwCDxwL/TZiJOxB1r+kMIQeJSP4s6QMRITCS"
		. "+XAgKcFAiUj8ZscHgQfpEt7wH41CQAb4CQ8CllAO+i0PlMAIgMGITaQPhM5hFA0RQr8iHG1Cgzgtdc62AAiDwAKDz/+JAAOLA2aLAGaDAPgwdRPH"
		. "RggAEQAAx0YMATCDAwIg61iD6DEAbAgPAIdK/v//iwtmAIsBZolFooPoAjAAVAl3OWtGDAAKg8ECiUWUuAIKAGT3ZgiJC4kAVZyJRZiLRZQAAUWc"
		. "D79FopkAA0WYE1Wcg8AA0IPS/4lGCIkQVgzrtQDqgzguBHQTAX0Qg+LfZoCD+kV0RenNAXcQwAK5AQAHiQPfAG4IZscGBQDdgF4IixNmiwIFdgDK"
		. "a8kKg8ICiYATiU2Y20WYAJGAmN59mNxGCAAoFOvVAD+JAF0+FHUOCwlAAWgAZS10CsaERaQA8PordQUCFQMCgAQtD4di/f//RDHAgXQRg+qACfog"
		. "CXcPa8ABcg+/ANKJCwHQ6+MxBMm6gU85yHQGawDSCkHr9oB9pBQA3QBsVYFGdAfeovmBQwXeyQE7FgAhABR1I4n4i04MAJmLRggPr88PQK/CAcGJ"
		. "+ACWAZLKg4fpEQAoMcAAFTAFD4XogAWBJn2kSNpNpAAh6dcACLkIZBUAAVp0dUFmIA++AYTAAJ0TQQBmOwIPhbD8/wL/gobr5YA9kBOpgEx0DoB6"
		. "A4DjCIFThOtKgAYJAKGwAA0k6ZwACLlpgyVmdWpFzRJkzxIVxRKIhusKZIMUqEAI60y5b2HDE24PhSTAD80UEBXJFJjCFA+ADwgAoYS4FEB5Rgjr"
		. "FkMTBqzABoADixCJBCQA/1IEUDHA6dwBQAu67P9//9P6AInRgOEBD4W4kvvAoVWkAhTpgwADAI1FyIkcJIlEACQE6ND4//+FMMAPhZ7BCMF7jUqA"
		. "92aD+Rd3McQQNIDiQBCAQAcCfuvbAIsTg8j/ZoM6GH11dgIUwiGJfgiE64SAMzoPhVWFCpCJdCQEQBnobkQYEjxBGEXQgAUIiTyhAx+PAgAACh0T"
		. "Bx2MdZYDHIG5LHWJAgMI6cb6AC9l9Fte4F9dw5CQQWrFAD8Avz8AHwAfAB8AHwARABBgAABPAHcAbgBQAIByAG8AcABznwajCABBWVAAdaAGaOoC"
		. "ggZgAFMAZQB0aAIAMDEyMzQ1NjcAODlBQkNERUaFomAY4AIZAAD64AAqT+AA3+AAFeAAIlUAbmtub3duX1YAYWx1ZV8AdHIAdWUAZmFsc2UAAG51"
		. "bGwASACqYWAOTSIMaOAWZGAJAWYGT2JqZWN0XxUxG18gAEVgAnUAbYGgAQ0KAAkAIsUFMeYHVHlwQA7qGlWJAOVXVo1VtI19ALxTg+x8i3UIQItd"
		. "EMdFtGEDiwAGiVQkFI1VDKHAAAjHRCRhKgDgACYMAVDgAAS0oXE0JID/UBSLA7kDIQYAUwyD7Bhmx0WI2AgAQK7Ii0MgngDUjVW4iUXQiwBFDIlF"
		. "4DHA8yKrwHHHRcBgYQCJUEW4iwYgCSAkCxzf5ACAJYADgA+hDgSkDmQDHgihDqEPYgShDxiD7IAkZoM7CXUM4A0ZRIMIUOdmYhxTgezKrCEURcC9"
		. "ReYAAaAFAFAEiwCJwYnTBIHBIAOAg9MAgyD7AA+GrQIToI0wfbAxwKIaIRaYiQBVpI1NiIlFrCShnOEPRZgiJBCJAEwkGI1NrMdFpaGmAEALmBSA"
		. "A7QkJP/qGkAF4hlkA+YZ5ADjGWEXCBgxwCAai1WQZgCLFAJmhdIPhAKLQAOF9nQMiw4AjVkCiR5miRGA6wWLfRD/B8CESOvWuWCkALuB64UQwHkr"
		. "vwEBmbswAaEJTYRJ9/8p0wBmiVxNvoXAdQDpi02Eg+kCZgDHRE2+LQDrEACZSff7g8IwZgSJVMID8AHJjUSEDb6B4IXSdBoWDjLeoBUxwMMVsxWD"
		. "7AAMi10Mi30IiwB1EIXbdA6LAwSNULJSACIA6ykQ/wbrJZBzDX4sUVAAInVHEAJOEQIECfABXABhAkACIgCAg8cCZosHZnAIGNPpQTASsAIHD44i"
		. "x2AMjVD4Ym+HugHAAA+30v8klTyB4mT4XHQK6aXxgFAGAuu/YAX3bQVcKADrp3AB330BYgAU649wAcd9AWYA6UR0//Bb23SsrQFuKADpWaMBka0B"
		. "cgDE6T6iAQ+EcnAA7QEQdADpH2ABgD2UIZJtC41Q4PAMXndAEetCjVCBoAAhxHYGwAwfdzPABaA0YdsDdQDrA/ANcmRcICQED7cHQCLoPBmQBOnJ"
		. "AJcgAw+LEwCNSgKJC2aJAoTptiAB/wbpr5MBgYsYAv8Gg8QMdBsQMcCJ5YEbEItVAbAbEItNCInOZkDB6QSD5g/QebYCKAEWiXRF8ECDYPgEdeS4"
		. "cTBAIREAiwqNcQKJMmYii6ABZokxMAUDg4DoAXPkg8QQISEB4TaQ"
		if (32 != A_PtrSize * 8)
			throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if IsSet(lib)
			return lib
		if !DllCall("Crypt32\CryptStringToBinary", "Str", codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(3987), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
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
		. "zsI5vEMIwCqYggWEB4IRwQNBEInY86tJWItPCIGYwQUIQgzYPcQUsMQUhBcCPQA7iUQgJDBNieiPlUyJmHQkKMWWgJSJ2IW88cC0jQVdACQCBAEP"
		. "QbL3BCSCG4Ad8AomwbNBBAco+8EJAygIwbnFvYUhgVilIvZyoDVJERABCkARAgsADP/BBksRIQJHEeEEQBFfEEgQRGaDYzEDdQogAci5QQR1X4EC"
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
		. "6aurAQTBxE0AFgsTFlYLFppzAhYPBhZBhutwRRUStkAH61iAFG4PhUIdAQ6NDboDkhX/CvuKFTzDK0iLBbNbACaAEwgAg8ByFkUWbBEACEiJToBv"
		. "Af9QIAgxwOnUwov6SADT+oDiAQ+FkhPCE0Jx6XbAAkyJ4gBIidnopfj//2CFwA+FkMEDJT8glHcYKAd1Jwfr3KAD0DoPhWJGAvKACAADFOhd5AhI"
		. "4giUJKABoA9JifBIienoJlIAHEcLdiugACwPBIRwgYOLE4PI/8Bmgzp9dSlkHcMZYIluCOk5AQSlEHWC1CUQtUiBxLCACwBbXl9dQVzDkP8FAOEj"
		. "CQD9AR8AHwAfAB8A/x8AHwAfAB8AHwAfAB8ABwACEGAATwB3AG4AAFAAcgBvAHAAjnOfBggAAWtQAHWgBgpo8gMGYABTAGUAAnT0BzAxMjM0NQA2"
		. "Nzg5QUJDRFRFRmECEiBVkmAAUFVgALJgADFgAG9gACIAVW5rbm93bl8AVmFsdWVfAHQAcnVlAGZhbHMAZQBudWxsAEhUAGHgEE2iDWhgGWQDYAlm"
		. "Bk9iamVjdCpfsR1fIABFYAJ1AAJtoAENCgAJACJjxQXmB1R5cEAObh1WIFNIgeyoYXyNNQaQoLAExIsBTInDIEiJlCTIQgNUJBBUTI2EgwGJVCQi"
		. "KAJ2jCTA4AHHRCwkVIEEcAAgcQD/ULwoiwBewwFAW8EDWCE8AwACYgdmiUQkcEhEi0OwYoQkiCIYSLEgAXhIiwQGgAJggnBwiYQkkOIHAQMgAlhP"
		. "YAlRBJBLYwgx0sECQGvCAoAAOIUAMAUJAYP/klAAZTsJcHeLS2NNDBCQwD8xD1tew1eBABCD7DBBuxPwAIS7CrMPSIXAZuADAi6xR9JMjUwkBqB5"
		. "NEG7FMABv6EFIEiZif5E8Er3+wAp1mZDiXRZ/ghJ/8swA3Xmg+kQAkhjwbADRAYtIADrGEiZYwKDwhIwcAIUWWQC6EhjgMlIAclJAckBbwBmhcB0"
		. "HU2F0gB0D0mLEkiNSgACSYkKZokC6wXwiAABcOvaMcBI+IPEMJBKYEriCvAXgAQA0nQRSIsCSI0CSABNCmbHACIAazIDgBx7gBxmoFKQVIRCjkJt"
		. "+A1/I1AAB4gPjhHwAI1I+EJwBIcEwAAPt8lIY4AMjkgB8f/hIAIIInQLUABcdC3pVuehDlAGGlMGBCAGXANwF6AGQAIiAOksgbADQYMAAukjIWOF"
		. "cALyfwICXADpMQYF4QHT7wECYgDp5WVUBrTvAQJms3ThAZVB7wECbgDpp+MBDwyEcnJgLgJyAOmEDSUCTy8CIQJ0AOtkAIA9E/r//wB0EAuNSOCQ"
		. "EV53ESDrOY1IgaAAIXaiBuAQH3cqQQgX7wMgAnUA6wRhEA+3KAvoT0F6F5ECD0iAiwpMjUkCTLEcggFzGYPDAulm0ZzjnxuUG4PEKCAptmgBAAHQ"
		. "HhgxwEyNHZMDwXagKAhJicpmwQLpMAfiD2ZHD74AFBNmRYkUQUiC/0Ai+AR14biARgUSExUgCGZFixRBCEyNWXAIGmZEiUIRZAboAXPdQiUYAMM="
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

