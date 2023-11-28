SetWorkingDir A_LineFile '\..\Src'

; Include the compiler
#Include %A_LineFile%\..\Src\Lib\MCL.ahk\MCL.ahk

; Pull in the C file
c := '#include "dumps.c"`n#include "loads.c"'

; Pull in the AHK file
ahk := FileOpen(A_LineFile '\..\Src\JSON.ahk', 'r').Read()

; Compile the C code and generate a standalone loader
; MCL.CompilerSuffix .= ' -O3'
mcode := MCL.StandaloneAHKFromC(c, MCL.Options.OutputBothBit, '_LoadLib')

; Indent the generated standalone loader
mcode := RegExReplace(RegExReplace(mcode, '`am)^\.', '`t.'), '`am)^', '`t')

; Add 'static' to the functions it spat out
mcode := RegExReplace(mcode, 'm)^[ \t]*\K_LoadLib', 'static _LoadLib')

; Replace the inline compilation with the standalone loader
ahk := RegExReplace(ahk, 'sm)^[ \t]*(static\s+)?_LoadLib\(\).+?\R\s*}\R', mcode)

; Remove the MCLib include
ahk := RegExReplace(ahk, 'm)^\s+#Include.+MCL.ahk$', '')

; Update the version string to indicate it's a built version
ahk := RegExReplace(ahk, 'm)^\s*static version.+\K-dev', '-built')
RegExMatch(ahk, 'm)^\s*static version := "\K[^"]+', &version) ; Extract version

; Prepend the LICENSE
license := Trim(FileOpen(A_LineFile '\..\LICENSE', 'r').Read(), ' `t`r`n')
license := StrReplace(license, "`r", "")
RegExMatch(license, "m)^Copyright \(c\).+", &copyright) ; Extract copyright
license := RegExReplace(license, 'm)^Copyright \(c\).+\s+', '') ; Remove copyright
license := RegExReplace(license, 'm)^', '; ') ; Prepend comments
license := RegExReplace(license, 'm)[ \t]+$', '') ; Remove trailing whitespace
ahk := (
';`n'
'; cJson.ahk ' version[0] '`n'
'; ' copyright[0] ' (known also as GeekDude, G33kDude)`n'
'; https://github.com/G33kDude/cJson.ahk`n'
';`n'
license '`n'
';`n'
ahk
)

; Normalize line endings
ahk := RegExReplace(ahk, '`a)\R', '`r`n')

; Save to the Dist folder
DirCreate A_LineFile '\..\Dist'
FileOpen(A_LineFile '\..\Dist\JSON.ahk', 'w').Write(ahk)

; Test the build
Run A_AhkPath '\..\AutoHotkey64.exe ' A_LineFile '\..\Tests\!TestDist.ahk'
Run A_AhkPath '\..\AutoHotkey32.exe ' A_LineFile '\..\Tests\!TestDist.ahk'
