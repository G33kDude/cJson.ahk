;
; cJson.ahk 0.5.1-git-built
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

class JSON
{
	static version := "0.5.1-git-built"

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

	NullsAsStrings[]
	{
		get
		{
			this._init()
			return NumGet(this.lib.bNullsAsStrings, "Int")
		}

		set
		{
			this._init()
			NumPut(value, this.lib.bNullsAsStrings, "Int")
			return value
		}
	}

	EmptyObjectsAsArrays[]
	{
		get
		{
			this._init()
			return NumGet(this.lib.bEmptyObjectsAsArrays, "Int")
		}

		set
		{
			this._init()
			NumPut(value, this.lib.bEmptyObjectsAsArrays, "Int")
			return value
		}
	}

	EscapeUnicode[]
	{
		get
		{
			this._init()
			return NumGet(this.lib.bEscapeUnicode, "Int")
		}

		set
		{
			this._init()
			NumPut(value, this.lib.bEscapeUnicode, "Int")
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
		. "FrYcAQADAAFwATBVieUQU4HstABIi0UUAIiFdP///4tFQAiLEKEkFwBIACA5wg+EpABwx0UC9AHU6ziDfQwAgHQhi0X0BTAAQAAPthiLRQyLAACN"
		. "SAKLVQyJCgBmD77TZokQ65ANi0UQACpQAQAOYIkQg0X0ABAFYgAQhMB1uQBjmYlFEKCJVaQBIUQkCBMARgAGBI0AEwQk6FBmHAAAAmkUC17HKAAi"
		. "AAxcuAGX6cNABwAAxkXzAMQIAItAEIXAdQwPCLYFBAAZiEXz6xpXARVQAKkBGznCdUJHgBQBx0XsgmgpAQIODItF7MHgBEAB0IlFsIsAAUAACItV"
		. "7IPCATkQ0A+UwIAhg0XsgAGAffMAdAuEIlBF7HzGglAkAgsHxLtbASYFu3uCpIlZJIkYjFiAvYGyAHQQUMdF6Auq6AVBHSiq6AAEhRgCqsdF5FkC"
		. "hqkFgUGDauSEaqyAg33kAA+OqYAPDRNWLA1WhSlSx0XgdYsp4Kop4AACRQyCKesKJ1MgIFUgZcdF3CFCIFTHRdiLItgFOkSoItgAAkUMgiKDRQLc"
		. "gAQYO0XcfaQED7aAefABhMAPDISfQMbCeRg5ReTEfXxkootFrMCNgLVQmIlVnI21mIG1j2oZRF8XDxPpgTjKE+kWykIEgCEcgCEPjZ9FwuHUC0DU"
		. "BUYoQNQPAAIlBuRwZBaQiVWUpW0WkGEW2xhYcSvqCwTrHMMJi1UQiVQj4AjgBFQkBIEIihodlQg6rSh/Q4ctDIP4WAF1HkEBLg4kwBbpDJwCASgD"
		. "BQYPhV41wjqsgJsoICAAgVXHxEXQyynQBU/fKcYpTtAAASUGwinpKiQOEBShIEYMzEsMzAVUu18MRgzMAAElBkMMx6YYi0G0QwzISwzIBVpfDF1G"
		. "DMgAASUGQwxkQgwYQI1IAQ+2lUPCrKCLAIlMJKEsDI8twLf5///pL+QSgS1YBXUgQgZPBYDhMgQRSAUCdWlAAY1VgKklBP4UwVzEIho3IhoAIItV"
		. "iItFxAEQwI0cAioaD7cTCREaxAEFBgHQD7dEAGbAwbfpkKJnwLELJcAFXx8l5grAAAFnJQamZy4cqhV/10YK5AMAAePJ5A+MSPr/ov9kng+EteIV"
		. "vOsV9rw/r4gLvAABJQYExKLld3FUEX+IBbR/VI8FhgW0F4AAFQN0VLggAbg7RagYfKRacV1TcX1fcYNdcZIJi138ycORGrMCALCJV1bQiZNRDBAU"
		. "IhRxAMdACNEBx0C2DDIMYAQIYQSgIQhxQYPAAEEfg/ggdOXYAIgKdNfYAA10ydgACAl0u9gAew+FcqNiPGgFx0WgMgdFwZCVYACoYwCsYQChqPAI"
		. "IbAuQBiLFaEAx0QkJCDiAUQkYIwAAAiNTZCgMxiNTaD1YAAUUAEQgZdwAPILcAAH4wwgV3EAiRQk/9CQg+wkiyBjRbDfDQ/fDd8N3w3XAH0PhFQr"
		. "5G0SAYXwbkMJAYP4ECJ0CrhAKP/p5HEQCo1FgNFg4QfALWmA/v//hcB0F/MBfsTwAf8J/wn/Cf8J1QA6ncUHZ88FcmmUCN/9kghVxAI6wgKIYzgI"
		. "YwKw/WECjIABTxRPCk8KTwrXAEgsdRIqBelUcBGQs1kWhQmhC18MgCwJ4jCgVbCJUAgDrHl1AmHzA1sPhfBFGTYohV5woUGxInK6kwB4lgB8Z5QA"
		. "/yj8KI1gkAIiKY1PEQVfKV8pVimFaBEDRf60sKbxAq8VrxWvFa8V1wCwXQ+EtnSP9imlA0DJ2B/h+9kfPAr1AcCL6uRjArRhAuZQFS8KLwo3Lwov"
		. "CtkfFioFYVzpAcuACBkgXcUJnwkfIBcgGrQWIHd1AkQ4D4VjpgPvNWB4ReCSA+CQA+GjBAgA6e8FS/RutAfCIzsFXA+Fqp1NKQfFUXvggAGJVeDi"
		. "ajsuros5BsAE2wJc3AJd2wKqL9sCL9wCL9sCYtsCqgjcAgHbAmbbAgzcAqrT201u2wIK3AKl2wKqctsCDdwCd9sCdNsCCzEe2QJJ2wJ1D4UR300+"
		. "4AOAA7FlIs/podcwATMAA4DcicLhATobL37iMNgAOX8iwwKRAlMBIAHQg+gwhQPpgMu3AAAAAItFCIsAAA+3AGaD+EB+Ai0IaEZ/H4tF4AkALInC"
		. "BVQB0IPoAjcBOOBmiRDrRVUIsGAKdGYTdFcGdApEuP8AAOmSBgR/jQRQAgAHiRCDRdwAAYN93AMPjhaBAB+DReAC6yYDKqJnBCoQjUoCKggASaCN"
		. "SAKJTQBmEgBSAQh9Ig+F//z//yCLRQyLSAEmKcgBAXcMi0AIg+gEsQEp4GbHBfgFPLgACBgA6QKFRwMkLXQkQYgGLw+OsQOKDzkID4+fgAjHRdgB"
		. "FYInDIArFIEDx0AIMYEnx0AMAQOJKHUUj4AWAWiKPogQMHUjEyCJhRXpjgspMH51CUlQf2frRwF2UIF3awDaCmvIAAHZuwIKgBn34wHRicoAi00I"
		. "iwmNcQIAi10IiTMPtzEAD7/OicvB+x8AAcgR2oPA0IMA0v+LTQyJQQhIiVEMyT5+GgkZfoKdRXDQBAAAkIgGMC4PhaVNLIYjZg8EbsDAAMpmD2LB"
		. "IGYP1oVQQBDfrbNBAYAI3VjAakFQBQBUAtQBVOtCi1XUiQDQweACAdABwAiJRdRDFUgCi1UICIkKwBuYg+gwKImFTMAP20MBRdSE3vmBEkAI3sGF"
		. "FBXIMA7KMKJIA2V0EuFIA0UPhVUAIA0xAweoFHUxCTTQwADaADSK0wA0lRU0xkXTS4FqE0AEAcoX60DMBggrvHURhgzQiE0yxGJEwqKCzEGM6yeL"
		. "VcyHToLDUU4B2IlFzLgKEL3HRcjBMMdFxCFCChOLVcioMciDBEXEQBjEO0XMfIDlgH3TAHQTQy8I20XIozBYCOsRrUcCyUYi5SgrJHRYIE0A2JmJ"
		. "3w+v+IkA1g+v8QH+9+GYjQwWYVUkUesdxgY0BXVmCthwCkQuAwAJA3oxAmpldA+FqwUiGsAiGjeLRcAFAE8XAAAPtgBmiA++0CYFOcJ0ZCpi8O1A"
		. "g0XAoB7GBoRAwHW6D7YFwQmEeMB0G6UPQ3iiJ0N464IsQwMJAIsVKEAHIaABiVAIoUIBAIsEQASjAokUJP/Q6IPsBIMXdGUPhKqFF6K8hRe8BVSa"
		. "FzOPF768gBfGBpoX6I+JFyCHFy9CAYMXQQGLF7erlG4PDIWggheiA+s0i0UouAVakxcHghfred0sF7ggF2YGIBe9IBehE9UgFxbDEwjAEyzGE4kW"
		. "PiSHFkIBgxZBAYoW6wUBQg+NZfRbXl9dMMOQkJChAgkAIlUAbmtub3duX08AYmplY3RfAA0KCgAMIqUBdHJ1ZQAAZmFsc2UAbgh1bGzHBVZhbHUA"
		. "ZV8AMDEyMzQANTY3ODlBQkMAREVGAFWJ5VNAg+xUx0X05ryLAEAUjVX0iVQkIBTHRCQQojBEJKIMQUmNVQzAAgjAAQ+ArqAFYHmjFxjHReSpAgVF"
		. "6MMA7MMA8IMKcBCJReRgAmPUIgwYqItV9MAIIKQLHHQAghhxAI1N5IlMwwffYQbBB+QBIiEQCASXB/Bx0hADHgl18CMQMFHxBUAIi1UQi1JFAgTE"
		. "62hmAgN1XGEC0lMSu7AWf7lBBTnDGSjRfBWGAT0gAYCJQNCD2P99LmAbjTRV4HEPiXAPsSAEJATooQAChcB0EYsETeBGA4kBiVEEYJCLXfzJgBtw"
		. "FYNA7Fhmx0Xugx9FCvAgFhQBEE0Mus0AzMzMicj34sGE6gP2TCnBicoQB0DAMINt9AHhgvRgZolURcawA+IC9wLikALoA4lFDIOAfQwAdbmNVaAB"
		. "UPQBwAGQAhCACQiDYhHDCSj+//+QQAihsx1gx0X4AjEapEgBwApF+MHgBAHQCIlF2AEBQBg5RbD4D41E8BkAC85RAgLY8QxF9MZF8wBAg330AHkH"
		. "kAABGPdd9FAcQwz0umcoZmZmQAzqcAn4AiESfCnYicL/DINtKuzyDOzxDKaeA8H5UB+JyimgCPSBBnWApYB98wB0DkEDQSEDx0RFpi1wJ6aHwADA"
		. "DmAC0MZF65AlIeImi0XkjeGO0AGI0A+38GnkjQzBFiQByIM8dVgKAgBmUIXAdRklAQwmAQbZEAUB69CjvAJ0EIe8AgB0B4NF5AHrh4CQgH3rAA+E"
		. "YWmZ4R9V2PCb0S3pyiQuZEAcIRWMo+IAwxTUqMZF44AL3IML3IIF+tSEC9yPCwgChQsjAYoLvuOCC7wCgQu8AoEL3IMLEOMAdA9KC+sYgyRF+LKA"
		. "QBBSC9f9/P//4ki6LL89YgByQ2AjhOgFgQ/dAN1dkC7G2LMBsg7HReBjACIbOI1F6FAnMAGRB6GkOxA940AVoQAdQeF3TCTwGI1N2AVBAm0MQeVI"
		. "fxVBIQs/Cz8LwAExEgAxBPSLAAA6iSBJnwufC58LX58LnwufC58LNjtkwAnmz5IK0jY0CldJfBg1AStMoH1ujUWoaEr2kEAJVA/rN4FDdCCLVQCw"
		. "i0XwAcCNHFVwbQw0mQwxmRNx0Q2XoSFAb/AgEEFv8AEFAzVmJ7fzdT60fdMT7IMAfewAeW2LTeyTj0GPQbgwEAQp0KpOzr6+A6ZBwgV1o+ECwQLB"
		. "QEG+LQDrW88GzwaXX1WvBq8GpYQj6z5CE9AnjVW+1lbovxO/E9myE+gBfAMmFKnpNbMqGhiSBhd6BcCDIgDpZsky35gF6bdT4MTmdcpWogMUrQNc"
		. "AB0JHwbVEwZjHgZRGQZcHwYfBlMfBmgC6QEeBu/TaImxAA+3AGaD+Ah1AFaDfQwAdBSLAEUMiwCNSAKLAFUMiQpmxwBcQADrDYtFEABMUFIBAByJ"
		. "EAKYFw2YYkAA6Z8CAAAKUukqjQIiCAPCDDzCZgBU6T0OYSsJYQo8YW7QAOnbAY0wyYIIhDBCDbwwcgDpeY4wZ4WJMAm8MHQA6ReOMAIFgAgPtgUI"
		. "AAAgAITAdCkGNh92QgyGBX52B7iACQAI6wW4QAEAg+ABVOszCAoYCAoTxAI92KAAdw0NwBdvKTCOCQZ1jQkDGw+3wItVIBCJVCQIAQpUJEAEiQQk"
		. "6G2BHisnwhHAJ8gRi1XADBJmRIkQjRxFCAIEL4WAwA+FOvz//1MhAiJNIZDJw5CQkIBVieVTg+wkgBAAZolF2MdF8G9AFwAAx0X4AT/rAC0Pt0XY"
		. "g+APAInCi0XwAdAPALYAZg++0ItFQPhmiVRF6AEHZgjB6AQBDoNF+AEAg334A37Nx0UU9APBDjOCIRyLRUD0D7dcReiKI4kS2hAybfRAEPQAeSLH"
		. "Al6LXfzCJw=="
		static Code := false
		if ((A_PtrSize * 8) != 32) {
			Throw Exception("_LoadLib32Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 3955, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 9164, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			DecompressedSize := 0
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 9164, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			for k, Offset in [41, 74, 124, 236, 415, 465, 582, 632, 721, 771, 978, 1028, 1286, 1313, 1363, 1385, 1412, 1462, 1484, 1511, 1561, 1808, 1858, 1984, 2034, 2073, 2123, 2388, 2399, 3044, 3055, 5379, 5434, 5448, 5493, 5504, 5515, 5568, 5623, 5637, 5682, 5693, 5704, 5757, 5809, 5823, 5841, 5863, 5874, 5885, 7166, 7177, 7352, 7363, 8682, 9021] {
				Old := NumGet(pCode + 0, Offset, "Ptr")
				NumPut(Old + pCode, pCode + 0, Offset, "Ptr")
			}
			OldProtect := 0
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 9164, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "bEmptyObjectsAsArrays": 4, "bEscapeUnicode": 8, "bNullsAsStrings": 12, "dumps": 16, "fnCastString": 2212, "fnGetObj": 2216, "loads": 2220, "objFalse": 5920, "objNull": 5924, "objTrue": 5928} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}
	_LoadLib64Bit() {
		static CodeBase64 := ""
		. "2rUcAQAbAA34DTxVSIkg5UiB7MAAFEiJAE0QSIlVGEyJAEUgRInIiEUoQEiLRRBIiwAEBQTVHQA+iwBIOcKID4S8AFbHRfwBegDrR0iDfRgAdAAt"
		. "i0X8SJhIjYQV3QAnRA+2BAAzBEUYATCNSAJIiwBVGEiJCmZBD4C+0GaJEOsPABtAIIsAjVABAQiJoBCDRfwBBT+dAD8hAT6EwHWlAn2JRSCgSItN"
		. "IAJDjUUAoEmJyEiJwegsliMAjgJ5GRA0xwAUIgCOMriBV+kvCWAAAMZF+4BlgWxAACBIhcB1DA+2AAXF/v//iEX7JOtwAwxQMAYQOcKEdVuAGAHH"
		. "RfSCeEI1hBAYi0X0AFnBoOAFSAHQAFOwgAuJgAFQEIALg8ABAA0JgJWUwAAqg0X0AUCAffsAdBMBGWNS0AgtfLKDYiyCDwgIQbhbATEGQbh7E4HH"
		. "j2xEiQ9sgH0oQAB0ZMdF8Axk8GkCVF0cMWTwAGTDDx0jwA8FZMdF7AJRpQYLAidEQexJQaiDfeywAA+OyoEv2GcslDFQZsdF6Iwx6IIhltobsTHo"
		. "gDHDD1bAD4UxFOsvmSYglCZ5x0VC5IImaMdF4Mwo4GnCGPUa8SjgwCjDD7UjwA/FKINF5MAFMDtAReR9kA+2wJDwwAGEwA+E6IDvQVzlBpEwQZmN"
		. "idwt0GGgAFao4AcBbJgIbJgEbDXKICUKHDQK6f5DVIkKbOnqYALqEzjiE2Fvx5RF3Kwm3KIewRm/Ju2vJtygI+MHgeAHKIaFGkqQiBqQhBpgH94k"
		. "LLksDesbZgrkCWQJ9AYkHXMJOlAuv04tNItAGHCD+AF1YTCAEAoQkzIeIHEXA2Iw4wQGD5yFn+BDYwWBtjAYoAGh4Jdpx0XYbC/YYiduTgAEfy9t"
		. "L9hgL+MHDiPgB2Uv6YsCaQ+UF9VmD9RsD9RiB9cABH8PbW0P1GAP4weX4AdmDw9Vag8oZw/QbA/QYgdhW38PcA/QYA/jByFpD5OhYnIwjUgBQApN"
		. "YeYZwBAATIAGQQqJTCQCIME1lPj//+loY8QzwjUFdR9kBSw7mYUhOz1JBQIPhYOjbQCoSI2VcP///0XhBMFgmsdFzBIOSEETDi5Ii5V44AGLBEXM"
		. "gAoBwEyNBMOADT0OQQ+3EC8OIQ4OzJAACgRQXQ+3AGZRUHKe6apSPMgcFci5EhEUFh8VHxXtBsgQFdnzA9QVXTwqEaagDu8zOw9O2gXs0AWoSPF2"
		. "D4wQRPn///FcD4Td1eIMxOwMxOIIJ+AI7wyb7wwLB8QAB/MD5xRZc6/BlXJjkZPJBrzCAr3AArfPBs8Gywa8wAbzA33IBgiDRcBwAcA7RTDUfJCs"
		. "hV2khX2vha+FETiTSIHEAQxdw5BHAQAfpv2kgewwsSuNqKwkgEKljbOllYEjWEiLhWEAEBsUtQBI2MdACGIRAAmFogJxCT5QcAnTAIFQdQGhKIP4"
		. "iCB01S0BCnTCLQGIDXSvLQEJdJwtAXB7D4UpMlSvB6IHx0RFUDIQx0VYdABgcXIAiwUDUThxPrGiBYL18KNIx0QkQFMCCEQkOIIAjVUwSFCJVCQw"
		. "gABQgQAopZABICG4QbnxAUECFoK6ogKJwUH/0mAX+jjAa2jPEM8QzxDPEM8Qw88QJwF9D4TCYkdpAQqFYIesXgGD+CJ0hAq4IBD/6ZQRgQ4Hobpg"
		. "B8Ie6Pf9///QhcB0IgMCcwEC7wy/7wzvDO8M7wzvDCQBOhUKvPIQDwgICFIoxws6wwtNtAO2sgMgMouNAyxF+mg0SUJgDX8ajw2PDY8Nx48Njw0n"
		. "ASx1HW8HYwc86cLQC7CPjB3VDOgPF58QnBCwOQm2OYtVaNBIiVAIs9OrygOTBfBbD4Vlsnc/BfQzYsmdcAD4dABSQhAzw/v5M2a10QD/M41VQMXz"
		. "M/AX/zP/M+AZ2PAzcMeF/qy07h8aHxofGh8aHxofGrEnAV0PhNHinzTeR1DJKCfH+iknQw4xAuImrIuVcQxQDXBEJy3gKAEqDca1AI1QAkiLhcAA"
		. "IAAASIkQBZCLAAAPtwBmg/ggdCLVDZAKdMINSA10Iq8NJAl0nA0kLHWKJAckSArsg4WsAAiAAemq/v//kA03IF10Crj/AADpbC4NARUTQQAJyAAJ"
		. "ZscMAAkBIwELSItVcCBIiVAIuAALAOkGLwo8A1kiD4UTBWMaU4ULiYWgggQELJUHggaALQc7CADpWQSRDTGFwHWEXbAMDz9gXA+F9gMhP4RWdW40"
		. "AAmCPIETiQJCgDwiuZYg6ccKL4Q6FCNclxGqgJARL5QRL5cROZARSmKUEQiXEfICjxFmVZQRDJcRq5ARbpQRClWXEWSQEXKUEQ2XER2dkBF0lBFC"
		. "uJMR1gGPEXB1D4WFigWOmeQKALAAx4WcgWXhZTtDBsNBA8AIweAEicF+IgURT1MvfkJNAjl/LwfHB2IHxwMB0IPoMBnpCemuo2sqCEB+P1FNAkZ/"
		. "LJoKN4kK66pczQdgLwpmPApXKgophHnjCNcpg0IoAYNCvcEAAw+OuECaSKKDIggC6zrjB6PpB3AQSI1K5wchiiM+SDUgPo0DExJQLmCXkPuLQAtF"
		. "kkgmBynISIIWgeMCQAhIg+gEyzwbdRcjpQWqG6MNLXQuMW4+D44MiqfkPg+P4vXgoMeFmMEgh6YADzIUBqjHQGAMsAx1Is/jBqEk36KDBjB1ITjT"
		. "CkNNfnAOMA+OidACOTB/dutMhigAvYnQAEjB4AJIAdBIYAHASYnAaQwgNYsKlWMMCqAHSA+/wOhMAcBgD9AFCCPFTGYSH24Ofo4lTIEGAMIADuEu"
		. "D4Xm2BtIPgBmD+/A8kgPKmPBFGEC8g8R4EAGMQWFwDOUxDPrbIuVsQAEidDgDQHQAcCJ96IB/w32DZjAOwIG8AVwAAbScAASBGYPKMjyCA9eyjYH"
		. "EEAI8lgPWME8CFwQFw8kjiZq6h9jAWV0ngJFD9yF+I9N/RCzAhRXIv8Rsf8RxoWTDyoBKiGTASYBTwdDB+syPQMrdW4f3gQfLUsRE68hhCFohbI1"
		. "jFRa6zqLlbEA7cYbQZ8pnBtEER4xA18HQV8HfqDHhYiEIsfEhYRVBxyLlVEBKCOl4QCDAgIBi2IAOzIGkHzWgL2iD3QqWSF14BfJUCONUQMQIxoi"
		. "60oolwJIgxoPKvIF8rwPWb0k+R3BpdU6i1JEIEiYSA+vOTjrOPk6AwV1vwawBqEDvwa6BlIMtyIDAFNTzw98+FB0D4XfkhOAlRNSRouyAJAJjRUS"
		. "4JAPwLYEEGYPvkEKmAP0OcIlr3laBZ1moQTwFg0WBcDQAhEFhMB1lwAPtgUi5P//hPjAdB3JCqhS0j8VEWSFzBU+AwdXSwUsEgFDUAiLBR7RAInB"
		. "/9IFUw/Z/4b4Zg+F0wlRD0V8Ig9Mi0V83dIJJ9QJ/w73Don/PPcOaEV8AbUE23AClA6guZAOOOOfDkxhng40owZtmA4iEgGVDhTRAJcO76kvM/hu"
		. "lQ54lQ540gluQ9QJnw6XDp8PQZgOeJuQDrME92Enlw5+4pIOdiCJx8AMl9jJiS7FDlfb+wHgDUWEB8MON4IBxQ6E6wUyCkiBxDCQDPhdw5AJAKQs"
		. "DwAPAA8AAQAAIlVua25vdwBuX09iamVjdFBfAA0KMAoi1QB0AHJ1ZQBmYWxzQGUAbnVsbOcCVgBhbHVlXwAwMQAyMzQ1Njc4OQBBQkNERUYAVQBI"
		. "ieVIg8SASACJTRBIiVUYTECJRSDHRfwDV0UDwFURXyhIjU0YSACNVfxIiVQkKJDHRCQg8QFBuTEwEEmJyLrTAk0Q/yDQSMdF4NIAx0UK6HQA8LQE"
		. "IEiJRQ7g4ABTjaIFTItQMFCLRfxIEAVA0wJEFCQ4hQAwggCNVeA/RgfAW0AHogeCFnGaTRCYQf/S0QWE83UeogafgZviGWAG5ADxGetgpwIYA3VT"
		. "tQEBDIBIOazQfUBy1AK6EBx/YhwoOdB/4FdF8Q/YSQtwjFMH6KErhcB0D7UAD0iLRdhIi1UAIEiLUghIiRAAkEiD7IBdw5AhBQBVSInlAEhgSACJ"
		. "TRCJVRhMiQBFIGbHRegAAACLRRiJRfjHRQj8FAAAGE0YicoAuM3MzMxID68AwkjB6CCJwsEA6gOJ0MHgAgEA0AHAKcGJyokA0IPAMINt/AEAicKL"
		. "RfxImGZQiVRFwAGKwgo4wQDoA4lFGIN9GMAAdalIjVUAIQArQEgBwEgB0AGmSQCJ0EiJwkiLTUAQ6AH+//8ArsTWYAiuBa9wAa9IBLAApIEAowDp"
		. "rgIAAADuIBBIi1AYA1bB4KIFgSuJRdCBB2OAMAGBDkAwSDnCD43QmgEAAIB1uAIaAA0CQAAoRfDGRe8AgEiDffAAeQgABeABSPdd8ICHAYIASiDw"
		. "SLpnZgMASIkgyEj36kgAV8H4AAJJichJwfg/mEwpwAFegQngAgE8UQBrKcFIho3ogo3ohYONkJgnSMH5PwAbFEgpgV3wAkd1gIBgfe8AdBCBIoMh"
		. "x6BERZAtAIChkIIHAYShiUXAxkXnAIjHReCBiYtF4EAGjI0UgTiBBw+3EIQEAgyBBBhIAcgPt0AAZjnCdW+PCgDgZoXAdR7JBcALxQUiBkAZAes6"
		. "Uw10IgFTDXQKg0XgAekEZv9AdoB95wAPVIT2AlZFgKdVwC4QYrjAZADpAUABCmw4GQFsjMrDCoVqyMZFqt/AOdjDOdiGG8jFOb+CBNA5jQrFOccF"
		. "yznfwjkvUQ3BOVENwTnYxjnfAAR0Es046yCDRfwLAHIIOSACOTv9//+DgKRAOoPEcF3DwrvYgeyQAQSEvEjEdsABm8DpwgHwwQHAsuAFAsCA8g8Q"
		. "APIPEUCFqMdFwEQEyOQA0OIAHo3AMyBFwAGBEUiLBQBE5v//SIsATCiLUDCgATahAcdERCRAgwZEJDgCAYthgA+JVCQw4XYBASilIAMgAQhBueED"
		. "QeIWArpCBYnBQf/SSOyBxAEX8HdA6XcDjkSNx4MhAAjkXg+Jm39veW/kuDDgBynQLZO/b6lveA+FemA5YQgjCGBvwPAtAOmAXxPfgh8T2oJIx0Xs"
		. "IS7rUOABGFgAdDaLqgAL7EIBTJiNBAJiVGArjUhAAQlhOQpBAGVmiRDrgcHEIIsAjVABAQHAiRCDRewBFAlHY9qO5VRAJzzkOyDpOwMTAhyvD2bH"
		. "ACIA6UxeBEOAyA/pSmMCEEEhDYP4InVmYwgZmXIIXADuF1wO5gNPDnbSYwJEDlxfDl8OyAXp6nNQDl9KDghfDl8OxgXQYgDpAFAO7DRyIwc+DC8H"
		. "LwcvBy8H4gJmAKzpjeMFKgd5KgcKLwcPLwcvBy8H4gJuAOka6S8H6QYqBw0vBy8HLwfDLwfiAnIA6acwTy0H9pMzASQHCS8HLwcvBy8HoeICdADp"
		. "NC8H6aFXAA+2BTnW//+EiMB0K9cHH3YNxwAofnYHE2cF4jqD4KgB6zapAhqpAhTFALA9oAB3fQNABnxfDW9fDV4N7wLhAnXvAtQHDxa3UVDxchgg"
		. "VInB6OqGcQg0wwQezwRgAGADZhKPTAEIRRBxT0INheDAD4Wm+6BtXwnYQXs+BEGoICRO9U1gWdVrieEAa40FQvNwBVBZxKgA6zIPt0UQg+AOD9Ks"
		. "wFpQU7YAZg8WvpKokl7oEQJmwegGBBEE0YCDffwDfhDIx0X4cDsA6z8BUwoli0X4SJhEGA+3ROB8DgtEicITXw/gW2340AT4AHkGuyVa9Qs="
		static Code := false
		if ((A_PtrSize * 8) != 64) {
			Throw Exception("_LoadLib64Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 4280, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 11280, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			DecompressedSize := 0
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 11280, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			OldProtect := 0
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 11280, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "bEmptyObjectsAsArrays": 16, "bEscapeUnicode": 32, "bNullsAsStrings": 48, "dumps": 64, "fnCastString": 2672, "fnGetObj": 2688, "loads": 2704, "objFalse": 7728, "objNull": 7744, "objTrue": 7760} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}
	_LoadLib() {
		return A_PtrSize = 4 ? this._LoadLib32Bit() : this._LoadLib64Bit()
	}

	Dump(obj, pretty := 0)
	{
		this._init()
		if (!IsObject(obj))
			throw Exception("Input must be object")
		size := 0
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr", 0, "Int*", size
		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
		VarSetCapacity(buf, size*2+2, 0)
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr*", &buf, "Int*", size
		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
		return StrGet(&buf, size, "UTF-16")
	}

	Load(ByRef json)
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

