class VMR{
    bus:=Array(), strip:=Array()
    
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
        VBVMR.DLL := DllCall("LoadLibrary", "Str", VBVMR.VM_PATH . VBVMR.VM_DLL . ".dll", "Ptr")
        VBVMR.__getAddresses()
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
        VBVMR.IsParametersDirty()
        loop % VBVMR.VM_BUSCOUNT {
            this.bus[A_Index].__updateLevel()
        }
        loop % VBVMR.VM_STRIPCOUNT {
            this.strip[A_Index].__updateLevel()
        }
    }

    __Delete(){
        DllCall("FreeLibrary", "Ptr", VBVMR.DLL)
    }
    
    class VM_BUS_STRIP {
        static BUS_COUNT:=0, BUS_LEVEL_COUNT:=0, BusDevices:=Array(), STRIP_COUNT:=0, STRIP_LEVEL_COUNT:=0, StripDevices:=Array()
        BUS_STRIP_TYPE:=, BUS_STRIP_INDEX:=, level, LEVEL_INDEX, BUS_STRIP_ID
        
        __New(p_type){
            this.BUS_STRIP_TYPE := p_type
            this.level := Array()
            this.LEVEL_INDEX := Array()
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
    
    class recorder {
        stop(set:=-1){
            if(set > -1)
                VBVMR.SetParameterFloat("Recorder","stop", 1)
            else
                return VBVMR.GetParameterFloat("Recorder","stop")
        }

        play(set:=-1){
            if(set > -1)
                VBVMR.SetParameterFloat("Recorder","play", 1)
            else
                return VBVMR.GetParameterFloat("Recorder","play")
        }

        A(p_I, set:=-1){
            if(set > -1)
                VBVMR.SetParameterFloat("Recorder","A" . p_I, set)
            else
                return VBVMR.GetParameterFloat("Recorder","A" . p_I)
        }

        B(p_I, set:=-1){
            if(set > -1)
                VBVMR.SetParameterFloat("Recorder","B" . p_I, set)
            else
                return VBVMR.GetParameterFloat("Recorder","B" . p_I)
        }
        
        load(fileName){
            VBVMR.SetParameterFloat("Recorder","load", fileName)
        }
        
        PlayOnLoad(set:=-1){
            if(set > -1)
                VBVMR.SetParameterFloat("Recorder","mode.PlayOnLoad", set)
            else
                return VBVMR.GetParameterFloat("Recorder","mode.PlayOnLoad")
        }

        Loop(set:=-1){
            if(set > -1)
                VBVMR.SetParameterFloat("Recorder","mode.Loop", set)
            else
                return VBVMR.GetParameterFloat("Recorder","mode.Loop")
        }

        record(set:=-1){
            if(set > -1)
                VBVMR.SetParameterFloat("Recorder","record", 1)
            else
                return VBVMR.GetParameterFloat("Recorder","record")
        }

        armBus(bus, set:=-1){
            if(set > -1){
                VBVMR.SetParameterFloat("Recorder","mode.recbus", 1)
                VBVMR.SetParameterFloat("Recorder","ArmBus(" (bus-1) ")", set)
            }else{
                return VBVMR.GetParameterFloat("Recorder","ArmBus(" (bus-1) ")")
            }
        }

        armStrips(strip*){
            loop { 
                Try 
                    this.armStrip(A_Index,0)
                Catch
                    Break
            }
            for i in strip
                Try this.armStrip(strip[i],1)
        }

        armStrip(strip, set:=-1){
            if(set > -1){
                VBVMR.SetParameterFloat("Recorder","mode.recbus", 0)
                VBVMR.SetParameterFloat("Recorder","ArmStrip(" . (strip-1) . ")", set)
            }else{
                return VBVMR.GetParameterFloat("Recorder","ArmStrip(" (strip-1) ")")
            }
        }

        Gain(set:="none"){
            if(set != "none")
                VBVMR.SetParameterFloat("Recorder","Gain", set)
            else
                return VBVMR.GetParameterFloat("Recorder","Gain")
        }

        FileType(set:="none"){
            if(set != "none")
                VBVMR.SetParameterFloat("Recorder","FileType", set)
            else
                return VBVMR.GetParameterFloat("Recorder","FileType")
        }
    }
}

class VBVMR {
    static DLL, VM_PATH:=, VM_DLL:=, VM_TYPE:=, VM_BUSCOUNT:=, VM_STRIPCOUNT:=
    static FUNC_ADDR:={ VBVMR_Login:0
        ,VBVMR_Logout:0
        ,VBVMR_SetParameterFloat:0
        ,VBVMR_SetParameterStringW:0
        ,VBVMR_GetParameterFloat:0
        ,VBVMR_GetParameterStringW:0
        ,VBVMR_GetVoicemeeterType:0
        ,VBVMR_GetLevel:0
        ,VBVMR_Output_GetDeviceNumber:0
        ,VBVMR_Output_GetDeviceDescW:0
        ,VBVMR_Input_GetDeviceNumber:0
        ,VBVMR_Input_GetDeviceDescW:0
        ,VBVMR_IsParametersDirty:0 }
    
    Login(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_Login)
        if(errLevel<0)
            Throw, Exception("VBVMR_Login returned " . errLevel, -1)
        return errLevel
    }

    Logout(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_Logout)
        if(errLevel<0)
            Throw, Exception("VBVMR_Logout returned " . errLevel, -1)
        return errLevel
    }

    SetParameterFloat(p_prefix, p_parameter, p_value){
        this.IsParametersDirty()
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_SetParameterFloat, "AStr" , p_prefix . "." . p_parameter , "Float" , p_value, "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_SetParameterFloat returned " . errLevel, -1)
        return p_value
    }

    SetParameterString(p_prefix, p_parameter, p_value){
        this.IsParametersDirty()
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_SetParameterStringW, "AStr", p_prefix . "." . p_parameter , "WStr" , p_value , "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_SetParameterStringW returned " . errLevel, -1)
        return p_value
    }

    GetParameterFloat(p_prefix, p_parameter){
        local value
        this.IsParametersDirty()
        VarSetCapacity(value, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_GetParameterFloat, "AStr" , p_prefix . "." . p_parameter , "Ptr" , &value, "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_GetParameterFloat returned " . errLevel, -1)
        value := NumGet(&value, 0, "Float")
        return value
    }

    GetParameterString(p_prefix, p_parameter){
        local value
        this.IsParametersDirty()
        VarSetCapacity(value, 1024)
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_GetParameterStringW, "AStr" , p_prefix . "." . p_parameter , "Ptr" , &value , "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_GetParameterStringW returned " . errLevel, -1)
        value := StrGet(&value,512,"UTF-16")
        return value
    }

    GetLevel(p_type, p_channel){
        local level
        this.IsParametersDirty()
        VarSetCapacity(level,4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_GetLevel, "Int", p_type, "Int", p_channel, "Ptr", &level)
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
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_GetVoicemeeterType, "Ptr", &vtype, "Int")
        if(errLevel<0)
            Throw, Exception("VBVMR_GetVoicemeeterType returned " . errLevel, -1)
        vtype:= NumGet(vtype, 0, "Int")
        return vtype
    }

    Output_GetDeviceNumber(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_Output_GetDeviceNumber,"Int") 
        if(errLevel<0)
            Throw, Exception("VBVMR_Output_GetDeviceNumber returned " . errLevel, -1)
        else
            return errLevel
    }
    
    Output_GetDeviceDesc(p_index){
        local name, driver, device := {}
        VarSetCapacity(name, 1024)
        VarSetCapacity(driver, 4)
        DllCall(VBVMR.FUNC_ADDR.VBVMR_Output_GetDeviceDescW, "Int", p_index, "Ptr" , &driver , "Ptr", &name, "Ptr", 0, "Int")
        driver := NumGet(driver, 0, "UInt")
        device.name := name
        device.driver := (driver=3 ? "wdm" : (driver=4 ? "ks" : (driver=5 ? "asio" : "mme"))) 
        return device
    }

    Input_GetDeviceNumber(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.VBVMR_Input_GetDeviceNumber,"Int") 
        if(errLevel<0)
            Throw, Exception("VBVMR_Input_GetDeviceNumber returned " . errLevel, -1)
        else
            return errLevel
    }

    Input_GetDeviceDesc(p_index){
        local name, driver, device := {}
        VarSetCapacity(name, 1024)
        VarSetCapacity(driver, 4)
        DllCall(VBVMR.FUNC_ADDR.VBVMR_Input_GetDeviceDescW, "Int", p_index, "Ptr" , &driver , "Ptr", &name, "Ptr", 0, "Int")
        driver := NumGet(driver, 0, "UInt")
        device.name := name
        device.driver := (driver=3 ? "wdm" : (driver=4 ? "ks" : (driver=5 ? "asio" : "mme"))) 
        return device
    }

    IsParametersDirty(){
        return DllCall(VBVMR.VM_DLL . "\VBVMR_IsParametersDirty")
    }

    __getAddresses(){
        for fName in VBVMR.FUNC_ADDR 
            (VBVMR.FUNC_ADDR)[fName]:= DllCall("GetProcAddress", "Ptr", VBVMR.DLL, "AStr", fName, "Ptr")
    }
}