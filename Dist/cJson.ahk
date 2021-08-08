;
; cJson.ahk 0.2.2-git-built
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
	static version := "0.2.2-git-built"

	_init()
	{
		if (this.lib)
			return
		this.lib := this._LoadLib()

		; Populate globals
		NumPut(&this.True, this.lib.objTrue+0, "UPtr")
		NumPut(&this.False, this.lib.objFalse+0, "UPtr")
		NumPut(&this.Null, this.lib.objNull+0, "UPtr")

		this.fnGetObj := Func("Object")
		NumPut(&this.fnGetObj, this.lib.fnGetObj+0, "UPtr")

		this.fnCastString := Func("Format").Bind("{}")
		NumPut(&this.fnCastString, this.lib.fnCastString, "UPtr")
	}

	_LoadLib() {
		static CodeBase64 := ""
		. "qLUAVUiJ5UiB7OAAAAAASIlNEEgAiVUYTIlFIEwAiU0oSItFEEgCiwAIRThIiwBIIDnCD4S0AJjHRQL8ABQA60dIg30AGAB0LYtF/EgAmEiNFXIb"
		. "AABQRA+2BAFgGAFgjQBIAkiLVRhIiQAKZkEPvtBmiQgQ6w8ANiCLAI0EUAEBEIkQg0X8GgEFPzIAPwE+hMB1EqUDek0gAT9JicjASInB6GMgAKEC"
		. "cUIZEGDHACIADl24AQGn6VsHAADGRST7AANTUDADB0AgCQDQdVsAGAHHRfSFAmg1hBAYi0X0gEgAweAFSAHQSIlMRdCAC4ABUBCAC4MMwAEADQCF"
		. "lMCIRQD7g0X0AYB9+2gAdBMBGWMBFAUtfAqyA1Ysgg8IQbhbYQExBkG4e4G0D2BEIomPX8dF8IJgOwYLAhmETfCJTciDffBoAH5eGYwsDywZFyAJ"
		. "jwsPtoA68AGEwMAPhNgBAACBIMY6cjABQ42BATUrZ0AByFPAD415fB5FEhxUEulm9kNQCRPp4sAEyiU4VcIlsMKr7Myr7MKb09oY8avswKvDD5PA"
		. "D8irKREzrx2eRSxMGOsbbdQSgwZG0xI6vnkBDw+AtkAYPAF1H4MQk8AsahDfHKBRqQPCL2FDBQYPhZRAQsUFOYBFKHVpx0XoDC6y6AImaxcfLg8u"
		. "6AAuzeMHK+AHBS7pI6QQow4qMKEO5KwO5KIG+hbbvw6vDuSgDuMHuuAHpg50rQKpDjihDiGnqQ7gbaIGir8OsA7goA7jB0oFqQ43pw5Mi00oTAOg"
		. "BWIJi004SIlMUiQAtU0wAQEgYTQrYPr//+kFJAZiNAU11TkwwTnaxDdCBQIP5IUd4QHHRSFn4QBiqFXgAMDhAGbgAgWiBfIADxAA8g8RRbhVQAOQ"
		. "RASY5ACg4gCNdEWw4JOQwAEACmAGBU7iAg0gGEGwBdTCDEREJECDBkQkOKMGlQBw////SIlUJKAwSI1VkAEBKIADUiBhCEG5QQRBIhK6AaIFicFB"
		. "/9LHRQrcQjBIQzAuSIuVInhgCItF3CApAcAYTI0EIC+NMEEPtzoQczDcIAEKCACtD7cAAGaFwHWe6a2V4onYTD7YQjacFF8+7c8N2EA+4wdc4Afr"
		. "ie017GAZv6wODPAADOiiYdOwD4yu+YAs69Nd9GmOff9p/2n4dUiBxCEweF3DkAIAIQEPAAcAVYXAhjCxH42sJIAyHEKNoSVIiZXIggeFC2EAsAwU"
		. "tQBIx0AI2/IWEAmFogKBCVCACdMAB3FLdQFxGoP4IHTVES0BCnTCLQENdK8RLQEJdJwtAXsPhY4pkkavB6IHx0VQVC+KWHQAYHIAiwUDcSyZ5i71"
		. "/tAA7y6NVYA7HbMuUL8uvy6ymIlFaH/PEM8QzxDPEM8QzxAnAX1YD4TCQjxpAYVQgayBXgGD+CJ0CrggEPD/6RYR0kCgpWAHwh4A6Pf9//+FwHTy"
		. "IgMC9RAPFu8M7wzvDNfvDO8MJwE6FQp0DwgJCNtSKMcLOsMLtAM4sgPBWNKNAyxFaNQ6spABfxo/jw2PDY8Njw2PDScBLHWmHW8HYwfpwtALkI4d"
		. "udUMag+fEJwQsDkJtjmAi1VoSIlQCIO2hi3KA5MFWw+FZbJo7z8F9DMirnAA+HQAUkIQMzTD+/kztdEA/zONVbtAsPMz8P8z/zPgGdjwM/Bwx4Ws"
		. "MAGBAh8aHxofHxofGh8aHxonAV0PhNsxx5803kdQKCfHMH0nJ8zFDTEC4iaLlXEMUA36cEQnnTAYLw0vDS8NLw23Lw0vDUknJG8HYweD0xYs6apA"
		. "UL4nXWUN7gzXfyK/J7kncLcnscoDFEgwD4UTBT8FzxBIiXaFMYuGBZXSALAFZwcIUADpWQQPG3W0CzLB7wf4XA+F9q9j7we51Qp1NCABkgdxAolC"
		. "CPdCfR8EtDzH6gVUB28EYgQGXG8E0gCwtgCJEOmAAwAASBCLhcAAAWAAD7eAAGaD+C91NACQAqABkI1QAkiJleEBKGbHAC8IpAJkBDRVAIw5EIxi"
		. "FIwIF4zyqgIPRmYURgwXRqsQRqpuFEYKFyNkECNyFCOqDRcjHRAjdBQjCRcjhNYBDyN1D4WFCgsHixkEMYArAADHhZxzgAIBAOk7AxkBDYARwXDg"
		. "BInCRQrCDAuDfuJCjQQ5fy+HD8IOhwcgAdCD6DDJE+muI8IGSxBAfj+NBEZ/SiwaFTcJFetcjQ9gFU8UZlwUV0oUCrj/UQAA6WUIl1ODglABBIO9"
		. "gQEDD464/hD//0iDQhAC6zqFww8lyQ8QSI1Kxw+qCEZ8SEB8jQMmEpBcICIPhZD7gBaLhYrIggVIRg4pyEgCLYHDBUAISIPoBIt5JdUuuEJ+hwfP"
		. "Yi10Qi5uPg+ODAUvBTnQD4/1BCFJmMEggw2LIREADxRlAUjHQCAgebAMdSLjBqEk+FWKBjAedSE40wpNfnAOMA+OgonQAjl/dutMhigAUAhIidBI"
		. "weAAAkgB0EgBwElMicBpDCA1i5VjDAoBoAdID7/ATAHAtWAP0AUIiQAITmYfbg4Efo4lTAMGAACQYe0DLg+F5tgbSD5mgA/vwPJIDyrBFLFhAvIP"
		. "EeBABjEFwDNClMQz62yLlWEBiYLQwBsB0AHAiUIDvfgbmIB3AgzgC+AA0uAAASIIZg8oyPIPXgLKZg4QQAjyD1iWwWwQrCAXD0iOaso/CcMCZXQu"
		. "BUUPhfg3G5vhDmMFFKdE/yMFAKjGhZMTVCEjAwGVDsTrMm0GK3Ufrgk7WlgvfhNPQwRD6mDox4SFjKS06zqLlWEB7YY3QTpTITdEITxhBr8OIaAO"
		. "oMeFiIQix4XihFUHHIuVUQEoI+EAUoMCAgGLYgA7MgZ8yNaAvaIPdCpZIeAXOslQI41RAxAjGiLrKCWXAkiDGg8q8gXyD1ZZvST5HSTYOotSREiQ"
		. "mEgPrzk46zg6A3wFdb8GsAahA78GugYMKbciAwBTU1EPfPh0KA+Ft5ITgJUTUosjsgCQCY0VfRADD7ZgBBBmD75BCpgDOfTCdOQe+/8tmGahBPAW"
		. "hRYFKxQFhMB1lxcKmeGCFeaDBNdIBdQSARHDTYsFxtEAicH/CtLTDIN/hPhmD4URAVTHRXyiDEyLRbp8Uge6sAJ/DHsMM38M0XcMRXwBtQRutAQQ"
		. "DGqgHAwEHgzy1AQTDOQLggEWDMEvLvhuD4UKpRIMeBIMSYtFeF1SB/6hHR8MEwwHEgzrtnTvC+ULeOALgwS1hAS14Auj7AtVp3DkC0PqCxI16gvr"
		. "BVIHSIHE4jBgD13DkAcApCQPAAMPAAIAIlVua25vAHduX09iamVjEHRfACKFAHRydQBlAGZhbHNlABBudWxslwJWYWwAdWVfADAxMjMANDU2Nzg5"
		. "QUIQQ0RFRvMEVUiJAOVIg8SASIlNABBIiVUYTIlF0CDHRfwDTkXATBFWAChIjU0YSI1VAPxIiVQkKMdEJCQg8QFBuYFESYkEyLrTAk0Q/9BIiMdF"
		. "4NIAx0XodACC8LQEIEiJReDgAANThKIFTItQMItFFPxIEAVA0wJEJDjFhQAwggCNVeBGB4CID0AHogdiFXGRTRBB/8bS0QUzIQl1HqIGgZJPwhhg"
		. "BuQA0RjrYKcCAwx1U7UBAQyASDnQVn1AadQCuvAaf0IbOZTQf+BORfEP2ElwgwlTB+jTMAOFwHQPoaAB2EiLVVADUjAGwBCQSIPsgBge8xUM7GDx"
		. "FeQVZsdF6kQAABAFiUX4oBYVAYAEi00Yicq4zQjMzMwwTsJIwehAIInCweoDJlkpAMGJyonQg8AwQINt/AGJwjETmKBmiVRFwFEEwooDAMHoA4lF"
		. "GIN98BgAdakgCxACsAJQjjexjmAKGAwBsKzgCsRgiwkp9Apw/yAA6a5CUYmRG1AYYwXB4AVxBWiJRdDxAGMQBtEBQIAwSDnCD42akB4vsA7AFWAB"
		. "oAFAAAVF8ADGRe8ASIN98AgAeQigAAFI910O8LAiQRBACfBIumcCZgMASInISPfqCYKa+AJAJknB+D8YTCnAwQvJm0gpwepIthHoshHosxEAl/8E"
		. "IfQESMH5P2ADSCkFsQvw4gh1gIB97xgAdBBRBDMEx0RFNJAtESiQ8gA0FIlFMMDGRedQR3Iui0UW4KFCsbBF4QEPtxAnJAGx6kAjAciDR3Vvga8C"
		. "AGaFwHUeeQHr8AJ1AQZQBgEQgV8D0AEMdCJfA3IBCoNF4AgB6WZwK5CAfeeQAA+E9sU3i1WwCwAQuAWzQAEAAADpAQBQiwBF/Ehj0EiLRQAQSItA"
		. "OEg5wjgPjMoA2ACAAFBAEABIiUXIxkXfABjHRdgAVAC02EiYCEiNFAF8yEgB0CgPtxAEJAwBJBhIAAHID7cAZjnCBHVvD1QAZoXAdS4eCS4ALwUX"
		. "BgBlAesSOhM1dCITNXQKgwBF2AHpZv///4CQgH3fAHQSAB4AIEiLVdBIiRACuAHj6yCDRfwBBQrkIALkO/3//7gBAWlIg8RwXcNVAEiJ5UiD7DBI"
		. "BIlNgHlVGEyJRVAgxkX/gHv4AxJ9EBAAeQiACAFI90ZdgCKAErpnZgMASACJyEj36kiJ0ABIwfgCSYnISQDB+D9MKcBIiRLCggngAoBXSAHAAEgp"
		. "wUiJyonQAI1IMItF+I1QAAGJVfiJykiYGGaJVIG1lihIwflyPwAcSCkAagBggUQPxIV6AHmAff+AeIYlAYAkx0RF0C0AgyBt+AHrPAAUGAAEdCKC"
		. "l4sASI1IggKAixhIiQqLABUAY9IPt1RV0GaQiRDrD4FMiwDAEAkBAokQQQ+DffgAhHm+hUcwXcOQxEcWIMlHQxgcTxhmxwBgIgDpCASCkckW6RT0"
		. "A8IEEIFvg/gilHVmwxAZ0hBcAA4nrZwckIMXihx8ihxcvxypigvpHZAcCYocCL8cQYgLYgDpqgKPHJYbwwSEHAy/HMgFZgDp6jdQDiNKDgpfDl8O"
		. "xgWwbgDpxMB3TQ6wYwIdRA4NXw5fDsYFcgDp6lFQDj1KDglfDl8OxgXwdADp3mOtSg7kr0QOiB9+DYcBfn58/w8b8A/TBXXQBUMND7fACyCSIakY"
		. "AJqJweiMdWGpNIMJHo8JwADABhJh8YlIg0UQwAQjGIWAwA+F/Pv//7kS6iKvEpCgkCCgkAcA5ZELAKWkkWaBo40FHfWBoAuJRfDHRfzBlwDrMg+3"
		. "RRCD4CIPobGLRfBBx7YAsGYPvtBhwmKv6CEEMGbB6AQhCKHFg30w/AN+yCC/wHgA6wo/YxUl4KxImEQPELdERejPFkSJwg16qbtlqaUY"
		static Code := false
		if ((A_PtrSize * 8) != 64) {
			Throw Exception("_LoadLib does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 3942, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 10112, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 10112, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 10112, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"dumps": 0, "fnCastString": 2128, "fnGetObj": 2144, "loads": 2160, "objFalse": 7056, "objNull": 7072, "objTrue": 7088} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}

	Dumps(obj)
	{
		this._init()
		if (!IsObject(obj))
			throw Exception("Input must be object")
		size := 0
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr", 0, "Int*", size
		, "Ptr", &this.True, "Ptr", &this.False, "Ptr", &this.Null, "CDecl Ptr")
		VarSetCapacity(buf, size*2+2, 0)
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr*", &buf, "Int*", size
		, "Ptr", &this.True, "Ptr", &this.False, "Ptr", &this.Null, "CDecl Ptr")
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

