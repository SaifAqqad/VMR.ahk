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
    }
        
    logout(){
        DllCall(VM_DLL . "\VBVMR_Logout")
        DllCall("FreeLibrary", "Ptr", this.VBVMRDLL) 
    }

    restart(){
        DllCall(VM_DLL . "\VBVMR_SetParameterFloat","AStr","Command.Restart","Float","1.0f", "Int")
        VMR.VM_BUS.updateDevices()
        VMR.VM_STRIP.updateDevices()
    }
    
    getType(){
        VarSetCapacity(type, 32)
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
    }

    __init_bus(){
        loop % this.VM_BUSCOUNT {
            this.bus.Push(new this.VM_BUS)
        }
        this.VM_BUS.updateDevices()
    }

    __init_strip(){
        loop % this.VM_STRIPCOUNT {
            this.strip.Push(new this.VM_STRIP)
        }
        this.VM_STRIP.updateDevices()
    }
    
    __checkDLLparams(){
        DllCall(VM_DLL . "\VBVMR_IsParametersDirty")
    }
    
    class VM_BUS extends VMR.VM_BUS_STRIP{
        static BUS_COUNT:=0, devices:= Array()
        
        __New(){
            this.BUS_STRIP_TYPE:="Bus"
            this.BUS_STRIP_INDEX:= VMR.VM_BUS.BUS_COUNT++ 
        }

        setDevice(device,driver:="wdm"){
            if((VMR.VM_BUS.BUS_COUNT=5 && this.BUS_STRIP_INDEX>2) || (VMR.VM_BUS.BUS_COUNT=8 && this.BUS_STRIP_INDEX>4)){
                return -4
            }
            if driver not in wdm,mme,ks,asio
                return -5
            device := this.getDevice(device,driver)
            errLevel := DllCall(VM_DLL . "\VBVMR_SetParameterStringW", "AStr","Bus[" . this.BUS_STRIP_INDEX . "].Device." . device.Driver , "WStr" , device.Name , "Int") 
            return errLevel<0 ? errLevel : device.Name
        }

        getDevice(device,driver){
            for i in VMR.VM_BUS.devices 
                if (VMR.VM_BUS.devices[i].Driver = driver && InStr(VMR.VM_BUS.devices[i].Name, device)>0)
                    return VMR.VM_BUS.devices[i]
        }

        updateDevices(){
            VMR.VM_BUS.devices:= Array()
            loop % DllCall(VM_DLL . "\VBVMR_Output_GetDeviceNumber","Int") {
                VarSetCapacity(ptrName, 1000)
                VarSetCapacity(ptrDriver, 1000)
                DllCall(VM_DLL . "\VBVMR_Output_GetDeviceDescW", "Int", A_Index-1, "Ptr" , &ptrDriver , "Ptr", &ptrName, "Ptr", 0, "Int")
                ptrDriver := NumGet(ptrDriver, 0, "UInt")
                device := {}
                device.Name := ptrName
                device.Driver := (ptrDriver=3 ? "wdm" : (ptrDriver=4 ? "ks" : (ptrDriver=5 ? "asio" : "mme"))) 
                VMR.VM_BUS.devices.Push(device)
            }
        }
    }

    class VM_STRIP extends VMR.VM_BUS_STRIP{
        static STRIP_COUNT:=0, devices:= Array()

        __New(){
            this.BUS_STRIP_TYPE:="Strip"
            this.BUS_STRIP_INDEX:= VMR.VM_STRIP.STRIP_COUNT++
        }

        setDevice(device,driver:="wdm"){
            if((VMR.VM_STRIP.STRIP_COUNT=3 && this.BUS_STRIP_INDEX>1) || (VMR.VM_STRIP.STRIP_COUNT=5 && this.BUS_STRIP_INDEX>2) || (STRIP_COUNT=8 && base.BUS_STRIP_INDEX>4)){
                return -4
            }
            if driver not in wdm,mme,ks,asio
                return -5
            device := this.getDevice(device,driver)
            errLevel := DllCall(VM_DLL . "\VBVMR_SetParameterStringW", "AStr","Strip[" . this.BUS_STRIP_INDEX . "].Device." . device.Driver , "WStr" , device.Name , "Int") 
            return errLevel<0 ? errLevel : device.Name
        }

        getDevice(device,driver){
            for i in VMR.VM_STRIP.devices {
                if (VMR.VM_STRIP.devices[i].Driver = driver && InStr(VMR.VM_STRIP.devices[i].Name, device)>0)
                    return VMR.VM_STRIP.devices[i]
            }
        }

        updateDevices(){
            VMR.VM_STRIP.devices:= Array()
            loop % DllCall(VM_DLL . "\VBVMR_Input_GetDeviceNumber","Int") {
                VarSetCapacity(ptrName, 1000)
                VarSetCapacity(ptrDriver, 1000)
                DllCall(VM_DLL . "\VBVMR_Input_GetDeviceDescW", "Int", A_Index-1, "Ptr" , &ptrDriver , "Ptr", &ptrName, "Ptr", 0, "Int")
                ptrDriver := NumGet(ptrDriver, 0, "UInt")
                device := {}
                device.Name := ptrName
                device.Driver := (ptrDriver=3 ? "wdm" : (ptrDriver=4 ? "ks" : (ptrDriver=5 ? "asio" : "mme"))) 
                VMR.VM_STRIP.devices.Push(device)
            }
        }
    }

    class VM_BUS_STRIP {
        BUS_STRIP_TYPE:=, BUS_STRIP_INDEX:=
        
        incGain(){
            local gain
            this.checkparams()
            gain := this.getGain()
            gain += (gain < 12 ? 1.2 : 0)
            return DllCall(VM_DLL . "\VBVMR_SetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX  . "].Gain" , "Float" , gain , "Int")
        }

        decGain(){
            local gain
            this.checkparams()
            gain := this.getGain()
            gain -= gain > -60 ? 1.2 : 0
            return DllCall(VM_DLL . "\VBVMR_SetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX  . "].Gain" , "Float" , gain , "Int")
        }

        setGain(gain){
            return DllCall(VM_DLL . "\VBVMR_SetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX  . "].Gain" , "Float" , gain , "Int")
        }

        getGain(){
            local gain := 0.0
            this.checkparams()
            NumPut(0.0, gain, 0, "Float")
            DllCall(VM_DLL . "\VBVMR_GetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX  . "].Gain" , "Ptr" , &gain, "Int")
            gain := NumGet(gain, 0, "Float")
            SetFormat, FloatFast, 4.1
            return gain+0
        }

        getGainPercentage(){
            local dB
            this.checkparams()
            dB := this.getGain()
            min_s := 10**(-60/20), max_s := 10**(0/20)
            return ((10**(dB/20))-min_s)/(max_s-min_s)*100
        }

        toggleMute(){
            local mute
            this.checkparams()
            mute := !this.getMute()
            DllCall(VM_DLL . "\VBVMR_SetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "].Mute" , "Float" , mute, "Int")
        }

        setMute(mute){
            return DllCall(VM_DLL . "\VBVMR_SetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "].Mute" , "Float" , mute, "Int")
        }

        getMute(){
            local mute := 0
            this.checkparams()
            NumPut(0, mute, 0, "Float")
            DllCall(VM_DLL . "\VBVMR_GetParameterFloat", "AStr" , this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "].Mute" , "Ptr" , &mute , "Int")
            return NumGet(mute, 0, "Float")
        }

        checkparams(){
            DllCall(VM_DLL . "\VBVMR_IsParametersDirty")
        }
    }
}