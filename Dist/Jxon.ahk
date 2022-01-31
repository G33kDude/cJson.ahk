;
; Jxon wrapper functions, for implicit include in scripts and interface
; compatibility with other JSON libraries.
;

#Include %A_LineFile%\..\JSON.ahk

Jxon_Load(ByRef _json)
{
    return JSON.Load(_json)
}

Jxon_Dump(obj, pretty := 0)
{
    return JSON.Dump(obj, pretty)
}
