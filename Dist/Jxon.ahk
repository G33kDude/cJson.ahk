;
; Jxon wrapper functions, for implicit include in scripts and interface
; compatibility with other JSON libraries.
;

#Include JSON.ahk

Jxon_Load(&_json) => JSON.Load(&_json)
Jxon_Dump(obj, pretty := 0) => JSON.Dump(obj, pretty)
