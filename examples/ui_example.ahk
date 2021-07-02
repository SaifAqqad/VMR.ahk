#Include, %A_ScriptDir%\..\VMR.ahk
SetBatchLines, 20ms

Global vm, GUI_hwnd, is_win_pos_changing:=0

vm := new VMR().login()
showUI()
vm.onUpdateLevels:= Func("syncLevel") ; register level callback func
vm.onUpdateParameters:= Func("syncParameters") ; register params callback func
OnMessage(0x46, Func("onPosChanging"))

showUI(){
    Global
    Gui, vm:New, +HwndGUI_hwnd, VoiceMeeter Remote UI
    xPos:=10
    Loop % vm.bus.Length() { ; add UI controls for each bus
        ;bus title
        yPos:=0, funcObj:=""
        Gui, Add, Text, x%xPos% y%yPos% w100, Bus[%A_Index%]
        
        ;bus level
        yPos+= 30
        Gui, Add, Progress, x%xPos% y%yPos% w20 h200 Range-72-20 c0x70C399 Background0x2C3D4D vertical Hwndbus_%A_Index%_level
        
        ;bus gain
        yPos+= 220
        Gui, Add, Edit, w50 x%xPos% y%yPos% ReadOnly 
        Gui, Add, UpDown,Hwndbus_%A_Index%_gain Range-60-12 x0
        funcObj:= Func("updateParam").bind("gain", A_Index)
        GuiControl +g, % bus_%A_Index%_gain, % FuncObj

        ;bus mute
        yPos+= 30
        Gui, Add, CheckBox, x%xPos% y%yPos% Hwndbus_%A_Index%_mute, Mute
        funcObj:= Func("updateParam").bind("mute", A_Index)
        GuiControl +g, % bus_%A_Index%_mute, % FuncObj
        
        ;bus device
        if(vm.bus[A_Index].__isPhysical()){ ; make sure the bus is a physical one (eg. 1-3 in banana)
            yPos+= 30
            Gui, Add, DropDownList, x%xPos% y%yPos% Hwndbus_%A_Index%_device
            funcObj:= Func("updateParam").bind("device", A_Index)
            GuiControl +g, % bus_%A_Index%_device, % FuncObj
            refreshDevices(A_Index)
        }

        xPos+=150
    }
    syncParameters() ; get initial values for gui controls
    Gui, Show, H350, VoiceMeeter Remote UI
}

; update vm bus parameters when they change on the AHK UI
updateParam(param, index){
    GuiControlGet, val,,% bus_%index%_%param%
    if(param == "device"){
        RegExMatch(val, "iO)(?<driver>\w+): (?<name>.+)", match)
        if(match)
            vm.bus[index].device[match.driver]:= match.name
        else
            vm.bus[index].device:= ""
    }else{
        vm.bus[index][param]:= val
    }
    SetTimer, syncParameters, -500 ; make sure params are in sync
}

; sync AHK UI controls with vm bus parameters
syncParameters(){
    Loop % vm.bus.Length() {
        GuiControl,, % bus_%A_Index%_gain, % vm.bus[A_Index].gain
        GuiControl,, % bus_%A_Index%_mute, % Format("{:i}", vm.bus[A_Index].mute) ; convert 0.0/1.0 to 0/1
        if(vm.bus[A_Index].__isPhysical())
            refreshDevices(A_Index)
    }
}

; sync level meters with vm bus levels
syncLevel(){
    if(is_win_pos_changing) ;dont update levels if the window is changing its position
        return
    Loop % vm.bus.Length() {
        GuiControl,, % bus_%A_Index%_level, % Max(vm.bus[A_Index].level*) ; get peak level for the bus
    }
}

; clears the bus's drop-down and reinserts the devices
refreshDevices(index){
    elems:="| |" ; extra empty element for removing the device
    preSelected:= vm.bus[index].device ; get the pre-selected device
    for i, device in vm.getBusDevices() {
        elems.= Format("{:U}: {}", device.driver, device.name)
        elems.= device.name == preSelected? "||" : "|" 
    }
    GuiControl,, % bus_%index%_device, % elems
}

vmGuiClose(){
    ExitApp
}

onPosChanging(){
    is_win_pos_changing:=1
    SetTimer, onPosChanged, -50
}

onPosChanged(){
    is_win_pos_changing:=0
}
