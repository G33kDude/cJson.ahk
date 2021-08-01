
class cJson
{
	static version := "0.2.0-git-built"

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
	}

	_LoadLib() {
		static CodeBase64 := ""
		. "yrUAVUiJ5UiD7HAASIlNEEiJVRgATIlFIEyJTShASItFEEiLABBFADhIiwBIOcIPAIS0AAAAx0X8AQAUAOtHSIN9GAAAdC2LRfxImABIjRW1HAAA"
		. "RCgPtgQBYBgBYI1IAAJIi1UYSIkKAGZBD77QZokQBOsPADYgiwCNUAIBARCJEINF/AENBX51AD8BPoTAdaUJA3pNIAE/SYnISLCJweimAB4DcRkQ"
		. "YFDHACIADl24AafpAC4GAADGRfsASQNTUDADB0AgANB1QlsAGAHHRfQCaDUhhBAYi0X0gEjB4AAFSAHQSIlF0BOAC4ABUBCAC4PAAQMADQCFlMCI"
		. "RfuDAEX0AYB9+wB0mhMBGWMBFAUtfLIDVkIsgg8IQbhbATEGmEG4e4ADEGBEiY9fyMdF8IJgDgUCGYRNAvCJTciDffAAflpeGYwsDywZFyCPCw8C"
		. "toA68AGEwA+EsNgBAACBIMY6MAFD3I2BATUrZ0AByMAPjXmUvxpFEhxUEun2Q1BZCRPp4sAEyiU4wiWw1cKr7Myr7MKbFkAa76tm7MCrww/WGcqr"
		. "ETPyS4AInEUsTBjrG9QSxhsGRtMSOr55AQ8PtkDgGDwBdR+DEMAsahBiIuAZ6XwCwi9DBQYYD4WUQELFBTlFKKB1acdF6Awu6AImbK4YHy4PLugA"
		. "LuMHblPgBwUu6faqDjChDuS1rA7kogY9vw6wDuSgDqnjB/0XqA6Aqg44oQ7q4KwO4KIGzaAGvw6tDlbgoA7jB42pDgqnDkwwi00oTKAFYgmLTSA4"
		. "SIlMJAC1TTAFAQEgYTQu+v//6VbYQ2RjNAXVOXNAI+mqrUJk3KwY3KIQDL8YzbAY3KAY4wfMFk1kTRDu0CAEH4cMDPAADEh9wa1YD4zb4B5Mrl1E"
		. "rn0DX65KxkiDxHBdww6QBQBBAgkAVUiB7ELAQTKNrCSAwQWJ08AHwQCVWAI1hcEAYBfCFGUBSMdACOIrIBD2hUIFARFQABGjAUFv5QIAD7cAZoP4"
		. "IHQi1U0CCnTCTQINdCKvTQIJdJxNAnsPGIU3BOISUw/HhdA/hA2gAIEjpACCLZITBfpO/rAVwSfRcwXs0QDHiEQkQIMCRCQ4ggAEjZXRVkiJVCQw"
		. "V7AAMQWxACjwASCQBgBUQblRAkECFroCA4kwwUH/0oAIIQFIif6FsW4fEh8SHxIfEh8SHxJhJwF9D4S4Qk1pAYUF0G6iXgGD+CJ0CkS4/wAA6YcT"
		. "QQ+FGeEhSImQB0Ig6N/9QP//hcB0IjMCY/8xAh8NHw0fDR8NHw0fDSQB8jpFCuISDwgICNIpxwsWIsMLtAOmsAPHhYwXZiASGmMgKIUPjUgIuYUB"
		. "jZWhAjYf0h65kR8joD4JH8dFcIMjRXjPlCZBNCQGAwlFcEMB0QN5egcwi0MGNAFPKIAAMP3TKE3wrLBRoQjQL+onlieT0QY0FHU81QeLQCANDWAA"
		. "UAYSEQGJwf/Sf98pvxy/HL8cvxy/HCcBLAx1HW8HYwfpzPz/zP+Q7iwFHOUQzx/MHyVgSgl2F4uVUhWJUBoIk7Ol+gPDBVsPhUzhA28F10RFUNQd"
		. "WLV0AGBERLUBWkZEp9EAmf8bjVWQbBJEVVDvQyPvQ8LJiYX4QWyFPP+AArECfxp/Gn8afxp/Gn8aYScBXQ+Eal9EUERUk1MBvDa2+bk2Og+xGIxF"
		. "+lCsYgyJhThQAKjHhTRQABWxrY3xAACJyrjNzMzMSAAPr8JIweggiQDCweoDidDB4AACAdABwCnBiQDKidCDwDCDrSFRAwGJwoviA0iYQGaJVEXQ"
		. "ixIFiSLCGgTB6AOTBoO9gVEAAHWXx0Us0RXppQNIjVBsjeDP0saQe4+iFkZAsXwTAY1VLK8/+68/xGVF8nBwABAmeT+QiOYQRD93BjCLsAUEAR8j"
		. "+RY/iekPPw8/Dz8PPw8/f48kjySPJI8kjySPJAA/JMtvB2MHgzMu6RqAWn4/cl3FJO0MDzp/P3Y/sLUASIuV+AAAAEgQiVAIuABwAOmtQgwAaIuF"
		. "UAEBMAAAD7cAZoP4Ig8IhRMFCVhIjVACiQU0iRAILomFKAISdIVYAgyVAhoAtgQiZoDHAAgA6VkEDcRAhcB1Crj/AADpgi4QflwPhfYDIX65BK11"
		. "NAASAnkBJ4kChOUAeSIWQenHCi+EOhQjqlwXI4AQIy8UIy8XIyo5ECNiFCMIFyPyAlUPI2YUIwyXEauQEW5VlBEKlxFkkBFylBENVZcRHZARdJQR"
		. "CZcR1sNDqYoRdQ+FhYoFjpnBxBUAAMeFJIACwssOO4MMgQaAEcHgBIlGwkUKj6YvfkKNBDkcfy+HD8IOhwcB0INk6DDJE+muwepMEEBEfj+NBEZ/"
		. "LBoVN6kJFetczQdgLwpmPAqmVyoKhHlhCNcpg0IoCAGDvcEAAw+OuCD+//9IgyIIAusKOuMHIekHEEiNSlfnByGKIz5IID6NAxMSs1AuYJeQ+0AL"
		. "RZJIJgcYKchIghbjAkAISDiD6ATLPHUXI6WDBxFvMS10Lm4+D47wIw6e4D4Pj9nAAseFLiDBIIMNRKQUBqjHQPMgILAMdSLjBqEk36KDBjwwdSE4"
		. "0wpNfnAOMA8EjonQAjl/dutMA4YoAL2J0EjB4AIASAHQSAHASYmmwGkMIDWLlWMMCqAHgEgPv8BMAcBgDy7QBQgjxUxmH24Ofo4VJUz/wNKQ7QMu"
		. "D4UG5tgbSD5mD+/A8hhIDyrBFGEC8g8RK+BABjEFwDMcxDPrbCSLlWEBidDAGwHQ2AHAiUID+BuYgHcCDBvgC+AA0uAAIghmDyggyPIPXspmDhBA"
		. "YAjyD1jBbBCsIBeZD0iOaso/wwJldC4FcEUPhfgbm3EHswIUx1ci/xH/EcaFG7QrDCqaIZMBAU8HQwfrMj0DuCt1H94EHy1LEROvIUWEIeYwdMeF"
		. "FFRa69g6i5WxAMYbQZ8pnBseRBEeMQNfB18HfqDHRIUQhCLHhQxVBxxci5VRASgj4QCDAgIBCotiADsyBnzWgL1Zog90Klkh4BfJUCONp1EDECMa"
		. "IusolwJIgxrEDyryBfIPWb0k+R0KJNg6i1JESJhID5KvOTjrODoDBXW/Bi+wBqEDvQaTUWlPevh0KA+Ft9IRCNURUosjsgDQB40VjxADD7ZgBBBm"
		. "D76BCJgDOfTCdCQdE1oF3WShBDAVhRYFPRQFhMB1lxcrzSGBFcQwF0cF5jQFAUyIiwXYggHB/9LTDNKbTyD4ZtUMBNgMsQDdsgfGoRPfDNoMRR85"
		. "2Aw3oQTQDBYFdBQF3wwVCrfeDAK91gzq4r3WDM3vOuD4bg+FsdIMAizRDOxPi7IAsgf+AAHfDNQM8gfSDOt6rwylDHEEoAyt5gSv5ASgDJqsDE9n"
		. "cJWkDD2qDC+qDOsFsgcQSIHEwAADXcOQHwEA8wsPAA8AAwAiVW4Aa25vd25fT2KAamVjdF8AIoUAAHRydWUAZmFsgHNlAG51bGyXAgBWYWx1ZV8A"
		. "MAAxMjM0NTY3OIA5QUJDREVG8wQAVUiJ5UiD7DAASIlNEEiJVRgATIlFIMZF/wAEx0VRGQBIg30QCAB5CBABAUj3XSMQTVACumdmAwBIiRDISPfq"
		. "EnT4AkkAichJwfg/TCkGwFGKWXVIKcFIiQDKidCNSDCLRQD4jVABiVX4iYDKSJhmiVRFABpDHwUUBUjB+T+AA0hAKdBIiUUQkggPBIV6EBSAff8A"
		. "dAYStgSQBMdERdAtgACDbfgB6zyAAgAYAHQiSItFGCm2UlUYgFKLoAJj0qAPt1RV0DGfDxACeCCLADAEgQCQH9ADgyB9+AB5vtIaSINsxDAwGvQR"
		. "IPkREwYcMx8GQtvpCNKTugXp9Kki0kUQFd9mMwQZPwRvEtvOCS8HKgeQ4wUqB3x9KgdcLwcvBy8HLwfkAunSHS8H6QkqBwgvBy8Hhy8HLwfiAmIA"
		. "6aogUnKxAEiLRSCLAI1QAgEBgIkQ6ZYCAAIAAFAQD7cAZoMA+Ax1ZkiDfRgIAHQZAEwYSIsAAEiNSAJIi1UYAEiJCmbHAFwALOsPDIADXBwSXGYA"
		. "rOk3A7wK5CMKcgpKcqBuAOnEAQ9ysAMThQRyDUo5cgDpURA5Cj0KOQlKOXQA6d4aAA85yoMJBDkffg2xBwZ+fnyyP5MLdZALAYMaD7fASItNIAGB"
		. "CkmJyInB6IzpwCTrNAMTHg8TgAGADZASZokQECBFEIAJAUMwhcAPhfz7/wr/WSUiTyWQSIPEECBdw5AHAFVIiQDlSIPsIInISACJVRhMiUUgZgCJ"
		. "RRBIjQUd+oFAF4lF8MdF/IAsAADrMg+3RRCDIOAPSInCwBLwSAAB0A+2AGYPvgDQi0X8SJhmiQhURehBCGbB6AQBQRCDRfwBg338gAN+yMdF+AMB"
		. "EAI/wyoli0X4SJhARA+3REXojy1ERInC0T6DbfhAE/gwAHm7uAEjSDE="
		static Code := false		if ((A_PtrSize * 8) != 64) {
			Throw Exception("_LoadLib does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		}		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/		if (!Code) {
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "UPtr", 0, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to parse MCLib b64 to binary")			CompressedSize := VarSetCapacity(DecompressionBuffer, CompressedSize, 0)			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 9152, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 9152, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 9152, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")			Exports := {}			for ExportName, ExportOffset in {"dumps": 0, "fnGetObj": 1824, "loads": 1840, "objFalse": 7376, "objNull": 7392, "objTrue": 7408} {
				Exports[ExportName] := pCode + ExportOffset
			}			Code := Exports		}		return Code
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

