#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_LineFile%

; Include the compiler
#Include %A_LineFile%\..\Src\Lib\MCLib.ahk\MCLib.ahk

; Pull in the C file
c := FileOpen("Src\cjson.c", "r").Read()

; Pull in the AHK file
ahk := FileOpen("Src\cJson.ahk", "r").Read()

; Replace inline compilation with pre-compiled machine code
mcode := MCLib.AHKFromC(c)
ahk := RegExReplace(ahk, "`a); MAGIC_STRING\R.+", "this.lib := MCLib.FromString(" mcode ")")

; Replace the MCLib include with the MCLib redistributable
ahk := RegExReplace(ahk, "m)^#Include.+MCLib.ahk$", FileOpen("Src\Lib\MCLib.ahk\MCLibRedist.ahk", "r").Read())

; Save to the Dist folder
FileOpen("Dist\cJson.ahk", "w").Write(ahk)
