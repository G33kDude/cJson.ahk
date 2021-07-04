
#Include %A_LineFile%\..\Lib\MCLib.ahk\MCLib.ahk

class cJson
{
	_init()
	{
		if (this.lib)
			return

		c := FileOpen(A_LineFile "\..\cJson.c", "r").Read()
		this.lib := MCLib.FromC(c)

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
		VarSetCapacity(buf, size*2+1, 0)
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr*", &buf, "Int*", size
		, "Ptr", &this.True, "Ptr", &this.False, "Ptr", &this.Null, "CDecl Ptr")
		return StrGet(&buf, size*2, "UTF-16")
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
}
