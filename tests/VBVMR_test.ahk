#Persistent
#Include %A_ScriptDir%\..\VMR.ahk
#Include <Yunit\Yunit>
#Include <Yunit\JUnit>

global vm, tester:= Yunit.Use(YunitJUnit)

tester.Test(VBVMR_Test)
FileMove, junit.xml, VBVMR_test.xml
sleep 2000
ExitApp

class VBVMR_Test {
    __New(){
        vm := (new VMR(A_Args[1])).login()
        FileAppend, % "VBVMR_Login: " VBVMR.FUNC_ADDR.Login "`n", *
        VBVMR.SetParameterString("command","Save", A_ScriptDir "\temp.xml")
    }

    Begin(){
        VBVMR.SetParameterFloat("command","reset",1)
        Sleep, 1000
    }

    SetParameterFloat(){
        VBVMR.SetParameterFloat("Bus[1]","gain",val)
    }

    GetParameterFloat(){
        VBVMR.GetParameterFloat("Strip[1]","A1")
    }

    SetParameterString(){
        VBVMR.SetParameterFloat("Strip[1]","label", val)
    }

    __Delete(){
        VBVMR.SetParameterString("command","Load", A_ScriptDir "\temp.xml")
        Sleep, 1000
    }
}

