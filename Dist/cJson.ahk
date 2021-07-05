
class cJson
{
	static version := "0.1.0-git-built"

	_init()
	{
		if (this.lib)
			return

		this.lib := this.MCLib.FromString("V0;__mcode_e_dumps-0,__mcode_e_loads-3437,__size-7328;"
. "trUAVUiJ5UiD7HAASIlNEEiJVRgATIlFIEyJTShASItFEEiLABBFADhIiwBIOcIPAIS0AAAAx0X8AQAUAOtHSIN9GAAAdC2LRfxImABIjRXlGwAA"
. "RCgPtgQBYBgBYI1IAAJIi1UYSIkKAGZBD77QZokQBOsPADYgiwCNUAIBARCJEINF/AENBX6lAD8BPoTAdaUJA3pNIAE/SYnISICJweiqCwAAA3FC"
. "GRBgxwAiAA5duAEBp+kuBgAAxkUk+wADU1AwAwdAIAkA0HVbABgBx0X0hQJoNYQQGItF9IBIAMHgBUgB0EiJTEXQgAuAAVAQgAuDDMABAA0AhZTA"
. "iEUA+4NF9AGAfftoAHQTARljARQFLXwKsgNWLIIPCEG4W2EBMQZBuHuAAxBgRCKJj1/HRfCCYA4FCwIZhE3wiU3Ig33waAB+XhmMLA8sGRcgCY8L"
. "D7aAOvABhMDAD4TYAQAAgSDGOnIwAUONgQE1K2dAAchTwA+NecMJRRIcVBLpZvZDUAkT6eLABMolOFXCJbDCq+zMq+zCm0baGfGr7MCrww8GwA/I"
. "qykRM/YInkUsTBjrG2nUEm0D2xI6vnkBDw+AtkAYPAF1H4MQi8AsahAm4BnpfALCL2FDBQYPhZRAQsUFOYBFKHVpx0XoDC6y6AIm3hcfLg8u6AAu"
. "TeMHnuAHBS7p9qoOMNWhDuSsDuSiBm2/DrAOVuSgDuMHLakOgKoOOJWhDuCsDuCiBv0Wvw5trw7goA7jB73gB6YOCsGnDkyLTShMoAViCYCLTThI"
. "iUwkALUUTTABASBhNC76/1j/6dhDZGM0BdU5GqngCumtQmTcrBjcohA2PL8YsBjcoBjjB/wVu01kTRDUQZsfhwsM8AAMY0h9wa0PjNvgHkyuXQ1E"
. "rn1frkrGSIPEcDxdw8TigCrH4jyTCAQNL5P04XYAFQ+3AGagg/gidWbZHVyVeK1WDpDDC0oOfEoOXF8OJy8HLwfmAukdLwfpCX0qBwgvBy8HLwcv"
. "B+ICYtgA6aozRyoHljMBJAc+DC8HLwcvBy8H4gJmAKTpNy8H6SMqBwovBw8vBy8HLwfiAm4A6cTbcz4qB7AzASQHDS8HLweHLwcvB+ICcgDpUS8H"
. "9Ok9KgcJLwcvBy8HLwch4gJ0AOne73vpyiMzASQHH3YNxwB+dr58/wf/B29v7wLgAnXvAnGkBg+3wLhJoEkxjeu6NMMEHs8EYABgAxIvUBkBCEUQ"
. "YAITDIXAD3iF/Pu1SV8JX04yBJCdQEggR0jRUiNIZolATxCNBbEQEBOJRfAB1bgyD7dFEIPgUA9IicIABPDQoQ8YtgBmMFritWaJVIRF6BECZsHo"
. "BBEEAYG3g338A37Ix0RF+LA7AOs8AwoiAQ8Ki1X4SGPSDzC3VFXo3w7wWG344aAE+AB5vsVTdwtgaVHHU8ZF/5Bm+EMCfRAQAHkIEAEBSPeCXaGO"
. "EEi6Z2YDAAJIwA736kiJ0EgIwfgCsBhJwfg/mEwpwJENMQHgAqGvAAHASCnBSInKIInRi0X4sAiJVfD4jVEwkw6AYf8E9ASQSMH5P2ADSCnRswGh"
. "IhAAdYCAff8YAHQShgRQBMdERbjQLQChDY8RjxFVn3BLjxGAETCFEcSAz9ZFWChIx3ECgTAwkwDr9hKRBEIHUAElsGjhKhEBEcMxIHTe+gAKdM4R"
. "+gANdL76AAl0rmH6AHsPhY50Tl4GGNK5sHkA/3ESwI8IjwgPjwiPCI8I9AB9D4S6J6RINAFwM4SnIAFMjQxFuIM54BeNVbRIgIlUJCBNicEChAGw"
. "Lk0Q6Kj+//9AhcB0HLj/AADp/FMNDw3fCt8K3wrfCvQASDp0CrMG5wy/BonOEACaMZkjC4tVQDAuCyz1/SILZASgYASLRSi0SGMQklXQDkUw+5Ce"
. "wQBFwJ4BBsAvcZ5xBBpMcEe6kRngk0H/0h13D1u/CH8Pfw+LRfO0ACBIiwAPtwBmAIP4DXS+SItFEQfwCXSuCngsdRchBDxIjVACAiiJEEDp3/3/"
. "/5AKTn0QdAq4/wAA6ccLDAAAD2IADChIi1UCwAMUMMcABQAAxAC4AAMA6ZYHMANKIFsPhd8BFEQYuQIEADP/0EiJRciM6xISIgdIIHTeCg8YCnTO"
. "Cg+dfV0PhAYLB0SBCYXAD4T4lQBATAJnTQALRRgAawAwSIlUJCBNiYDBSYnISInCgAwAEOgG/P//hcAphYqxCoIjMABWY8gDA4aBVchIx0QkKAsB"
. "gwEEIAEETItVEIBJiclJidC6AXVASInBQf/SACQcnQMkaAMkWXuTfKL+jXzyXQU31AnUJMB5wjADfzWARhCDfKMHDIMSIg/YhegDGDaAe/hAEMAA"
. "x0AShRYADADpeIcNA2gKdQQlP80YXA+FJzvZGEQidYAqABuBB4lVIPhmxwAikAzpAZeLHUAXzg1c0Q3JAswNqi/ODS/RDZHNDWLODaoI0Q1ZzQ1m"
. "zg0M8QaqIe0Gbu4GCvEG6etlqIP4cu4GDfEGse0GKnTuBgnxBnntBnUPDIU3lYehCAAAx0Uq9IJQ/yNT+OAGweCOBKF2AASsQS9+NuoBODl/JkQG"
. "4gUEAwHQyIPoMAYI6ZADC6cGiEB+M+oBRn8jtAhSN6YI601KBmBMCGZNVghXRwgkYTUG8SGDAEX0AYN99AMPBI73IHtIg0X4AhTrLgMGBAYGEEiN"
. "qkoEBgjDMUjAMU3gDvYSTSVAeHRAnsYsLw5jf2anIL8KBy10IT1oLg+EjtetazkPj8NgAnjHRfBgO+OJYQxjqsfmAIQCaAp1GWAFgRncfVgwdSKr"
. "CQ1MjU0LMER+ckxCYus+JbqJANBIweACSAHQwEgBwEmJwOYJoCYUi1XgCQpgBkgPv9DATAHAgAzQx5lJTtIc6wt+ogU5bICpS7AwLg+FsvIWAxIA"
. "ZoAP78DySA8qIRFwKPIPEeQlgHuwFOwBYRPrVYtV7InQAVALAdABwIlF7Hs/C6AGmAAusgSgBHAA0gFwAFXsZg8oyPIID17KswUQAPIPHFjBeAYp"
. "DSsOOX6LEfoAZXQU+gBFD4UGfz88dF+LAIP4AUdUGw8OCA7GRetNIRg1MAEBbwXrQT13Ait1vha4A58jTw1DDVQaxsAHCMdF5PEk6y6LVVrkxhVB"
. "DyHGFUSxF+RDDwYKBrLHReAxG8eERdzSBROLVeCoGwDgg0XcAYtF3AA7ReR85YB961gAdB+lGWASyTAbTabg8Bo2Gusd5AEIpB1aReABWSkcxBYZ"
. "5C2LgEXwSJhID691K6brgTsyAgJ1vgTwuQSFoz+sT15/x0XYsgwQQ4tF2MAFjRWrAUACD7YEEGYPvtNxBsUCOcLVhmavIeJMFtiwDyMEaCQEhMB1"
. "vqnzIABNVUMBFOMIHe0IqmbhCNTlCNSyBCHvCG3rCNf/N+II1OAIIwTeLxAC7whoR+MIjp1GbnUQecdF0OIIQItFWtCyBJi0BO8IB+II62JLvwiD"
. "RdCwCPMDWBW3CKyzCAe/CADrBQHCBEiD7IBdw5ABAAAiVW5rbm93AG5fT2JqZWN0CF8AIoUAdHJ1ZQAAZmFsc2UAbhB1bGwAlgJWYWwAdWVfADAx"
. "MjMANDU2Nzg5QUIQQ0RFRkIGAEdDAEM6ICh0ZG02ADQtMSkgMTAuGDMuMKMBAgA=")

		this.pfnPush := RegisterCallback(this._Push, "Fast CDecl",, &this)
		this.pfnGetObj := RegisterCallback(this._GetObj, "Fast CDecl",, &this)
	}

	_GetObj()
	{
		type := this, this := Object(A_EventInfo)
		return Object(Object())
	}
	
	_Push(typeObject, value, typeValue, key, typeKey)
	{
		pObject := this, this := Object(A_EventInfo)
		value := this._Value(value, typeValue)
		
		if (typeObject == 4)
			ObjPush(Object(pObject), value)
		else if (typeObject == 5)
			ObjRawSet(Object(pObject), this._Value(key, typeKey), value)
		
		return 0
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

	Loads(json)
	{
		this._init()

		VarSetCapacity(pJson, A_PtrSize)
		NumPut(&json, &pJson, 0, "Ptr")

		if (r := DllCall(this.lib.loads, "Ptr", this.pfnPush, "Ptr", this.pfnGetObj, "Ptr", &pJson, "Int64*", pResult
			, "Int*", resultType, "CDecl Int")) || ErrorLevel
		{
			throw Exception("Failed to parse JSON (" r "," ErrorLevel ")", -1
			, Format("Unexpected character at position {}: '{}'"
			, (NumGet(pJson)-&json)//2+1, Chr(NumGet(NumGet(pJson), "short"))))
		}

		return this._Value(pResult, resultType)
	}
	
	; type = 1: Integer, 2: Double, 3: String, 4: Array, 5: Object
	_Value(value, type)
	{
		switch (type)
		{
			case 1: return value+0
			case 2:
			VarSetCapacity(tmp, 8, 0)
			NumPut(value, &tmp, "Int64")
			return NumGet(&tmp, 0, "Double")
			case 3: return StrGet(value, "UTF-16")
			case 4, 5: return Object(value), ObjRelease(value)
			case 6: return value ? this.true : this.false
			case 7: return this.null
		}
		throw Exception("Rehydration error: " type)
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
;
; MCLib.ahk redistributable pre-release
; https://github.com/G33kDude/MCLib.ahk
;
; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
; https://creativecommons.org/licenses/by/4.0/
;

class MClib {
	class LZ {
		Decompress(pCData, cbCData, pData, cbData) {
			if (r := DllCall("ntdll\RtlDecompressBuffer"
				, "UShort",  0x102 ; USHORT CompressionFormat
				, "Ptr", pData     ; PUCHAR UncompressedBuffer
				, "UInt", cbData   ; ULONG  UncompressedBufferSize
				, "Ptr", pCData    ; PUCHAR CompressedBuffer
				, "UInt", cbCData  ; ULONG  CompressedBufferSize,
				, "UInt*", cbFinal ; PULONG FinalUncompressedSize
				, "UInt")) ; NTSTATUS
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			
			return cbFinal
		}
	}

	Load(pCode, CodeSize, Symbols) {
		for SymbolName, SymbolOffset in Symbols {
			if (RegExMatch(SymbolName, "O)__mcode_i_(\w+?)_(\w+)", Match)) {
				DllName := Match[1]
				FunctionName := Match[2]

				hDll := DllCall("GetModuleHandle", "Str", DllName, "Ptr")

				if (ErrorLevel || A_LastError) {
					Throw "Could not load dll " DllName ", ErrorLevel " ErrorLevel ", LastError " Format("{:0x}", A_LastError) 
				}

				pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", FunctionName, "Ptr")

				if (ErrorLevel || A_LastError) {
					Throw "Could not find function " FunctionName " from " DllName ".dll, ErrorLevel " ErrorLevel ", LastError " Format("{:0x}", A_LastError) 
				}

				NumPut(pFunction, pCode + 0, SymbolOffset, "Ptr")
			}
		}
		
		if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", CodeSize, "UInt", 0x40, "UInt*", OldProtect, "UInt")
			Throw Exception("Failed to mark MCLib memory as executable")
		
		Exports := {}

		for SymbolName, SymbolOffset in Symbols {
			if (RegExMatch(SymbolName, "O)__mcode_e_(\w+)", Match)) {
				Exports[Match[1]] := pCode + SymbolOffset
			}
		}

		if (Exports.Count()) {
			return Exports
		}
		else {
			return pCode + Symbols["__main"]
		}
	}

	FromString(Code) {
		Parts := StrSplit(Code, ";")

		if (Parts[1] != "V0") {
			Throw "Unknown MClib packed code format"
		}

		Symbols := {}

		for k, SymbolEntry in StrSplit(Parts[2], ",") {
			SymbolEntry := StrSplit(SymbolEntry, "-")

			Symbols[SymbolEntry[1]] := SymbolEntry[2]
		}

		CodeBase64 := Parts[3]

		DecompressedSize := Symbols.__Size

		if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1
			, "UPtr", 0, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
			throw Exception("Failed to parse MCLib b64 to binary")
		
		CompressedSize := VarSetCapacity(DecompressionBuffer, CompressedSize, 0)
		pDecompressionBuffer := &DecompressionBuffer

		if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1
			, "Ptr", pDecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
			throw Exception("Failed to convert MCLib b64 to binary")
		
		if !(pBinary := DllCall("GlobalAlloc", "UInt", 0, "Ptr", DecompressedSize, "Ptr"))
			throw Exception("Failed to reserve MCLib memory")

		this.LZ.Decompress(pDecompressionBuffer, CompressedSize, pBinary, DecompressedSize)
		
		return this.Load(pBinary, DecompressedSize, Symbols)
	}
}

}
