#Persistent
#Include %A_ScriptDir%\..\VMR.ahk
#Include <Yunit\Yunit>
#Include <Yunit\JUnit>

global vm, tester:= Yunit.Use(YunitJUnit)

tester.Test(VMR_Test)
FileDelete, VMR_test.xml
FileMove, junit.xml, VMR_test.xml
FileDelete, temp.xml
sleep 2000
ExitApp

class VMR_Test {
    __New(){
        vm := (new VMR(A_Args[1])).login()
        FileAppend, % "VBVMR_Login: " VBVMR.FUNC_ADDR.Login "`n", *
        vm.command.save(A_ScriptDir "\temp.xml")
    }

    __Delete(){
        vm.command.load(A_ScriptDir "\temp.xml")
        Sleep, 1000
    }

    Begin(){
        vm.command.reset()
        Sleep, 1000
    }

    VMType(){
        Yunit.Assert(vm.getType())
    }
    
    class Bus_Strip_Tests{
        __New(){
            vm.command.save(A_ScriptDir "\temp.xml")
        }
    
        __Delete(){
            vm.command.load(A_ScriptDir "\temp.xml")
            Sleep, 1000
        }
        
        BusGain(){ ; test edge-case param
            vm.bus[1].gain:= 3.7
            Sleep, 200
            Yunit.Assert(3.7 = vm.bus[1].gain, "Setting/Getting float bus/strip params failed: gain = " vm.bus[1].gain)        
        }

        BusGainPercentage(){ ; test gain percentage
            vm.bus[1].gain:= 3.7
            Sleep, 200
            Yunit.Assert(153.16 = vm.bus[1].getGainPercentage(), "Setting/Getting float bus/strip params failed: gain percentage = " vm.bus[1].getGainPercentage())        
        }

        BusLimit(){ ; tests generic params
            vm.strip[1].limit:= 5.4
            Sleep, 200
            Yunit.Assert(5.4 = vm.strip[1].limit, "Setting/Getting float bus/strip params failed: limit = " vm.strip[1].limit)
        }
        
        BusMute(){ ; test edge-case param
            vm.bus[1].mute:= 1
            Sleep, 200
            Yunit.Assert(1.0 = vm.bus[1].mute, "Setting/Getting float bus/strip params failed: mute = " vm.bus[1].mute)
        }

        StripLabel(){ ; test string params
            vm.Strip[1].Label:= "set by yunit"
            Sleep, 200
            Yunit.Assert("set by yunit" = vm.strip[1].Label, "Setting/Getting string bus/strip params failed: Label = " vm.bus[1].Label)
        }

        StripColor(){ ;test 2-d params
            vm.Strip[1].Color_x:= -0.2
            vm.Strip[1].Color_y:= 0.3
            Sleep, 200
            Yunit.Assert(-0.2 = vm.Strip[1].Color_x && 0.3 = vm.Strip[1].Color_y, "Setting/Getting string bus/strip params failed: color_x,color_y = " vm.Strip[1].color_x "," vm.Strip[1].color_y)
        }
    }
}