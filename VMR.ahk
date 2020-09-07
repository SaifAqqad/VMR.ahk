global VM_PATH:=, VM_DLL:=
class VMR{
    static VM_TYPE:=, VM_BUSCOUNT:=, VM_STRIPCOUNT:=
    bus:=Array(), strip:=Array()
    
    __New(dir:=""){
        if(A_Is64bitOS){
            VM_PATH := dir? dir : "C:\Program Files (x86)\VB\Voicemeeter\"
            VM_DLL := "VoicemeeterRemote64"
        }else{
            VM_PATH := dir? dir : "C:\Program Files\VB\Voicemeeter\"
            VM_DLL := "VoicemeeterRemote"
        }
    }
    
    login(){
        this.VBVMRDLL := DllCall("LoadLibrary", "str", VM_PATH . VM_DLL . ".dll")
        DllCall(VM_DLL . "\VBVMR_Login")
        checkDLLparams:= ObjBindMethod(this, "__checkDLLparams")
        SetTimer, %checkDLLparams%, 10, 2
        OnExit(ObjBindMethod(this, "logout"))
        this.getType()
        this.__init_bus()
        this.__init_strip()
        VMR.VM_BUS_STRIP.__updateDevices()
    }
        
    logout(){
        DllCall(VM_DLL . "\VBVMR_Logout")
        DllCall("FreeLibrary", "Ptr", this.VBVMRDLL) 
    }

    restart(){
        DllCall(VM_DLL . "\VBVMR_SetParameterFloat","AStr","Command.Restart","Float","1.0f", "Int")
        VMR.VM_BUS_STRIP.__updateDevices()
    }
    
    getType(){
        VarSetCapacity(type, 4)
        DllCall(VM_DLL . "\VBVMR_GetVoicemeeterType","Ptr" , &type, "Int")
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
        return this.VM_TYPE
    }

    __init_bus(){
        loop % this.VM_BUSCOUNT {
            this.bus.Push(new this.VM_BUS)
        }
    }

    __init_strip(){
        loop % this.VM_STRIPCOUNT {
            this.strip.Push(new this.VM_STRIP)
        }
    }
    
    __checkDLLparams(){
        DllCall(VM_DLL . "\VBVMR_IsParametersDirty")
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
            this.setParameter("gain", gain)
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
            return this.setParameter("mute",!this.getMute())
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
            errLevel := this.setParameter("device." . device.Driver,device.Name)
            return errLevel<0 ? errLevel : device.Name
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
            return this[func](parameter)
        }

        __setParameterFloat(p_parameter, p_value){
            this.checkparams()
            return DllCall(VM_DLL . "\VBVMR_SetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "]." . p_parameter , "Float" , p_value, "Int")
        }

        __setParameterString(p_parameter, p_value){
            this.checkparams()
            return DllCall(VM_DLL . "\VBVMR_SetParameterStringW", "AStr", this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "]." . p_parameter , "WStr" , p_value , "Int")
        }

        __getParameterFloat(p_parameter){
            local value
            this.checkparams()
            NumPut(0.0, &value, 0, "Float")
            errLevel := DllCall(VM_DLL . "\VBVMR_GetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX  . "]." . p_parameter , "Ptr" , &value, "Int")
            value := NumGet(&value, 0, "Float")
            return errLevel < 0 ? errLevel : value
        }

        __getParameterString(p_parameter){
            local value
            this.checkparams()
            VarSetCapacity(value, 1024)
            errLevel := DllCall(VM_DLL . "\VBVMR_GetParameterStringW", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "]." . p_parameter , "Ptr" , &value , "Int")
            value := StrGet(&value,512,"UTF-16")
            return errLevel < 0 ? errLevel : value
        }
        
        __getDeviceObj(substring,driver:="wdm"){
            local devices_array := this.BUS_STRIP_TYPE . "Devices", devices:= VMR.VM_BUS_STRIP[devices_array]
            for i in devices 
                if (devices[i].Driver = driver && InStr(devices[i].Name, substring)>0)
                    return devices[i]
        }
    
        __updateDevices(){
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
}