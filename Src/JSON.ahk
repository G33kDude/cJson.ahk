#Requires AutoHotkey v2.0

class JSON
{
	static version := "1.6.0-git-dev"

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

	static _LoadLib() {
		; MCL.CompilerSuffix .= " -O3" ; Gotta go fast
		return MCL.FromC('#include "dumps.c"`n#include "loads.c"')
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

#Include %A_LineFile%\..\Lib\MCL.ahk\MCL.ahk
