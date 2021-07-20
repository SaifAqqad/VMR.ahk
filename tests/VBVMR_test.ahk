#Persistent
#Include %A_ScriptDir%\..\VMR.ahk
#Include <Yunit\Yunit>
#Include <Yunit\JUnit>

global vm, tester:= Yunit.Use(YunitJUnit)

tester.Test(VBVMR_Test)
FileDelete, VBVMR_test.xml
FileMove, junit.xml, VBVMR_test.xml
FileDelete, temp.xml
sleep 2000
ExitApp

class VBVMR_Test {
    __New(){
        vm := (new VMR(A_Args[1])).login()
        FileAppend, % "VBVMR_Login: " VBVMR.FUNC_ADDR.Login "`n", *
        VBVMR.SetParameterString("command","Save", A_ScriptDir "\temp.xml")
        VBVMR.SetParameterFloat("command","reset",1)
    }

    SetParameterFloat(){
        VBVMR.SetParameterFloat("Bus[1]","gain", 1.0)
        Sleep, 1000
    }

    GetParameterFloat(){
        VBVMR.GetParameterFloat("Strip[1]","A1")
        Sleep, 1000
    }

    SetParameterString(){
        VBVMR.SetParameterString("Strip[1]", "Label", "Tests")
        Sleep, 1000
    }

    __Delete(){
        VBVMR.SetParameterString("command","Load", A_ScriptDir "\temp.xml")
        Sleep, 1000
    }
}

