#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_LineFile%\..

; Include the compiler
#Include %A_LineFile%\..\Src\Lib\MCLib.ahk\MCL.ahk

; Pull in the C file
c := FileOpen("Src\cjson.c", "r").Read()

; Pull in the AHK file
ahk := FileOpen("Src\cJson.ahk", "r").Read()

; Compile the C code and generate a standalone loader
MCL.CompilerSuffix += " -O3"
mcode := MCL.StandaloneAHKFromC(c,, "_LoadLib")

; Indent the generated standalone loader
mcode := RegExReplace(RegExReplace(mcode, "`am)^\.", "`t."), "`am)^", "`t")

; Replace the inline compilation with the standalone loader
ahk := RegExReplace(ahk, "sm)^[ \t]*_LoadLib().+?\R\s*}", mcode)

; Remove the MCLib include
ahk := RegExReplace(ahk, "m)^\s+#Include.+MCL.ahk$", "")

; Update the version string to indicate it's a built version
ahk := RegExReplace(ahk, "m)^\s*static version.+\K-dev", "-built")

; Save to the Dist folder
FileCreateDir, Dist
FileOpen("Dist\cJson.ahk", "w").Write(ahk)

; Test the build
Run, %A_LineFile%\..\Tests\!TestDist.ahk
