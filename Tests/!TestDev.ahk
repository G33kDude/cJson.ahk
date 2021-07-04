#NoEnv
SetBatchLines, -1

; Include Yunit files
#include %A_LineFile%/../Lib/Yunit
#Include Yunit.ahk
#Include Window.ahk
#Include StdOut.ahk
#Include JUnit.ahk
#Include OutputDebug.ahk

; Include dev cJson
#Include %A_LineFile%/../../Src/cJson.ahk

; Include test suites
#Include %A_LineFile%\..\
#Include DumpsTestSuite.ahk
#Include LoadsTestSuite.ahk

Yunit.Use(YunitStdOut, YunitWindow, YunitOutputDebug).Test(LoadsTestSuite, DumpsTestSuite)
