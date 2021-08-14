;
; cJson.ahk 0.3.0-git-built
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
	static version := "0.3.0-git-built"

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

	_LoadLib32Bit() {
		static CodeBase64 := ""
		. "XbYAVYnlU4HshAAAAACLRQiLEIsARRyLADnCD4QipACIx0X0ACgA6wA4g30MAHQhiwBF9AWUFAAADwC2GItFDIsAjQBIAotVDIkKZgAPvtNmiRDr"
		. "DUiLRRAAKlABAA6JMBCDRfQAEAViAIQIwHW5AMKZiUXAiIlVxAFCRCQIAIwJAAwEjQATBCTo4SgZAAACaRQLXscAFCIADFy4AZfpuQWgAADGRfMC"
		. "uVAAkwAIi0AQOcJ1R6EAEwHHRewCuykCHAAMi0XsweAEASDQiUXMiwACQAgAi1Xsg8IBOdAAD5TAiEXzg0UA7AGAffMAdAuhhCJF7HzGgkUkAguI"
		. "B7tbASYFu3sClImJTokYjE3HReiCTizQBIOpAT7oBD7Ig6B96AB+TpNyLI1yJRMTIA0TD7YAYPABQITAD4SfAYM5QEAYOUXofXykposMRchARIBm"
		. "uIlVvKWNZriBZkYYhGYXDxNM6dzCRMgT6cqEk0CiHIAhD42fwpLky5Lo5AWl6JLkAAJFDMSSocQssIlVtM0ssMEslJIXmJMryhfrHIMTYItVEIlU"
		. "wBHACVTUJAQBEUHWpDp0a0IawAyD+AF1HoECThxk2xbAjpACAVADCgYoD4VSgnXIQOZFFCB1VcdF4ItS4AU6rqhS4AACRQyCUukiO6QNwAsYwQsB"
		. "OsgL3AV2s98LxgvcAAElBsMLwxWnFxzBC9jLC9gFubvfC8YL2AABJQbDC2TFCwiLVRyAKBSLVRihwAAQi1UUwAAMDyzACvv//+kvhAYBLFgFdSDk"
		. "B00FQ0BI6SIESAUCdWlAAY1VUqAlBMETQVvUIho3ASIaIItVqItF1CABwI0cAioaD7cSExEa1AEFBgHQDwC3AGaFwHW36YqQImbQCyXQBb4fJb3m"
		. "CtAAASUGJmYuHG3gAxu/hEQK6AABo6PoD4zWIcAoKqRdI6R9P6Sit8CLXfzJw5ABHQIAWeDQV1Yg0YOJDAAQFBHhAMdACKEDx0AM22Ih4AgI4Qgg"
		. "KwhBaYABQWEmg/ggdOWoAQpEdNeoAQ10yagBCYR0u6gBew+FcqJf0cgKx0WgYg5FYeDAAIqowwCswQChhAagBRIAAKyLFUEBx0QkIiDCA0QkHOEA"
		. "jU0AkIlMJBiNTaD1wAAUoAIQoEehA+IX4AAHwxmglOEAiRQk/9DAg+wki0WYAJm/G8O/G6sbfQ+EVCTCIgIKhUDEQwkCg/gidEgKuP8AAOlzEAqN"
		. "HEWAAVThB7Ahaf7/oP+FwHQX8wFT8AFf/wn/Cf8J/wnVADrFB/bOC84FolyUCN/9kgjEAmrJwgKIUywIYwISXxA/IApPFE8KTwpPCtcALHXSEioF"
		. "6VRwEZBZFoUJFjBfDIEsCfIwVbCJNFAIc4sIdQLzA1sPzIXwRRk2KIVwEAWyItSFdJYAeJYAfJQA/yjZ/CiNYJACIimNEQVfKZNfKVYphWgRA0W0"
		. "sHs/8QKvFa8VrxWvFdcAXQ9shLakgvYppQNA2B/hs5BG1x/LCfUB8H7kYwL6tGECalAVLwovCi8KLwrN2R8WKgWhiOkBgAgZILpdxQkuwgkfIBMg"
		. "tBYghgZ1AkQ4D4VjA+81oIsAiUXgkgPgkAPhowQIAOnvBUvkYrQHhrJAHDgFXA+Fqp1NiykHQW/ggAGJVeDSXl07Los5BsAE2wJc3AJdVdsCL9sC"
		. "L9wCL9sCYlXbAgjcAgHbAmbbAgxV3ALT201u2wIK3AKlVdsCctsCDdwCd9sCdBfbAjEe2QJJ2wJ1D4W+EU0+4AOAA7FlEpfpYZ1nMAEAA+DCicLh"
		. "ATobL8R+MNgAOX8iwwKRAkFTAQHQg+gwhQPpgoCpNYP4QH4t2ACIRn8f3wOD6DfVA9TrRcgCYKoDZq8DoQM2V6YDBCkhoUm7M9wBgIN93AMPjhbw"
		. "AXGQqALrJvRfkNzy542WSqICwC7g8IOJTWAGhhJLELAy//z//2ExUkhhAinIcQcM0LuD3OgENxWKB0M3kUQGhASMLXRwd7cVD46xJTjx9BUPj58Q"
		. "AfCqwU8/ifM0iRkFdRTQAgENXzcTAlgwdSMPBGojjisFMMR+dSofZ+tHwQ4w5QBACGvaCmvIABAB2bsKMAP34wEA0YnKi00IiwkAjXECi10IiTMA"
		. "D7cxD7/OicsAwfsfAcgR2oMAwNCD0v+LTQxgiUEIiVFA6WIFVbcAAGaD+C9+GotARQiLAA+3AdA5QH6d6wq4/wAA6SBfBAAAkAhoLg8ghaUAAAAC"
		. "RI1QAgIAHIkQi0UMiwBQDItACGYPbgLAAAbKZg9iwWaQD9aFUACC360BChEARN1YCAAKZscAQAUAx0XUAQCI6wBCi1XUidDB4AACAdABwIlF1AED"
		. "VUgCi1UIiQoBAG+Yg+gwiYVMhQA/2wMFRdTe+QFKMEAI3sEFUgaaL36KDgrDoggNZXQSCA1wRQ+FVQCADcQDDhRUdTEJaNCAAdoAaNPFAGiVFWjG"
		. "RdODJgMhKC11E4AIAYov6x/xCBArdREGGQdAlmSExSjTAgAAncyAnADrUCeLVcwHncORnAEQ2IlFzJgqvcdFIsgBw8dFxIIUE4uEVchIY8iDRcSA"
		. "MADEO0XMfOWAfRDTAHQTg17bRcihQ2FYCOsRhwTJhkQFxVErwVFICItYDACLRdiZid8PrwD4idYPr/EB/gD34Y0MFonKiwBNDIlBCIlRDKTrHYYN"
		. "BXXGFNjQFJGEXAMAuMEs6cCFcaHDB3QPhYVCNMBCNAA3i0XABa4UAAAAD7YAZg++0FFGCjnCdMRUf82BgwxFwEA9hg2EwHW6wYMcCQCLFZAABUAD"
		. "EIlQCKGCAgCLQAIEQwWJFCT/0INU7ASDJSmLJWaFJbxRhSW8BbOaJejN2IPcRbyAJYYNiyWIhyWCAjeDJYECiyWSRRWDJW51CH/HRUIG6zSLRSi4"
		. "BblTEgdCEutYXewRuOARZgbgEb3nEYyf5xFCAeMRQQHqEesFIgsAjWX0W15fXcMDQQIFACJVbmtubwB3bl9PYmplYxB0XwAiBQF0cnUAZQBmYWxz"
		. "ZQAQbnVsbCcFVmFsAHVlXwAwMTIzADQ1Njc4OUFCAENERUYAAFWJAOVTg+xUx0X0AyELohiLQBSNVfQAiVQkFMdEJBCLwQLgAAyBYY1VDMACPgjA"
		. "AQCfoAXgaUMWGMe0ReQCBUVhM8AA7MMAwvCDChCJReRgAkEIoSQMGItV9MAIIKQLChzkABjhAI1N5IneTIMPwQyBD8QDCOEAIBAaBCcPJKALAzYJ"
		. "dRsHYAHgkuELCItVEIsiUoUEBOtoxgQDdZZcwQQimLsALH+5gQpAOcMZ0XwVBgM9AUACgInQg9j/faIuYDWNVeDhHongHiHhOwQk6KEABIXAIHQR"
		. "i03ghgaJAQCJUQSQi138yQjDkJDgKoPsWGbIx0Xuoz1F8EAsYDwCAMB6us3MzMyJQMj34sHqA2aKKQjBicogDsAwg20A9AGJwotF9GYwiVRFxmAH"
		. "wgX34gEgBegDiUUMg31ADAB1uY1VQAP0qAHAASAFEAATCMIiwYMTKP7//5CAEGM70GDHRfgCXBogpMEvAYAVRfjB4AQB0AiJRdgBAkAYOUWw+A+N"
		. "ROAzABbOoQQC2OEZRfTGRfMAQIN99AB5ByABARj3XfSgOIMY9LpnKGZmZoAY6uAS+AIAicvB+x8p2ImqwvEZ7OIZ7OEZpi4HQMH5H4nKKUAR9AEB"
		. "DXWlgH3zAHQGDoEGQQbHREWmLR3gTqaAAYAdwATQxkUG6yBLwk2LReSNFEGgANAB0A+3YMTkpI0MgS0ByINzdaBygQgEAGaFwHUZRQKKDEYCBiAK"
		. "AestbgUGdKD+bAV0B4NF5AAB64eQgH3rAAwPhKFh4R9V2IkQkrjRLenKJC5AHCEVDIyj4gDDFNTGReNVgAvcgwvcggXUhAvc348LCAKFCyMBigvj"
		. "ggu8AheBC7wCgQvcgwvjAHSCD0oL6xiDRfjyeIRAEFIL1/3//zJIn7osvz1iAHJDYCPoBYEP0N0A3V2QLtizAbIOGMdF4GMAIhuNRehHUCcwAZEH"
		. "oYAGA1AYHIsVoQAdQSFwTCQY+I1N2AVBInkMQeVIFUE/IQs/Cz8LwAExEgAxBIv6AAA6iSBJnwufC58LnwuvnwufC58LNjtkwAnmkgpn0jY0CldJ"
		. "fBg1AStMfdBujUWoaEr2kEBUDwTrN4FDdCCLVbCAi0XwAcCNHLBqSgx0kQxxkRNmgJgNl6EhgGzwIBCBbPABBQM1Zie383I+ZHzTE+yDAH3sAHlt"
		. "i03sk49Bj0G4MBAEKdCqTs6+vgOmQcIFdaPhAsECwUBBvi0A61vPBs8Gl19VrwavBqWEI+s+QhPQJ41VvtZW6L8TvxPZshPoAXwDJhSp6TWzKhoY"
		. "kgYXegUQgyIA6Ux2A1NGlgXpZBIBCFEDbSJ1VqIDFK0DXK4AHQkfBhMGEB4G/rNiPRMGXB8GHwYfBmgC6a7r8gQZBpwZBggfBh8GHwahZgJiAOlM"
		. "HgY6GQYeDB8GHwYfBmYCZgDptuoCLxkG2CMwEwYKHwaHHwYfBmYCbgDpiB4GenYZBg0fBh8GHwZmAnKoAOkmHgYUGQYJHwbHHwYfBmYCdADpNXEX"
		. "BmayI0wTBh9+0Ie0AH68fm/fBt8G1QZuAnVtAvGTBQ+3wNCfAZuBAmCR9ZFQbNE8K3IEsFN4BKCkiA+3Eu87g0UIwbzDsAAPtwBmhcAPhQCN/P//"
		. "g30MAAB0FItFDIsAjQBIAotVDIkKZgDHACIA6w2LRRIQAExQAQAciRCQAMnDkJBVieVTAIPsJItFCGaJAEXYx0XwzhQAIADHRfgAAADrLQAPt0XY"
		. "g+APiQDCi0XwAdAPtgAAZg++0ItF+CBmiVRF6AE4ZsEE6AQBcINF+AGDAH34A37Nx0X0CgMBOzMChRyLRfQgD7dcRegKjYnaiGaJEAyNg230AEEg"
		. "9AB5x7gBe4tdAvwBnpA="
		static Code := false
		if ((A_PtrSize * 8) != 32) {
			Throw Exception("_LoadLib32Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 3710, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 8408, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 8408, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			for k, Offset in [47, 97, 635, 685, 966, 1016, 1061, 1111, 1156, 1206, 1453, 1503, 1840, 1851, 2496, 2507, 4831, 4886, 4907, 4918, 4929, 4982, 5037, 5058, 5069, 5080, 5129, 5181, 5202, 5213, 5224, 6494, 6505, 6680, 6691, 8265] {
				Old := NumGet(pCode + 0, Offset, "Ptr")
				NumPut(Old + pCode, pCode + 0, Offset, "Ptr")
			}
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 8408, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"dumps": 0, "fnCastString": 1664, "fnGetObj": 1668, "loads": 1672, "objFalse": 5256, "objNull": 5260, "objTrue": 5264} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}
	_LoadLib64Bit() {
		static CodeBase64 := ""
		. "j7UAVUiJ5UiB7KAAAAAASIlNEEgAiVUYTIlFIEwAiU0oSItFEEgCiwAIRThIiwBIIDnCD4S8AJjHRQL8ABQA60dIg30AGAB0LYtF/EgAmEiNFeIa"
		. "AABQRA+2BAFgGAFgjQBIAkiLVRhIiQAKZkEPvtBmiQgQ6w8ANiCLAI0EUAEBEIkQg0X8GgEFP6IAPwE+hMB1AqUCeolFwEiLTQIgAkONRcBJicjA"
		. "SInB6JsgAKkCeUIZEGjHACIADmW4AQGv6b4GAADGRST7AAPWUDADB0AgCQBsdVsADAHHRfSFAmw1hBAYi0X0gExAweAFSAHQgEbQE4ALgAFQEIAL"
		. "g8ABAwANAImUwIhF+4MARfQBgH37AHSaEwEZYwEUBS18sgNWQiyCDwhBuFsBMQaYQbh7gbgPYESJj1/Ix0XwgmCeBQIZhE0C8IlNyIN98AB+Wl4Z"
		. "jCwPLBkXII8LDwK2gDrwAYTAD4Sw6AEAAIEgxjowAUPcjYkBNStnQAHIwA+Be0q4iHu4hHusHkUUHJlUFOn+Q1IJFenqwASNyic4widBgsdF7Myv"
		. "0uzCnzMY8a/swK/DD6zzF8qvBTWwCDWwBDWU1x2eSSxMGusbxhTTxBPEEmsf2xI6vn0BD4CLQBiD+AF1YTCLgBAKEAqAGen/AmIw4eMEBg+FlOBD"
		. "YwUAh4BFKHVpx0XorC6y6KImxha/Lq8u6KAuzeMHhuAHpS7peaQQow6qMKEO5KwO5KIGVb8OrbAO5KAO4wcVqQ4Dqg4qOKEO4KwO4KIG5RXbvw6v"
		. "DuCgDuMHpeAHpg6CjScsTItNKEygBQFiCYtNOEiJTCQpoLdNMAEBIGE0Fvow///pWyQGYjQFdVYfZRbLORvBOTBJBQJEdXpCBY1VkAEESlHgtMdF"
		. "3CIcRSMcKyHgB5iLRdygFAHAGEyNBKAaDRxBD7c6EPMb3CABpwfAmQ+3AABmhcB1pOmqlaJ12Gwp2GIhnhR/Ke1vDdhgKeMHXuAHq3WqIO41gBwf"
		. "mawL8KALSI7Bv1gPjEtAL0zAXUTAfSNfwErYSIHE4fRdw26QBwDhAhkAVYD7ojmNSKwkgIL8jcDCAJVayKIPhWEAAA0UtQBI2MdACBIXYAmFogLR"
		. "CT5Q0AnTAPFAdQGRGoP4iCB01S0BCnTCLQGIDXSvLQEJdJwtAeB7D4UpA3IJrwehB4jHRVCSEMdFWHQAwmByAIsFA/9wFrEwEZF9BfX+0ADHRCQi"
		. "QFMCRCQ4ggCNVVEwMVQkMIAAUIEAKEWQASDQEQBBufEBQQViFrqiAonBQf/S8bKPiUVozxDPEM8QzxCHzxDPECcBfQ+EwoI4FWkBhdB3rF4Bg/gi"
		. "CHQKuCAQ/+kWEQ+BDvGTYAfCHuj3/f8g/4XAdCIDAvUQfw8W7wzvDO8M7wzvDCcBOr0VCnQPCAkIUijHCzrDCy20AziyA3FOjQMsRWj9JDuykAF/"
		. "Go8Njw2PDY8NY48NJwEsdR1vB2MH6ZrC0AuQjh3VDGoPnxALnBCwOQm2OYtVaEhoiVAIA60tygOTBVv4D4Vl4mg/BfQzoqRwAE74dABSQhAzw/v5"
		. "M7Wz0QD/M41VwKbzM/D/Mwv/M+AZ2PAzcMeFrP8wAYECHxofGh8aHxofGh8asScBXQ+Esb2fNN5HUM0oJ8cwWycnxQ0xAuImrIuVcQxQDXBEJ50w"
		. "GH8vDS8NLw0vDS8NLw1JJyTLbwdjB4PTFumqQFC+J3JdZQ3uDH8ivye5J3CNtyexygMUSA+FExLKYz8FyxBIiYXy5oUFlQnT51AIZwcIAOlZKgQP"
		. "G3W0CzLvB/hcOA+F9q9j7wfVCnU09yABkgdxAolCCJJ9HwS0PN7H6gVUB28EYgRcbwRlBLKAbwT4L28EYgQvbwTlZQQ5bwT4Ym8E5BRvBAFjBMa2"
		. "AOnyAgAASIuFBMAAAWAAD7cAZqCD+GZ1NACQoAGQQI1QAkiJlQEoZjjHAAwIpAJkBDSJEFTpqxCMbhSMCheMZFUQRnIURg0XRh0QRnQlFEYJFyPW"
		. "AQ8jdQ88hYUKC4sZBDGAKwAAmMeFnIACAQDpOwMZgwENACPB4ASJwoUUI4IZCjEvfkINCTl/Di8HH4IdBw8B0IPoMjCJJ+mugg2LIEB+oj8NCUZ/"
		. "LBoqNwkVVOtcjQ9gTxRmXBRXEUoUCrj/AADpZQhFl1ODglABg72BAQMAD464/v//SINRQhAC6zrDDyXJDxCoSI1Kxw8IRnxIQHwKjQMmEpBcIg+F"
		. "kKL7gBaLhciCBUhGDhgpyEgCLcMFQAhIWIPoBIt51S64Qn6HIgfPYi10Ls58D44EDAVPCjkPj/UEvUGSmIFBAxtBIgAeFMUCmEjHQEBAUBl1IsMN"
		. "50FJ2KuKBjB1ITjTCk1+IXAOMA+OidACOX8IdutMhihQCEiJANBIweACSAHQwEgBwEmJwGkMIDUUi5VjDAqgB0gPv1DATAHAYA/QBQiJSwAITmYf"
		. "bg5+jiVMAxAGAACQ7QMuD4UG5tgbSD5mD+/A8hhIDyrBFGEC8g8RK+BABjEFwDOUxDPrbCSLlWEBidDAGwHQ2AHAiUID+BuYgHcCDBvgC+AA0uAA"
		. "IghmDyggyPIPXspmDhBAYAjyD1jBbBCsIBeZD0iOaso/wwJldC4FcEUPhfgbm+EOYwUUg6dE/yMFAMaFkxNUSiEjAwGVDusybQYrjHUfrgk7Wi9+"
		. "E09DKQRD6gNha4yktOs6bIuVYQGGN0E6UyE3RA8hPGEGvw6gDqDHhYgRBEXHhYSlDhyLlZehAkhGwQGDAgQBi8IAQjtiDHzWgL1CH3TWKqlCwC/J"
		. "oEaNoQYgRikqROsoJwVIAzUPKrHiC/IPWW1J+R0k2DqCi1JESJhID685OOTrODoDBXW/BrAGoQNLvwa6Bgy3IgMAU1NRQQ98+HQPhbeSE4AZlRNS"
		. "i7IAkAmNFX0BEAMPtgQQZg++o0EKmAM5wnTkHvv/LS+YZqEE8BYWBSsUBYTAzHWXFwrhghXmgwTXSIwF1BIBw02LBcbRAFCJwf/S0wyDf4T4iGYP"
		. "hQFUx0V8ogzQTItFfFIHurACfwyNewwzfwx3DEV8AbUEVm60BBAMoBwMBB4M8lvUBBMM5IIBFgzBLy74UG4PhaUSDHgSDEnoi0V4Ugf+oR0fDBMM"
		. "sgcSDOt07wvlC3jgC62DBLWEBOALo+wLVadwleQLQ+oLNeoL6wVSBxBIgcQwYA9dw5AfBwCkJA8ADwACACJVbgBrbm93bl9PYoBqZWN0XwAihQAA"
		. "dHJ1ZQBmYWyAc2UAbnVsbJcCAFZhbHVlXwAwADEyMzQ1Njc4gDlBQkNERUbzBABVSInlSIPEgABIiU0QSIlVGIBMiUUgx0X8A04GRcBMEVYoSI1N"
		. "GABIjVX8SIlUJCAox0QkIPEBQbkhgURJici60wJNEED/0EjHReDSAMcUReh0APC0BCBIiRxF4OAAU4SiBUyLUKAwi0X8SBAFQNMCKEQkOIUAMIIA"
		. "jVV+4EYHgIhAB6IHYhVxkU0wEEH/0tEFMyEJdX4eogaBksIYYAbkANEY62JgpwIDdVO1AQEMgLBIOdB9QGnUArrwGqJ/Qhs50H/gTkXxD0zYSXCD"
		. "Uwfo0zADhQjAdA+gAdhIi1UFUANSMAYQkEiD7GaAGB7zFexg8RXkFWajshEQBYlF+KAWFIAEAItNGInKuM3MBMzMME7CSMHoICCJwsHqAyZZKcEA"
		. "icqJ0IPAMIMgbfwBicIxE5hmUIlURcBRBMKKA8EA6AOJRRiDfRj4AHWpIAsQArACUI6xjptgChgMAbCs4ArEYAkpxfQKcP8gAOmuQlGRG0RQGGMF"
		. "weAFcQWJNEXQ8QBjEAbRAUAwwEg5wg+NmpAesA4XoBpgAaABQAAFRfDGAEXvAEiDffAABHkIoAABSPdd8AfwEEEQQAnwSLpnZoEDAEiJyEj36oKa"
		. "BPgCQCZJwfg/TAwpwMELyZtIKcFI9bYR6LIR6LMRAJf/BPQEkEjB+T9gA0gpsQsC8OIIdYCAfe8ADHQQUQQzBMdERZAaLREokPIANBSJRcAYxkXn"
		. "UEdyLotF4IuhQrGwReEBD7cQJAGTsepAIwHIg0d1b68CwABmhcB1HnkB8AJ1dQEGUAYBEIFfA9ABdAYiXwNyAQqDReABBOlmcCuQgH3nAEgPhPbF"
		. "N4tVsAsQsrjRN+kBUAAKGzgBGwyMyrMCpRrIxkXf1XAO2HMO2OYGyHUOIgEffw6uAnUOdwEXC3SzAHUGxkXfAes6AItF2EiYSI0UAABIi0XISAHQ"
		. "AA+3AGaFwHQiBQm4GAdcCoNF2AEA6Wb///+QgH0Q3wB0EgA8IEiLAFXQSIkQuAEAAAAA6yCDRfwBQItF/Ehj0AA2EABIi0AgSDnCD0CMO/3//7gA"
		. "QAAASIPEcF3DVUhAieVIgeyQARCJAE0QSIlVGEjHREXgAiDHRegEB/AVAQdmABcFAYcQ8g+AEADyDxFF6AAaKsAEIsgEB9ACB41FYOBIiUXAAA4B"
		. "jEgAiwXU5v//SIugAEyLUDAADcYBDRDHRCRAAzREJDgFAgSLAD6JVCQwSKiNVcABBCiADCABIFRBuYEPQYJbugIViYDBQf/SSIHEAVwYXcOQBgCC"
		. "Z4PsQGEFZkyJRSAAXABkxzhF/BQCMgGGACBF8ABIg33wAA+Jm4GCCk3wSLpnZgMAAEiJyEj36kiJANBIwfgCSYnIQEnB+D9MKQBJwgmCCeACAMRI"
		. "AcBIgCnBSInKuDCAHwAp0INt/AGJwoEBuJhmiVRFwJgokEjB+T8AHEgpgNY5hUKFesBywRBDEMdEQEXALQDpgLsmiRDQg8AwOyZ1gMckRexBXOtQ"
		. "wAMYAFx0NgFnQhOBGQEAFuxhggJMjQQCwqjAVo0GSIACwXIKQQ+3ECBmiRDrD8GniwAIjVABAQKJEINFTOwBFBIGuXWOxalAW0d4xHcgyXcDJhxP"
		. "H2aAxwAiAOkIBEJ9MYkf6fQDQ4JBGoP4KCJ1ZsMQGdIQXABbzi+cHJCDF4ocfIocXFO/HMoF6R1QDglKDggHXw5fDsYFYgDpqgLtTw6WYwJEDgxf"
		. "Dl8OxgVQZgDpN1AOI0oOCodfDl8OxgVuAOnEAJDtTQ6wYwJEDg1fDl8OxgVQcgDpUVAOPUoOCYdfDl8OxgV0AOneQ6ONSg7KxKVDDh9+DYcBuH5+"
		. "fP8P8A/TBXXQBVlDDQ+34ZUh2xiAnYmoweiMQZE0gwkejwkLwADABhJRjkiDRRADIZQiGIXAD4X8+6uA0LgSIq8SkICRIMnNF+aRwKilzYkAzI0F"
		. "jR7zoAugqMDOwqcyD7egRRCD4A8htYuAq4GgnLYAZg++0JZZwugRAmbB6AQRBNF7AIN9/AN+yMdFIvhgPADrP7MKJYsARfhImEQPt0Rj4HduC0SJ"
		. "wr8P4FZtwvjQBPgAebslVVUM"
		static Code := false
		if ((A_PtrSize * 8) != 64) {
			Throw Exception("_LoadLib64Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 4050, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 10368, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 10368, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 10368, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"dumps": 0, "fnCastString": 1984, "fnGetObj": 2000, "loads": 2016, "objFalse": 6912, "objNull": 6928, "objTrue": 6944} {
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

