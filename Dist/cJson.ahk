;
; cJson.ahk 0.3.1-git-built
; Copyright (c) 2021 Philip Taylor (known also as GeekDude, G33kDude)
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

class cJson
{
	static version := "0.3.1-git-built"

	BoolsAsInts[]
	{
		get
		{
			this._init()
			return NumGet(this.lib.bBoolsAsInts, "Int")
		}

		set
		{
			this._init()
			NumPut(value, this.lib.bBoolsAsInts, "Int")
			return value
		}
	}

	_init()
	{
		if (this.lib)
			return
		this.lib := this._LoadLib()

		; Populate globals
		NumPut(&this.True, this.lib.objTrue, "UPtr")
		NumPut(&this.False, this.lib.objFalse, "UPtr")
		NumPut(&this.Null, this.lib.objNull, "UPtr")

		this.fnGetObj := Func("Object")
		NumPut(&this.fnGetObj, this.lib.fnGetObj, "UPtr")

		this.fnCastString := Func("Format").Bind("{}")
		NumPut(&this.fnCastString, this.lib.fnCastString, "UPtr")
	}

	_LoadLib32Bit() {
		static CodeBase64 := ""
		. "TrYCAAAAVYnlU4PsAHSLRQiLEKHQABQAAIsAOcIPRISkANDHRfQBhOsAOIN9DAB0IYsQRfQF2ACAD7YYAItFDIsAjUgCAItVDIkKZg++ANNmiRDr"
		. "DYtFEhAAKlABAA6JEIMMRfQAEAViAITAdQK5AMaZiUXAiVVixAFCRCQIAIwABgQCjQATBCToIhoACgACaRQLXscAIgAFDFy4AZfpsAUAAFDGRfMA"
		. "AbtQAJMIgItAEDnCdUcAE1ABx0XsArspAhwMAItF7MHgBAHQEIlFzIsAAkAIiwBV7IPCATnQDwCUwIhF84NF7IABgH3zAHQLhCJQRex8xoJFJAIL"
		. "B8S7WwEmBbt7AAOLTkSJGIxNx0Xogk7HFgQBFQM+6AQ+yIN90OgAfk6TciyNchMTEiANEw+2AGDwAYQgwA+EnwGDOUAYIDlF6H18pKaLRYbIQESA"
		. "ZriJVbyNZlK4gWaHGIRmFw8T6WbcwkTIE+nKQgSAIRxRgCEPjZ/CkuTLkuT0BenokuQAAkUMxJLELFCwiVW0zSywwSzTSheYkyvKF+scgxOLMFUQ"
		. "iVTAEcAJVCTSBAERghkVETp0a0IawAyD+AF1HoECThxiHIAt6YcCAVADCgaoD4VJgnXIAOjUQEAhgLhVx0Xgi1PgBTryqFPgAAJFDMIp6RVxJA4Q"
		. "ocxGDAE7SAzc7AX3XwxGDNwAASUGQwwusqYYwYxDDNhLDNgFdv1fDEYM2AABJQZDDE8FRAwA7yoU+///6UYv5APhKgV1IFQFjUVBMARIBQJ1aUAB"
		. "jRRVoCUEC2AOx0XUBYIXN4IXIItVqIuARdQBwI0cAooXSA+3E3EX1AEFBgEA0A+3AGaFwHUot+mQAmXQayLQBewCFX8i5QrQAAElBgZl3S4ct+AX"
		. "n4NECugAAYOisOgPjCrAKAqjXQOjBn0fo4K2i138ycODAQFkz1dWU4HsI4iKDMAPFOEAx0AIoQPYx0AMIiGgCAihCOAqDgjhZ4ABISaD+CB0IuWo"
		. "AQp016gBDXQiyagBCXS7qAF7D4yFcsJdyArHRaBiDlZFAd/AAKjDAKzBAKFMfAbB4qCqixVBAceIRCQgwgNEJBzhAACNTZCJTCQYjdRNoMAAFKAC"
		. "EGBHoQMf4hfgAMMZQJPhAIkUJAD/0IPsJItFmA+gl78bvxurG30PhFQrxMAiAoXgwkMJAoP4ICJ0Crj/AADpv3EQCo1FgFFT4QeQIWmA/v//hcB0"
		. "F/MBfp/wAf8J/wn/Cf8J1QA6ncUHQs8F8luUCN/9kgjVxAIVwgKIMywIYwJiXn5cgAFPFE8KTwpPCtcALKR1EioF6VRwEZBZFlmFCXwLXwyALAnS"
		. "MFXQsIlQCMOKVHUC8wMwWw+F8EUZNiiFcFMQBbIihXSWAHiWAHxnlAD/KPwojWCQAiIpjU8RBV8pXylWKYVoEQNF/rQAe/ECrxWvFa8VrxXXALBd"
		. "D4S29IH2KaUDQM3YH+FwRtcfFwr1AUB+6uRjArRhArZQFS8KLwo3LwovCtkfFioF8YfpAcuACBkgXcUJegkfIBcgGrQWIFJ1AkQ4D4VjggPvNYsA"
		. "iUXgkgOG4JADowQIAOnvBUsbxGK0B/5AHDgFXA+FLqqdTSkHIW/ggAGJVXbgsl47Los5BsAE2wJcVdwCXdsCL9sCL9wCL1XbAmLbAgjcAgHbAmZV"
		. "2wIM3ALT201u2wIKVdwCpdsCctsCDdwCd33bAnTbAjEe2QKDmtYCdfgPhRFNPuADgAOxZeKVnulxnDABAAMwwonC4QEROhsvfjDYADl/IgfDApEC"
		. "UwEB0IPoMAmFA+mAqTWD+EB+Ii3YAEZ/H98Dg+hSN9UD60XIAmCqA2bbrwOhA1emAwQpbaFJuzMA3AGDfdwDD47GFvABoKcC6yb0X6QCWBCNSqIC"
		. "wC7g0IOJGk1gBhJLELAy//z/Sv9hMUhhAinIcQcMcSC7g+gENxWKB0M33TMw4ogELXRwd7cVD47GsSU49BUPj58QAYCpz8FPP4k0iRkFdRTQAgEN"
		. "Y183EwIwdSMPBGojjhErBTB+dSofZ+tHA8EOgORACGvaCmsgyAAB2bsQUQD3AOMB0YnKi00IAIsJjXECi10IAIkzD7cxD7/OAInLwfsfAcgRANqD"
		. "wNCD0v+LgE0MiUEIiVGQ6AF4JRqLTLcARQiLAA+3AGYAg/g5fp3rCrgC/wAA6asEAACQAosH0C4PhaUAACIAAkSNUAIAHIkQAItFDItQDItAIAhm"
		. "D27AAAbKZgAPYsFmD9aFUBkAgt+tAQoARN1YCAEACmbHAAUAx0UE1AEAiOtCi1XUAInQweACAdABEMCJRdQDVUgCixBVCIkKAG+Yg+hQMImFTAA/"
		. "2wMFRQjU3vkBSkAI3sEjBVIGmi9+DggNOX4ioggNZXQSCA1FDxyFVQCADcQDDhR1MVUJaNCAAdoAaNMAaJUxFWjGRdODJgMhLXVKE4AIAYov6x8I"
		. "ECs8dREGGQdAlmSExR8DCgAAncyAnADrJ4sUVcwHncORnAHYiYRFzJgqvcdFyAHDCMdFxAIpE4tVyCFIY8iDRcSAMMQ7AEXMfOWAfdMARHQTg17b"
		. "RchDYVhoCOsRhwTJhkTFUSsBwVFICItYDItFANiZid8Pr/iJANYPr/EB/vfhAI0MFonKi00MAIlBCIlRDOsdaYYNBXXGFNjQFIRcA8QAuMEs6QwC"
		. "hHHDB1B0D4WrQjTAQjQ3AItFwAXyFAAAgA+2AGYPvtBGCig5wnTEVMvNgYNFBsBAPYYNhMB1ug+EtgWBE4TAdBtFH5HAAcdACEJPQAzCGoIsgwYJ"
		. "AIsV1IAOIUADiVAIoYICAIsEQARDBYkUJP/QaIPsBAMvT8UeAy9mRQUvvAUvvAX3Gi8OfQ8vvAAvhg0aL0EFEC/M34cXQgGDF0EBixeSpYCDFyBu"
		. "dX/HRSID6zSgi0W4Bf0TFwcCF3TrWKwWuKAWZgagFr195xHQ5xFCAeMRQQHqEesCBSILjWX0W15fDF3DQQIFACJVbmsAbm93bl9PYmpAZWN0XwAi"
		. "BQF0AHJ1ZQBmYWxzQGUAbnVsbCcFVgBhbHVlXwAwMQAyMzQ1Njc4OQBBQkNERUYAAABVieVTg+xUxwxF9CELohiLQBSNAFX0iVQkFMdERCQQoipE"
		. "JAxBQ430VQzAAgjAAYCooAVgcyFDFhjHReQCBUXoFcMA7MMA8IMKEIlFDuRgAkEIJAwYi1X0VcAIIKQLHOQAGOEAjfBN5IlMgw/BDIEPxANrQjwg"
		. "EAQnDySgCwM2CRp14EEQYJzhCwiLVYgQi1KFBATraMYEWAN1XMEEoqG7ACx/ArmBCjnDGdF8FQUGAz1AAoCJ0IPYiP99LmA1jVXg4R6GieAe4TsE"
		. "JOihAASAhcB0EYtN4IYGAIkBiVEEkItdIPzJw5CQ4CqD7CBYZsdF7qM9RfALQCxgPABAhLrNzMwAzInI9+LB6gMh5pMpwYnKIA7AMACDbfQBicKL"
		. "RcD0ZolURcZgB8IFBPfiIAXoA4lFDACDfQwAdbmNVaFAA/QBwAEgBRAAEwYIwiKDEyj+//+QQ4AQYztgx0X4AlwaA0SLgBVF+MHgBAEQ0IlF2AEC"
		. "QBg5YEX4D41E4DMAFs4FoQTY4RlF9MZF84AAg330AHkHIAEwAfdd9KA4gxj0ulBnZmZmgBjq4BL4AAKJy8H7HynYVInC8Rns4hns4RmmgS4Hwfkf"
		. "icopQBEC9AENdaWAffMADHQOgQZBBsdERaY6LeBOpoABgB3ABNDGDEXrIEvCTYtF5I2CFKAA0AHQD7fgzUjkjQyBLQHIg3N1A1A5CAIAZoXAdRkV"
		. "JQEMJgEGEAUB6y0JvgJ0Gr4CdAeDRQDkAeuHkIB96xgAD4RhZuEfVdiJJBC40S3pyiQuQBwZIRWMo+IAwxTUxkWq44AL3IML3IIF1IQLvtyPCwgC"
		. "hQsjAYoL44ILL7wCgQu8AoEL3IML4wAEdA9KC+sYg0X4CbJ9QBBSC9f9//8/Mki6LL89YgByQ2Aj6AWhgQ/dAN1dkC7YswExsg7HReBjACIbjUWO"
		. "6FAnMAGRB6F4BgNQOBiLFaEAHUHhdEwk8BiNTdgFQQJqDEHlSH8VQSELPws/C8ABMRIAMQT0iwAAOokgSZ8LnwufC1+fC58LnwufCzY7ZMAJ5s+S"
		. "CtI2NApXSXwYNQErTKB9bo1FqGhK9pBACVQP6zeBQ3Qgi1UAsItF8AHAjRyVsGoMNJYMMZYTZkCdLg2hIYBs8CAQgWzwAWsFA2Ynt/NyPrR60xPs"
		. "AIN97AB5bYtNJuyPQY9BuDAQBCnQnapOvr4DpkHCBXWj4QKDwQJAQb4tAOtbzwYvzwZfVa8GrwalhCPrPqFCEyeNVb7WVui/E7O/E7IT6AF8AyYU"
		. "qek1NbMqGJIGF3oFEIMiAEzpdlCymgXpZBIBCFEDbSJ1VqIDFK0DXK4AHQkfBhMGEB4G/rNiPRMGXB8GHwYfBmgC6a7r8gQZBpwZBggfBh8GHwah"
		. "ZgJiAOlMHgY6GQYeDB8GHwYfBmYCZgDptuoCLxkG2CMwEwYKHwaHHwYfBmYCbgDpiB4GenYZBg0fBh8GHwZmAnKoAOkmHgYUGQYJHwbHHwYfBmYC"
		. "dADpNXEXBmayI0wTBh9+0Ie0AH68fm/fBt8G1QZuAnVtAjGTBQ+3wNCf8JDnsAAIi1UMiVQkBACJBCTobAAAAADrK4N9DAB0GACLRQyLAI1IAgEB"
		. "8AqLVQgPtxIAZokQ6w2LRRAJAFxQAQAciRCDRRAIAotFADYAZoWAwA+Fjfz//wJ6ghQKembHACIADHIAkMnDkJBVieUQU4PsJABBZolFANjHRfAS"
		. "FQAACMdF+ACGAOstDwC3RdiD4A+JwgCLRfAB0A+2AABmD77Qi0X4ZhCJVEXoARxmwegCBAE4g0X4AYN9APgDfs3HRfQDBQE7MwKFHItF9A+Qt1xF"
		. "6AqNidoQxwRt9IAg9AB5x7gRgT2LXfwBT5A="
		static Code := false
		if ((A_PtrSize * 8) != 32) {
			Throw Exception("_LoadLib32Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 3722, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 8476, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 8476, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			for k, Offset in [17, 50, 100, 638, 688, 946, 973, 1023, 1045, 1072, 1122, 1144, 1171, 1221, 1447, 1497, 1832, 1843, 2488, 2499, 4823, 4878, 4892, 4937, 4948, 4959, 5012, 5067, 5081, 5126, 5137, 5148, 5197, 5249, 5270, 5281, 5292, 6562, 6573, 6748, 6759, 8333] {
				Old := NumGet(pCode + 0, Offset, "Ptr")
				NumPut(Old + pCode, pCode + 0, Offset, "Ptr")
			}
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 8476, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "dumps": 4, "fnCastString": 1656, "fnGetObj": 1660, "loads": 1664, "objFalse": 5324, "objNull": 5328, "objTrue": 5332} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}
	_LoadLib64Bit() {
		static CodeBase64 := ""
		. "grUCAAwAVUiJ5UiBBOyQAFBIiU0QSACJVRhMiUUgSCCLRRBIiwAIBTsCGwBkiwBIOcIPRIS8AJTHRfwBbusAR0iDfRgAdC0Ai0X8SJhIjRVCMwBO"
		. "RA+2BABmRQIYAWCNSAJIi1UAGEiJCmZBD75A0GaJEOsPADYgIIsAjVABAQiJEBCDRfwBBT/zGgBCAAE+hMB1pQJ9iWBFwEiLTQCJAEONAEXASYnI"
		. "SInBWOjsIACOAnkZEGjHKAAiAA5luAGv6b3ABgAAxkX7AMuBbCRQMIMDQCAAbHVboQAMAcdF9AJsNYQQEBiLRfSATMHgBWhIAdCARtCAC4ABUGIQ"
		. "gAuDwAEADQCJlADAiEX7g0X0AUCAffsAdBMBGWNTARQFLXyyA1Ysgg8ICEG4WwExBkG4exMBuA9gRImPX8dF8FmCYJ0FAhmETfCJTchAg33wAH5e"
		. "GYwsSw8smQsgjwsPtoA68AABhMAPhOgBAJYAgSDGOjABQ42JATVbK2dAAcjAD4F7uIh7uCmEe/0eRRQcVBTp/rNDUgkV6erABMonOMInUUGCx0Xs"
		. "zK/swp+E2hjxr+zAr8MPRMAPyK/VBTWwCDWwBDUoBjWWSXIsTBrrG8YUxBPEErwaH9sSOr59AQ+LQBhwg/gBdWEwgBAKEFsyHUBT/gJiMOMEBg+c"
		. "hZPgQ2MFQYgIF6ABocBsacdF6Gwv6GInbhEABH8vbS/oYC/jB9GyFmcv6XJkEWMPbEAD1WQP5GwP5GIHmgAEfw+tbQ/kYA/jB1ppD/bqHqoAZw/g"
		. "bA/gYgckfw9NcA/gYA/jB+QVaA96B2YPwABKNBj6///pRlvEA0I0BXUfUwVtRaE5MEkFAnV6QgWNFFWQAQScwLTHRdwVwhlFwxkr4AeYi0WC3EAS"
		. "AcBMjQRAGKGtGUEPtxCTGdwgAQOnB6CZD7cAZoXAUHWk6aqCddgMJ9jZAh/wFB8nbw3YACfjB+6w4AeLdaogh4Ac/5isC47woAsojqG/D4xMQC81"
		. "LMBdJMB9P8Aq2EiB4sSh9F3DkAkA7fnv+4SB7OI5jawkgIL8pI3AYgCVyPIHhWEAhSANFLUASMdACDIX7YAJhaIC8QlQ8AnTAAFBg3UBsRqD+CB0"
		. "1S0BiAp0wi0BDXSvLQEICXScLQF7D4UpjgNyCa8HoQfHRVCyECjHRVh0AGByAIsFRAP/kBaLAEyifQWE9f7QAMdEJEBTAghEJDiCAI1VMEhQiVQk"
		. "MIAAUIEAKEWQASDQEQBBufEBQQWCFrqiAonBQf/S9eAXOEBcaM8QzxDPEM8Qh88QzxAnAX0PhMKiOBVpAYXgd6xeAYP4Igh0CrggEP/pZhEPgQ4B"
		. "lGAHwh7o9/3/oP+FwHQiAwJFAQJ/7wzvDO8M7wzvDO8MJAE6eRUKxBAPCAgIUijHCzqbwwu0A4iyA6Ayi40DLPRFaEQ7AmANfxqPDY8Nj48Njw2P"
		. "DScBLHUdbwdpYwfpwtALkI4d1Qy6Lg+fEJwQsDkJtjmLVaBoSIlQCBOtfcoD4ZMFWw+FZfJvPwX0MzuypHAA+HQAUkIQM8P7zfkztdEA/zONVdCm"
		. "8zMu8P8z/zPgGdjwM3DH/IWsMAGBAh8aHxofGh8axx8aHxonAV0PhMG9nzQ23kdQKCfHUFsnJxUOszEC4iaLlXEMUA1wRCf+7TAYLw0vDS8NLw0v"
		. "DS8NLUknJG8HYweD0xbpqstAUL4nXWUNPg1/Ir8nNbkncLcnAcoDFEgPhQ4TIso/BcsQSImFoDl4F4uV0gCwBWcHCAAo6VkEDxt1tAuCDOHvB1wP"
		. "hfavY+8H1QrcdTQgAZIHcQKJQgiyfXsfBLQ8x+oFVAdvBGIEXMtvBGUEgG8E+C9vBGIEli9vBGUEOW8E+GJvBAPkFJUCz7YAiwBIjVACSIsAhcAA"
		. "AABIiRAY6fICADgEcIsADwC3AGaD+GZ1NE0ASKABSAGwiZUBKGZYxwAMCKQMjKsQjG5VFIwKF0ZkEEZyFEYNVRdGHRBGdBRGCRcj1sIBDyN1D4WF"
		. "CguLGYMEMYArAADHhZyAAjkBAOk7AxkBDQAjweA4BInChRSCGQoxL37iQg0JOX8vBx+CHQcPIAHQg+gwiSfpriOCDYsgQH4/DQlGf0osGhU3CRXr"
		. "XI0PYBVPFGZcFFdKFAq4/1EAAOm1CJdTg4JQAQSDvYEBAw+OuP4Q//9Ig0IQAus6hcMPdckPEEiNSscPqghGfEhAfI0DJhKQXCAiD4WQ+4AWi4WK"
		. "yIIFSEYOKchIAi2BwwVACEiD6ASLeSXVLrhCftcHz2ItdEIuznwPjgwFTwo50A+P9QRBkpiBQQMbi0EiAB4UxQJIx0BAQHlQGXUiww1BSdirigYw"
		. "HnUhONMKTX5wDjAPjoKJ0AI5f3brTIYoAFAISInQSMHgAAJIAdBIAcBJTInAaQwgNYuVYwwKAaAHSA+/wEwBwLVgD9AFCIkACE5mH24OBH6OJUxT"
		. "BgAAkGHtAy4PhebYG0g+ZoAP78DySA8qwRSxYQLyDxHgQAYxBcAzQpTEM+tsi5VhAYmC0MAbAdABwIlCA734G5iAdwIM4AvgANLgAAEiCGYPKMjy"
		. "D14CymYOEEAI8g9YlsFsEKwgFw9IjmrKPwnDAmV0LgVFD4X4Nxub4Q5jBRSnRP8jBQCoxoWTE1QhIwMBlQ7E6zJtBit1H64JO1pYL34TT0MEQzpi"
		. "a4xhpLTrOouVYQGGN0F7OlMhN0QhPGEGvw6gDqCIx4WIBEXHhYSlDrgci5WhAkhGwQGDAgQUAYvCADtiDHzWgLK9Qh90KqlCwC/JoEZOjaEGIEYq"
		. "ROsoJwVIiQM1DyryBfIPWb0kFfkdJNg6i1JESJhIJA+vOTjrODoDBXVfvwawBqEDvwa6Bgy3IgMKAFNToQ98+HQPhcrfkhOAlRNSi7IAkAkIjRXN"
		. "EAMPtgQQGGYPvkEKmAM5wnR95B5LWgWdZqEE8BYWBXsBFAWEwHWXD7YFAMLm//+EwHQdn8kKqFLSPxURZIUVDgMHGVdLBfwiNkNQiwXuodEAicH/"
		. "0lMPq/+GIPhmD4XTUQ9FfKEiD0yLRXzSCeKwAhv/DvsOW/889w5FfAEttQSWtASQDqCQDtjlt58OTGGeDgSjBpgO8lQHLZMO5IIBlg7BLzP4bigP"
		. "haWSDngSBkmLdEV40gn+oSKfDpMOB9mSDut0bw5lDnhgDoME1rWEBGAOo+wLVad15AtKQ+oLNeoL6wVSB0iIgcQwYA9dw5AHAA+kKQ8ADwACACJV"
		. "bmsAbm93bl9PYmpAZWN0XwAihQB0AHJ1ZQBmYWxzQGUAbnVsbJcCVgBhbHVlXwAwMQAyMzQ1Njc4OUBBQkNERUbzBFUASInlSIPEgEgAiU0QSIlV"
		. "GExAiUUgx0X8A1NFA8BREVsoSI1NGEgAjVX8SIlUJCiQx0QkIPEBQbkxLBBJici60wJNEP8g0EjHReDSAMdFCuh0APC0BCBIiUUO4OAAU4miBUyL"
		. "UDBQi0X8SBAFQNMCRBQkOIUAMIIAjVXgP0YHwFdAB6IHYhVxlk0QGEH/0tEFMyEJdR4/ogaBl8IYYAbkANEY62AxpwIDdVO1AQEMgEhYOdB9QG7U"
		. "ArrwGn9RQhs50H/gU0XxD9gWSXCIUwfoQTaFwHRCD6AB2EiLVVADUoEwBhCQSIPsgBge2fMV7GDxFeQVZrIREAUoiUX4oBYUgASLTQAYicq4zczM"
		. "zAEwU8JIweggicIIweoDJl4pwYnKAInQg8Awg238CAGJwjETmGaJVBRFwFEEwooDwegDAIlFGIN9GAB1/qkgCxACsAJQk7GTYAoYDGYBsLHgCsRg"
		. "CSn0CnAx/yAA6a7SSZEbUBgRYwXB4AVxBYlF0A3xAGMQBtEBQDBIOfDCD42akB6wDqAaYAEFoAFAAAVF8MZF7wAASIN98AB5CMGgAAFI913w8BBB"
		. "EEFACfBIumdmAwBIIInISPfqgp/4AgFAJknB+D9MKcBDwQvJoEgpwUi2Eeg9shHosxEAnP8E9ARIwaT5P2ADSCmxC/DiCAB1gIB97wB0EINRBDME"
		. "x0RFkC0RKAaQ8gA0FIlFwMZFxudQR3Iui0XgoUKxteJF4QEPtxAkAbHvQCMkAciDR3VvrwIAZnCFwHUeeQHwAnUBBp1QBgEQhl8D0AF0Il8DAXIB"
		. "CoNF4AHpZgFwK5CAfecAD4SS9sU3i1WwCxC40Tcs6QFQAAobOAEbjMoDswKlGsjGRd8AlrMQx0XYAAAAi0XYAEiYSI0UAEiLAEXISAHQD7cQBQSQ"
		. "DAFIGEgByA+AtwBmOcJ1bw+owABmhcB1HgkuAF4BBS4GxkXfAes6CRNqdCITanQKg0UA2AHpZv///5BAgH3fAHQSAB4gAEiLVdBIiRC4AgEAsOsg"
		. "g0X8AUCLRfxIY9AAGxAASItAIEg5wg9AjDv9//+4AdJIAIPEcF3DVUiJIOVIgeyQARCJTQAQSIlVGEjHRaLgAiDHRegEB/CBAwpmgAsFgUMQ8g8Q"
		. "QADyDxFF6AANwBUEEciEA9CCA41F4DBIiUXAAAcBRkiLAAWE5v//SIsAUEyLUDCABnaBBseIRCRAAxpEJDgCBAKLAD6JVCQwSI1UVcABBCiADCAB"
		. "IEEquYEPQYJbugIVicFAQf/SSIHEAVxdjMOQBgCCZ4PsQAVmMEyJRSAAXABkx0Uc/BQCMgGGACBF8EiAg33wAA+Jm4IKQE3wSLpnZgMASACJyEj3"
		. "6kiJ0ABIwfgCSYnISaDB+D9MKYAkwsIEBOACAGJIAcBIKUDBSInKuDDADymA0INt/AGJwgFcQJhmiVRFwFgUSMjB+T8ADkgpQGtFIRyFesBywRBD"
		. "EMdERSDALQDpgLsmidAIg8AwOyZ1gMdFEuxBXOtQwAMYAHSuNgFnQhOBGQEAFuyCAjBMjQQCwqjAVo1IE4ACwXIKQQDKZokQBOsPwaeLAI1QAYEB"
		. "AokQg0XsARQStYfGjsWpQEd4xHcgyXcFAyYcTx9mxwAiABjpCARCfYkf6fQDg0OCQRqD+CJ1ZsMQshnSEFwA7hdcDpDDC3VKDnxKDlxfDl8OyAXp"
		. "6h1QDglKDghfDl8OxgWgYgDpqgJPDpZjAh1EDgxfDl8OxgVmAOnqN1AOI0oOCl8OXw7GBbBuAOnEAJBNDrBjAh1EDg1fDl8OxgVyAOnqUVAOPUoO"
		. "CV8OXw7GBbB0AOneQ6NKDsrEpRFDDh9+DYcBfn58N/8P8A/TBXXQBUMND7cL4ZUh2xiAnYnB6Ix1QZE0gwkejwnAAMAGEmFRjkiDRRAhlCIYhWDA"
		. "D4X8+4DQuBIi9a8SkMBIIOlm9khgVNVmwokAZo0FjfPQBVBUA2Bn4lMyD7dFEIM04A+RWovAVVBOtgBQZg++0JZZ6BECZhjB6AQRBNF7g338QAN+"
		. "yMdF+GA8AATrP7MKJYtF+EhgmEQPt0Tgd24LREyJwr8P4FZt+NAE+BgAebslVVUM"
		static Code := false
		if ((A_PtrSize * 8) != 64) {
			Throw Exception("_LoadLib64Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 4080, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 10464, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 10464, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 10464, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "dumps": 16, "fnCastString": 2000, "fnGetObj": 2016, "loads": 2032, "objFalse": 7008, "objNull": 7024, "objTrue": 7040} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}
	_LoadLib() {
		return A_PtrSize = 4 ? this._LoadLib32Bit() : this._LoadLib64Bit()
	}

	Dumps(obj)
	{
		this._init()
		if (!IsObject(obj))
			throw Exception("Input must be object")
		size := 0
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr", 0, "Int*", size, "CDecl Ptr")
		VarSetCapacity(buf, size*2+2, 0)
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr*", &buf, "Int*", size, "CDecl Ptr")
		return StrGet(&buf, size, "UTF-16")
	}

	Loads(ByRef json)
	{
		this._init()

		_json := " " json ; Prefix with a space to provide room for BSTR prefixes
		VarSetCapacity(pJson, A_PtrSize)
		NumPut(&_json, &pJson, 0, "Ptr")

		VarSetCapacity(pResult, 24)

		if (r := DllCall(this.lib.loads, "Ptr", &pJson, "Ptr", &pResult , "CDecl Int")) || ErrorLevel
		{
			throw Exception("Failed to parse JSON (" r "," ErrorLevel ")", -1
			, Format("Unexpected character at position {}: '{}'"
			, (NumGet(pJson)-&_json)//2, Chr(NumGet(NumGet(pJson), "short"))))
		}

		result := ComObject(0x400C, &pResult)[]
		if (IsObject(result))
			ObjRelease(&result)
		return result
	}

	True[]
	{
		get
		{
			static _ := {"value": true, "name": "true"}
			return _
		}
	}

	False[]
	{
		get
		{
			static _ := {"value": false, "name": "false"}
			return _
		}
	}

	Null[]
	{
		get
		{
			static _ := {"value": "", "name": "null"}
			return _
		}
	}
}

