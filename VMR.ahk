global VM_PATH:=, VM_DLL:=
class VMR{
    static VM_TYPE:=, VM_BUSCOUNT:=, VM_STRIPCOUNT:=
    bus:=Array(), strip:=Array()
    
    __New(p_path:=""){
        if(p_path && SubStr(p_path, 0)!="\"){
            p_path.= "\"
        }
        if(A_Is64bitOS){
            VM_PATH := p_path? p_path : "C:\Program Files (x86)\VB\Voicemeeter\"
            VM_DLL := "VoicemeeterRemote64"
        }else{
            VM_PATH := p_path? p_path : "C:\Program Files\VB\Voicemeeter\"
            VM_DLL := "VoicemeeterRemote"
        }
        this.VBVMRDLL := DllCall("LoadLibrary", "str", VM_PATH . VM_DLL . ".dll")
    }
    
    login(){
        errLevel := DllCall(VM_DLL . "\VBVMR_Login")
        if(errLevel<0)
            Throw, Exception("VBVMR_Login returned " . errLevel, -1)
        if(errLevel){
            this.runVoicemeeter()
            sleep, 1000
        }
        OnExit(ObjBindMethod(this, "__logout"))
        checkDLLparams := ObjBindMethod(this, "__checkDLLparams")
        SetTimer, %checkDLLparams%, 10, 2
        this.getType()
        this.__init_arrays()
    }
    
    getType(){
        if(!this.VM_TYPE){
            VarSetCapacity(type, 4)
            errLevel := DllCall(VM_DLL . "\VBVMR_GetVoicemeeterType","Ptr" , &type, "Int")
            if(errLevel<0)
                Throw, Exception("VBVMR_GetVoicemeeterType returned " . errLevel, -1)
            this.VM_TYPE:= NumGet(type, 0, "Int")
            Switch this.VM_TYPE {
                case 1:
                    this.VM_BUSCOUNT:= 2
                    this.VM_STRIPCOUNT:= 3 
                case 2:
                    this.VM_BUSCOUNT:= 5
                    this.VM_STRIPCOUNT:= 5 
                case 3:
                    this.VM_BUSCOUNT:= 8
                    this.VM_STRIPCOUNT:= 8 
            }
        }
        return this.VM_TYPE
    }

    runVoicemeeter(){
        Run, %VM_PATH%voicemeeter8x64.exe , %VM_PATH%, UseErrorLevel Min
        if(!ErrorLevel)
            return
        Run, %VM_PATH%voicemeeter8.exe , %VM_PATH%, UseErrorLevel Min
        if(!ErrorLevel)
            return
        Run, %VM_PATH%voicemeeterpro.exe , %VM_PATH%, UseErrorLevel Min
        if(!ErrorLevel)
            return
        Run, %VM_PATH%voicemeeter.exe , %VM_PATH%, UseErrorLevel Min
        if(ErrorLevel)
            Throw, Exception("Could not run Voicemeeter", -1)
    }

    updateDevices(){
        VMR.VM_BUS_STRIP.BusDevices:= Array()
        VMR.VM_BUS_STRIP.StripDevices:= Array()
        this.checkparams()
        loop % DllCall(VM_DLL . "\VBVMR_Output_GetDeviceNumber","Int") {
            VarSetCapacity(ptrName, 1024)
            VarSetCapacity(ptrDriver, 4)
            DllCall(VM_DLL . "\VBVMR_Output_GetDeviceDescW", "Int", A_Index-1, "Ptr" , &ptrDriver , "Ptr", &ptrName, "Ptr", 0, "Int")
            ptrDriver := NumGet(ptrDriver, 0, "UInt")
            device := {}
            device.Name := ptrName
            device.Driver := (ptrDriver=3 ? "wdm" : (ptrDriver=4 ? "ks" : (ptrDriver=5 ? "asio" : "mme"))) 
            VMR.VM_BUS_STRIP.BusDevices.Push(device)
        }
        this.checkparams()
        loop % DllCall(VM_DLL . "\VBVMR_Input_GetDeviceNumber","Int") {
            VarSetCapacity(ptrName, 1024)
            VarSetCapacity(ptrDriver, 4)
            DllCall(VM_DLL . "\VBVMR_Input_GetDeviceDescW", "Int", A_Index-1, "Ptr" , &ptrDriver , "Ptr", &ptrName, "Ptr", 0, "Int")
            ptrDriver := NumGet(ptrDriver, 0, "UInt")
            device := {}
            device.Name := ptrName
            device.Driver := (ptrDriver=3 ? "wdm" : (ptrDriver=4 ? "ks" : (ptrDriver=5 ? "asio" : "mme"))) 
            VMR.VM_BUS_STRIP.StripDevices.Push(device)
        }
    }

    __init_arrays(){
        loop % this.VM_BUSCOUNT {
            this.bus.Push(new this.VM_BUS)
        }
        loop % this.VM_STRIPCOUNT {
            this.strip.Push(new this.VM_STRIP)
        }
        this.updateDevices()
    }
    
    __checkDLLparams(){
        DllCall(VM_DLL . "\VBVMR_IsParametersDirty")
    }
    
    __logout(){
        DllCall(VM_DLL . "\VBVMR_Logout")
        DllCall("FreeLibrary", "Ptr", this.VBVMRDLL) 
    }

    class VM_BUS extends VMR.VM_BUS_STRIP{
        static BUS_COUNT:=0
        
        __New(){
            this.BUS_STRIP_TYPE:="Bus"
            this.BUS_STRIP_INDEX:= VMR.VM_BUS.BUS_COUNT++ 
        }
    }

    class VM_STRIP extends VMR.VM_BUS_STRIP{
        static STRIP_COUNT:=0

        __New(){
            this.BUS_STRIP_TYPE:="Strip"
            this.BUS_STRIP_INDEX:= VMR.VM_STRIP.STRIP_COUNT++
        }
            
    }
    
    class VM_BUS_STRIP {
        static StripDevices, BusDevices
        BUS_STRIP_TYPE:=, BUS_STRIP_INDEX:=
        
        incGain(){
            local gain := this.getGain()
            gain += gain < 12 ? 1.2 : 0
            return this.setGain(gain)
        }

        decGain(){
            local gain := this.getGain()
            gain -= gain > -60 ? 1.2 : 0
            return this.setGain(gain)
        }

        setGain(gain){
            return this.setParameter("gain", gain)
        }

        getGain(){
            local gain := this.getParameter("gain")
            SetFormat, FloatFast, 4.1
            return gain+0
        }

        getGainPercentage(){
            dB := this.getGain()
            min_s := 10**(-60/20), max_s := 10**(0/20)
            return ((10**(dB/20))-min_s)/(max_s-min_s)*100
        }

        toggleMute(){
            return this.setMute(!this.getMute())
        }

        setMute(mute){
            return this.setParameter("mute",mute)
        }

        getMute(){
            return this.getParameter("mute")
        }

        setDevice(device,driver:="wdm"){
            if (!this.__isPhysical())
                return -4
            if driver not in wdm,mme,ks,asio
                return -5
            device := this.__getDeviceObj(device,driver)
            this.setParameter("device." . device.Driver,device.Name)
            return device.Name
        }    

        getDevice(){
            return this.getParameter("device.name")
        }

        setParameter(parameter, value){
            local func
            if parameter contains device,FadeTo,Label
                func:= "__setParameterString"
            else
                func:= "__setParameterFloat"
            return this[func](parameter,value)
        }

        getParameter(parameter){
            local func
            if parameter contains device,FadeTo,Label
                func:= "__getParameterString"
            else
                func:= "__getParameterFloat"
            this.checkparams()
            return this[func](parameter)
        }

        __setParameterFloat(p_parameter, p_value){
            this.checkparams()
            errLevel := DllCall(VM_DLL . "\VBVMR_SetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "]." . p_parameter , "Float" , p_value, "Int")
            if (errLevel<0)
                Throw, Exception("VBVMR_SetParameterFloat returned " . errLevel, -1)
            return p_value
        }

        __setParameterString(p_parameter, p_value){
            this.checkparams()
            errLevel := DllCall(VM_DLL . "\VBVMR_SetParameterStringW", "AStr", this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "]." . p_parameter , "WStr" , p_value , "Int")
            if (errLevel<0)
                Throw, Exception("VBVMR_SetParameterStringW returned " . errLevel, -1)
            return p_value
        }

        __getParameterFloat(p_parameter){
            local value
            this.checkparams()
            VarSetCapacity(value, 4)
            errLevel := DllCall(VM_DLL . "\VBVMR_GetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX  . "]." . p_parameter , "Ptr" , &value, "Int")
            if (errLevel<0)
                Throw, Exception("VBVMR_GetParameterFloat returned " . errLevel, -1)
            value := NumGet(&value, 0, "Float")
            return value
        }

        __getParameterString(p_parameter){
            local value
            this.checkparams()
            VarSetCapacity(value, 1024)
            errLevel := DllCall(VM_DLL . "\VBVMR_GetParameterStringW", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "]." . p_parameter , "Ptr" , &value , "Int")
            if (errLevel<0)
                Throw, Exception("VBVMR_GetParameterStringW returned " . errLevel, -1)
            value := StrGet(&value,512,"UTF-16")
            return value
        }
        
        __getDeviceObj(substring,driver:="wdm"){
            local devices_array := this.BUS_STRIP_TYPE . "Devices", devices:= VMR.VM_BUS_STRIP[devices_array]
            for i in devices 
                if (devices[i].Driver = driver && InStr(devices[i].Name, substring)>0)
                    return devices[i]
        }

        __isPhysical(){
            local VM_type
            VarSetCapacity(VM_type, 4)
            DllCall(VM_DLL . "\VBVMR_GetVoicemeeterType","Ptr" , &VM_type, "Int")
            Switch NumGet(VM_type, 0, "Int") {
                case 1: ;vm
                    if(this.BUS_STRIP_TYPE = "Strip")
                        return this.BUS_STRIP_INDEX < 2
                    else
                        return 1
                case 2: ;vm banana
                        return this.BUS_STRIP_INDEX < 3
                case 3: ;vm potato
                        return this.BUS_STRIP_INDEX < 5
            }
        }
        
        checkparams(){
            DllCall(VM_DLL . "\VBVMR_IsParametersDirty")
        }
    }
    class command {
                
        restart(){
            this.__setParameterFloat("Restart","1.0f")
        }

        shutdown(){
            this.__setParameterFloat("Shutdown ","1.0f")
        }

        show(){
            this.__setParameterFloat("Show","1.0f")
        }

        eject(){
            this.__setParameterFloat("Eject","1.0f")
        }

        reset(){
            this.__setParameterFloat("Reset","1.0f")
        }

        save(filePath){
            this.__setParameterString("Save",filePath)
        }

        load(filePath){
            this.__setParameterString("Load",filePath)
        }

        __setParameterFloat(p_parameter, p_value){
            this.checkparams()
            errLevel := DllCall(VM_DLL . "\VBVMR_SetParameterFloat", "AStr" , "Command." . p_parameter , "Float" , p_value, "Int")
            if (errLevel<0)
                Throw, Exception("VBVMR_SetParameterFloat returned " . errLevel, -1)
            return p_value
        }

        __setParameterString(p_parameter, p_value){
            this.checkparams()
            errLevel := DllCall(VM_DLL . "\VBVMR_SetParameterStringW", "AStr", "Command." . p_parameter , "WStr" , p_value , "Int")
            if (errLevel<0)
                Throw, Exception("VBVMR_SetParameterStringW returned " . errLevel, -1)
            return p_value
        }
    }
}