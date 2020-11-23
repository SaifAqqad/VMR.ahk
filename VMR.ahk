class VMR{
    bus:=Array(), strip:=Array(), recorder:=
    
    __New(p_path:=""){
        if(p_path && SubStr(p_path, 0)!="\"){
            p_path.= "\"
        }
        if(A_Is64bitOS){
            VBVMR.VM_PATH := p_path? p_path : "C:\Program Files (x86)\VB\Voicemeeter\"
            VBVMR.VM_DLL := "VoicemeeterRemote64"
        }else{
            VBVMR.VM_PATH := p_path? p_path : "C:\Program Files\VB\Voicemeeter\"
            VBVMR.VM_DLL := "VoicemeeterRemote"
        }
        VBVMR.STR_TYPE := A_IsUnicode? "W" : "A"
        VBVMR.DLL := DllCall("LoadLibrary", "Str", VBVMR.VM_PATH . VBVMR.VM_DLL . ".dll", "Ptr")
        VBVMR.__getAddresses()
        this.recorder:= new this.__recorder
    }
    
    login(){
        if(VBVMR.Login()){
            this.runVoicemeeter()
            sleep, 1000
        }
        OnExit(ObjBindMethod(VBVMR, "Logout"))
        syncWithDLL := ObjBindMethod(this, "__syncWithDLL")
        SetTimer, %syncWithDLL%, 10, 3
        this.getType()
        this.__init_arrays()
    }
    
    getType(){
        if(!VBVMR.VM_TYPE){
            VBVMR.VM_TYPE:= VBVMR.GetVoicemeeterType()
            Switch VBVMR.VM_TYPE {
                case 1:
                    VBVMR.VM_BUSCOUNT:= 2
                    VBVMR.VM_STRIPCOUNT:= 3 
                case 2:
                    VBVMR.VM_BUSCOUNT:= 5
                    VBVMR.VM_STRIPCOUNT:= 5 
                case 3:
                    VBVMR.VM_BUSCOUNT:= 8
                    VBVMR.VM_STRIPCOUNT:= 8 
            }
        }
        return VBVMR.VM_TYPE
    }

    runVoicemeeter(){
        Run, % VBVMR.VM_PATH "voicemeeter8x64.exe" , % VBVMR.VM_PATH, UseErrorLevel Hide
        if(!ErrorLevel)
            return
        Run, % VBVMR.VM_PATH "voicemeeter8.exe" , % VBVMR.VM_PATH, UseErrorLevel Hide
        if(!ErrorLevel)
            return
        Run, % VBVMR.VM_PATH "voicemeeterpro.exe" , % VBVMR.VM_PATH, UseErrorLevel Hide
        if(!ErrorLevel)
            return
        Run, % VBVMR.VM_PATH "voicemeeter.exe" , % VBVMR.VM_PATH, UseErrorLevel Hide
        if(ErrorLevel)
            Throw, Exception("Could not run Voicemeeter", -1)
    }

    updateDevices(){
        VMR.VM_BUS_STRIP.BusDevices:= Array()
        VMR.VM_BUS_STRIP.StripDevices:= Array()
        this.__syncWithDLL()
        loop % VBVMR.Output_GetDeviceNumber()
            VMR.VM_BUS_STRIP.BusDevices.Push(VBVMR.Output_GetDeviceDesc(A_Index-1))
        this.__syncWithDLL()
        loop % VBVMR.Input_GetDeviceNumber() 
            VMR.VM_BUS_STRIP.StripDevices.Push(VBVMR.Input_GetDeviceDesc(A_Index-1))
    }

    __init_arrays(){
        loop % VBVMR.VM_BUSCOUNT {
            this.bus.Push(new this.VM_BUS_STRIP("Bus"))
        }
        loop % VBVMR.VM_STRIPCOUNT {
            this.strip.Push(new this.VM_BUS_STRIP("Strip"))
        }
        this.updateDevices()
    }

    __syncWithDLL(){
        static ignore_msg:=0
        try {
            VBVMR.IsParametersDirty()
            loop % VBVMR.VM_BUSCOUNT {
                this.bus[A_Index].__updateLevel()
            }
            loop % VBVMR.VM_STRIPCOUNT {
                this.strip[A_Index].__updateLevel()
            }
            ignore_msg:=0
        } catch e {
            if(!ignore_msg){
                MsgBox, 52, VMR, Voicemeeter is down `nattempt to restart it?
                IfMsgBox Yes
                    this.runVoicemeeter()
                IfMsgBox, No
                    ignore_msg:=1
                sleep, 1000
            }
        }
    }

    __Delete(){
        DllCall("FreeLibrary", "Ptr", VBVMR.DLL)
    }
    
    class VM_BUS_STRIP {
        static BUS_COUNT:=0, BUS_LEVEL_COUNT:=0, BusDevices:=Array(), STRIP_COUNT:=0, STRIP_LEVEL_COUNT:=0, StripDevices:=Array()
        BUS_STRIP_TYPE:=, BUS_STRIP_INDEX:=, BUS_STRIP_ID, LEVEL_INDEX, level, gain_limit
        
        gain{
            set{
                if(!this.BUS_STRIP_ID)
                    return
                return this.setParameter("gain", max(-60.0, min(value, this.gain_limit)))
            }
            get{
                if(!this.BUS_STRIP_ID)
                    return
                SetFormat, FloatFast, 4.1
                return this.getParameter("gain")+0
            }
        }

        mute{
            set{
                if(!this.BUS_STRIP_ID)
                    return
                if(value = -1)
                    value:= !this.mute
                return this.setParameter("mute", value)
            }
            get{
                if(!this.BUS_STRIP_ID)
                    return
                return this.getParameter("mute")
            }
        }

        device[driver:="wdm"]{
            set{
                if(!this.BUS_STRIP_ID)
                    return
                if (!this.__isPhysical())
                    return -4
                if driver not in wdm,mme,ks,asio
                    return -5
                deviceObj := this.__getDeviceObj(value,driver)
                return this.setParameter("device." . deviceObj.Driver,deviceObj.Name)
            }
            get{
                if(!this.BUS_STRIP_ID)
                    return
                return this.getParameter("device.name")
            }
        }

        __New(p_type){
            this.BUS_STRIP_TYPE := p_type
            this.level := Array()
            this.LEVEL_INDEX := Array()
            this.gain_limit:= 12.0
            if (p_type="Strip") {
                this.BUS_STRIP_INDEX := VMR.VM_BUS_STRIP.STRIP_COUNT++
                loop % this.__isPhysical() ? 2 : 8 
                    this.LEVEL_INDEX.Push(VMR.VM_BUS_STRIP.STRIP_LEVEL_COUNT++)
            }else{
                this.BUS_STRIP_INDEX := VMR.VM_BUS_STRIP.BUS_COUNT++
                loop 8 
                    this.LEVEL_INDEX.Push(VMR.VM_BUS_STRIP.BUS_LEVEL_COUNT++)
            }
            this.BUS_STRIP_ID := this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "]"
        }

        getGainPercentage(){
            return this.getPercentage(this.gain)
        }

        getPercentage(dB){
            min_s := 10**(-60/20), max_s := 10**(0/20)
            return ((10**(dB/20))-min_s)/(max_s-min_s)*100
        }

        setParameter(parameter, value){
            local func
            if parameter contains device,FadeTo,Label
                func:= "setParameterString"
            else
                func:= "setParameterFloat"
            return (VBVMR)[func](this.BUS_STRIP_ID, parameter, value)
        }

        getParameter(parameter){
            local func
            if parameter contains device,FadeTo,Label
                func:= "getParameterString"
            else
                func:= "getParameterFloat"
            VBVMR.IsParametersDirty()
            return (VBVMR)[func](this.BUS_STRIP_ID, parameter)
        }
        
        __getDeviceObj(substring,driver:="wdm"){
            local devices:= VMR.VM_BUS_STRIP[this.BUS_STRIP_TYPE . "Devices"]
            for i in devices 
                if (devices[i].driver = driver && InStr(devices[i].name, substring)>0)
                    return devices[i]
        }

        __updateLevel(){
            local type := this.BUS_STRIP_TYPE="Bus" ? 3 : 0
            loop % this.LEVEL_INDEX.Length() {
                level := VBVMR.GetLevel(type, this.LEVEL_INDEX[A_Index])
                this.level[A_Index] := Max(Ceil(20 * Log(level)), -999)
            }
        }

        __isPhysical(){
            Switch VBVMR.VM_TYPE {
                case 1:
                    if(this.BUS_STRIP_TYPE = "Strip")
                        return this.BUS_STRIP_INDEX < 2
                    else
                        return 1
                case 2:
                        return this.BUS_STRIP_INDEX < 3
                case 3:
                        return this.BUS_STRIP_INDEX < 5
            }
        }
    }
    
    class command {
                
        restart(){
            VBVMR.SetParameterFloat("Command","Restart",1)
        }

        shutdown(){
            VBVMR.SetParameterFloat("Command","Shutdown",1)
        }

        show(){
            VBVMR.SetParameterFloat("Command","Show",1)
        }

        eject(){
            VBVMR.SetParameterFloat("Command","Eject",1)
        }

        reset(){
            VBVMR.SetParameterFloat("Command","Reset",1)
        }

        save(filePath){
            VBVMR.SetParameterFloat("Command","Save",filePath)
        }

        load(filePath){
            VBVMR.SetParameterFloat("Command","Load",filePath)
        }
    }
    
    class __recorder {
        
        __Set(p_name,p_value){
            return VBVMR.SetParameterFloat("Recorder",p_name, p_value)
        }

        __Get(p_name){
            return VBVMR.GetParameterFloat("Recorder",p_name)
        }

        ArmBus(bus, set:=-1){
            if(set > -1){
                VBVMR.SetParameterFloat("Recorder","mode.recbus", 1)
                VBVMR.SetParameterFloat("Recorder","ArmBus(" (bus-1) ")", set)
            }else{
                return VBVMR.GetParameterFloat("Recorder","ArmBus(" (bus-1) ")")
            }
        }

        ArmStrips(strip*){
            loop { 
                Try 
                    this.armStrip(A_Index,0)
                Catch
                    Break
            }
            for i in strip
                Try this.armStrip(strip[i],1)
        }

        ArmStrip(strip, set:=-1){
            if(set > -1){
                VBVMR.SetParameterFloat("Recorder","mode.recbus", 0)
                VBVMR.SetParameterFloat("Recorder","ArmStrip(" . (strip-1) . ")", set)
            }else{
                return VBVMR.GetParameterFloat("Recorder","ArmStrip(" (strip-1) ")")
            }
        }
    }
}

class VBVMR {
    static DLL, VM_PATH:=, VM_DLL:=, VM_TYPE:=, VM_BUSCOUNT:=, VM_STRIPCOUNT:=
    static FUNC_ADDR:={ Login:0
        ,Logout:0
        ,SetParameterFloat:0
        ,SetParameterStringW:0
        ,SetParameterStringA:0
        ,GetParameterFloat:0
        ,GetParameterStringW:0
        ,GetParameterStringA:0
        ,GetVoicemeeterType:0
        ,GetLevel:0
        ,Output_GetDeviceNumber:0
        ,Output_GetDeviceDescW:0
        ,Output_GetDeviceDescA:0
        ,Input_GetDeviceNumber:0
        ,Input_GetDeviceDescW:0
        ,Input_GetDeviceDescA:0
        ,IsParametersDirty:0 }
    
    Login(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Login)
        if(errLevel<0)
            Throw, Exception("VBVMR_Login returned " . errLevel, -1)
        return errLevel
    }

    Logout(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Logout)
        if(errLevel<0)
            Throw, Exception("VBVMR_Logout returned " . errLevel, -1)
        return errLevel
    }

    SetParameterFloat(p_prefix, p_parameter, p_value){
        this.IsParametersDirty()
        errLevel := DllCall(VBVMR.FUNC_ADDR.SetParameterFloat, "AStr" , p_prefix . "." . p_parameter , "Float" , p_value, "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_SetParameterFloat returned " . errLevel, -1)
        return p_value
    }

    SetParameterString(p_prefix, p_parameter, p_value){
        this.IsParametersDirty()
        errLevel := DllCall(VBVMR.FUNC_ADDR["SetParameterString" . VBVMR.STR_TYPE], "AStr", p_prefix . "." . p_parameter , VBVMR.STR_TYPE . "Str" , p_value , "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_SetParameterStringW returned " . errLevel, -1)
        return p_value
    }

    GetParameterFloat(p_prefix, p_parameter){
        local value
        this.IsParametersDirty()
        VarSetCapacity(value, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetParameterFloat, "AStr" , p_prefix . "." . p_parameter , "Ptr" , &value, "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_GetParameterFloat returned " . errLevel, -1)
        value := NumGet(&value, 0, "Float")
        return value
    }

    GetParameterString(p_prefix, p_parameter){
        local value
        this.IsParametersDirty()
        VarSetCapacity(value, A_IsUnicode? 1024 : 512)
        errLevel := DllCall(VBVMR.FUNC_ADDR["GetParameterString" . VBVMR.STR_TYPE], "AStr" , p_prefix . "." . p_parameter , "Ptr" , &value , "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_GetParameterStringW returned " . errLevel, -1)
        value := StrGet(&value,512)
        return value
    }

    GetLevel(p_type, p_channel){
        local level
        this.IsParametersDirty()
        VarSetCapacity(level,4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetLevel, "Int", p_type, "Int", p_channel, "Ptr", &level)
        if(errLevel<0){
            SetTimer,, Off
            Throw, Exception("VBVMR_GetLevel returned " . errLevel, -1)
        }
        level := NumGet(&level, 0, "Float")
        return level
    }

    GetVoicemeeterType(){
        local vtype
        VarSetCapacity(vtype, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetVoicemeeterType, "Ptr", &vtype, "Int")
        if(errLevel<0)
            Throw, Exception("VBVMR_GetVoicemeeterType returned " . errLevel, -1)
        vtype:= NumGet(vtype, 0, "Int")
        return vtype
    }

    Output_GetDeviceNumber(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Output_GetDeviceNumber,"Int") 
        if(errLevel<0)
            Throw, Exception("VBVMR_Output_GetDeviceNumber returned " . errLevel, -1)
        else
            return errLevel
    }
    
    Output_GetDeviceDesc(p_index){
        local name, driver, device := {}
        VarSetCapacity(name, A_IsUnicode? 1024 : 512)
        VarSetCapacity(driver, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR["Output_GetDeviceDesc" . VBVMR.STR_TYPE], "Int", p_index, "Ptr" , &driver , "Ptr", &name, "Ptr", 0, "Int")
        driver := NumGet(&driver, 0, "UInt")
        name := StrGet(&name,512)
        device.name := name
        device.driver := (driver=3 ? "wdm" : (driver=4 ? "ks" : (driver=5 ? "asio" : "mme"))) 
        return device
    }

    Input_GetDeviceNumber(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Input_GetDeviceNumber,"Int") 
        if(errLevel<0)
            Throw, Exception("VBVMR_Input_GetDeviceNumber returned " . errLevel, -1)
        else
            return errLevel
    }

    Input_GetDeviceDesc(p_index){
        local name, driver, device := {}
        VarSetCapacity(name, A_IsUnicode? 1024 : 512)
        VarSetCapacity(driver, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR["Input_GetDeviceDesc" . VBVMR.STR_TYPE], "Int", p_index, "Ptr" , &driver , "Ptr", &name, "Ptr", 0, "Int")
        driver := NumGet(&driver, 0, "UInt")
        name := StrGet(&name,512)
        device.name := name
        device.driver := (driver=3 ? "wdm" : (driver=4 ? "ks" : (driver=5 ? "asio" : "mme"))) 
        return device
    }

    IsParametersDirty(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.IsParametersDirty)
        if(errLevel<0)
            Throw, Exception("VBVMR_IsParametersDirty returned " . errLevel, -1)
        else
            return errLevel 
    }

    __getAddresses(){
        for fName in VBVMR.FUNC_ADDR 
            (VBVMR.FUNC_ADDR)[fName]:= DllCall("GetProcAddress", "Ptr", VBVMR.DLL, "AStr", "VBVMR_" . fName, "Ptr")
    }
}