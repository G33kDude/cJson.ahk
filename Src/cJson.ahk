
class cJson
{
	static version := "0.1.0-git-dev"

	_init()
	{
		if (this.lib)
			return

		; MAGIC_STRING
		this.lib := MCL.FromC(FileOpen(A_LineFile "\..\cJson.c", "r").Read())

		; Populate globals
		NumPut(&this.True, this.lib.objTrue+0, "UPtr")
		NumPut(&this.False, this.lib.objFalse+0, "UPtr")
		NumPut(&this.Null, this.lib.objNull+0, "UPtr")

		this.pfnPush := RegisterCallback(this._Push, "Fast CDecl",, &this)
		this.pfnGetObj := RegisterCallback(this._GetObj, "Fast CDecl",, &this)
	}

	_GetObj()
	{
		type := this, this := Object(A_EventInfo)
		return Object(Object())
	}

	_Push(typeObject, value, key)
	{
		pObject := this, this := Object(A_EventInfo)
		value := this._Value(value)

		if (typeObject == 4)
			ObjPush(Object(pObject), value)
		else if (typeObject == 5)
			ObjRawSet(Object(pObject), this._Value(key), value)

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

	Loads(ByRef json)
	{
		this._init()

		_json := " " json ; Prefix with a space to provide room for BSTR prefixes
		VarSetCapacity(pJson, A_PtrSize)
		NumPut(&_json, &pJson, 0, "Ptr")

		VarSetCapacity(pResult, 24)

		if (r := DllCall(this.lib.loads, "Ptr", this.pfnPush, "Ptr", this.pfnGetObj
			, "Ptr", &pJson, "Ptr", &pResult , "CDecl Int")) || ErrorLevel
		{
			throw Exception("Failed to parse JSON (" r "," ErrorLevel ")", -1
			, Format("Unexpected character at position {}: '{}'"
			, (NumGet(pJson)-&_json)//2, Chr(NumGet(NumGet(pJson), "short"))))
		}

		return this._Value(&pResult)
	}

	_Value(value)
	{
		; return ComObject(0x400C, value)[]
		type := NumGet(value+0, "UShort")
		switch (type)
		{
			case 20: return NumGet(value+A_PtrSize, "UInt64") ; VT_I8
			case 5: return NumGet(value+A_PtrSize, "Double") ; VT_R8
			case 8: return StrGet(NumGet(value+A_PtrSize, "Ptr"), "UTF-16") ; VT_BSTR
			case 9: return Object(NumGet(value+A_PtrSize, "Ptr")), ObjRelease(NumGet(value+A_PtrSize, "Ptr")) ; VT_DISPATCH
			case 11: return NumGet(value+A_PtrSize, "Int64") ? this.true : this.false ; VT_BOOL
			case 1: return this.null ; VT_NULL
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
}

#Include %A_LineFile%\..\Lib\MCLib.ahk\MCL.ahk
