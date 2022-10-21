class BusStrip {
    static BUS_COUNT:=0
    , BUS_LEVEL_COUNT:=0
    , BusDevices:=Array()
    , STRIP_COUNT:=0
    , STRIP_LEVEL_COUNT:=0
    , StripDevices:=Array()
    , BUS_STRIP_NAMES:=
    ( Join LTrim ; ahk
        {
            1: {
                "Bus": [
                    "A",
                    "B"
                ],
                "Strip": [
                    "Input #1",
                    "Input #2",
                    "Virtual Input #1"
                ]
            },
            2: {
                "Bus": [
                    "A1",
                    "A2",
                    "A3",
                    "B1",
                    "B2"
                ],
                "Strip": [
                    "Input #1",
                    "Input #2",
                    "Input #3",
                    "Virtual Input #1",
                    "Virtual Input #2"
                ]
            },
            3: {
                "Bus": [
                    "A1",
                    "A2",
                    "A3",
                    "A4",
                    "A5",
                    "B1",
                    "B2",
                    "B3"
                ],
                "Strip": [
                    "Input #1",
                    "Input #2",
                    "Input #3",
                    "Input #4",
                    "Input #5",
                    "Virtual Input #1",
                    "Virtual Input #2",
                    "Virtual Input #3"
                ]
            }
        }
    )
    , initiated:=0
    
    __Set(p_name, p_value, p_sec_value:=""){
        if(VMR.BusStrip.initiated && this.BUS_STRIP_ID){
            switch p_name {
                case "gain":
                    return Format("{:.1f}",this.setParameter(p_name, max(-60.0, min(p_value, this.gain_limit))))
                case "limit":
                    return Format("{:.1f}",this.setParameter(p_name, max(-40.0, min(p_value, 12.0))))
                case "device":
                    if(IsObject(p_value))
                        return this.__setDevice(p_value)
                    if(!p_value)
                        return this.__setDevice({name:"",driver:"wdm"})
                    driver:= p_sec_value? p_value : "wdm"
                    name:= p_sec_value? p_sec_value : p_value
                    return this.__setDevice(this.__getDeviceObj(name,driver))
                case "mute":
                    if(p_value = -1)
                        p_value:= !this.mute
            }
            return this.setParameter(p_name,p_value)
        }
    }

    __Get(p_name){
        if(VMR.BusStrip.initiated && this.BUS_STRIP_ID){
            switch p_name {
                case "gain","limit":
                    return Format("{:.1f}",this.getParameter(p_name))
                case "device":
                    return this.getParameter("device.name")
            }
            return this.getParameter(p_name)
        }
    }

    __New(p_type){
        this.BUS_STRIP_TYPE := p_type
        this.level := Array()
        this.LEVEL_INDEX := Array()
        this.gain_limit:= 12.0
        if (p_type="Strip") {
            this.BUS_STRIP_INDEX := VMR.BusStrip.STRIP_COUNT++
            loop % this.isPhysical() ? 2 : 8 
                this.LEVEL_INDEX.Push(VMR.BusStrip.STRIP_LEVEL_COUNT++)
        }else{
            this.BUS_STRIP_INDEX := VMR.BusStrip.BUS_COUNT++
            loop 8 
                this.LEVEL_INDEX.Push(VMR.BusStrip.BUS_LEVEL_COUNT++)
        }
        this.BUS_STRIP_ID := this.BUS_STRIP_TYPE . "[" . this.BUS_STRIP_INDEX . "]"
        this.name := VMR.BusStrip.BUS_STRIP_NAMES[VBVMR.VM_TYPE][this.BUS_STRIP_TYPE][this.BUS_STRIP_INDEX+1]
    }

    getGainPercentage(){
        return Format("{:.2f}",this.getPercentage(this.gain))
    }

    getPercentage(dB){
        min_s := 10**(-60/20), max_s := 10**(0/20)
        return ((10**(dB/20))-min_s)/(max_s-min_s)*100
    }

    setParameter(parameter, value){
        local func
        if parameter contains device,FadeTo,Label,FadeBy,AppGain,AppMute
            func:= "setParameterString"
        else
            func:= "setParameterFloat"
        return (VBVMR)[func](this.BUS_STRIP_ID, parameter, value)
    }

    getParameter(parameter){
        local func
        if parameter contains device,FadeTo,Label,FadeBy,AppGain,AppMute
            func:= "getParameterString"
        else
            func:= "getParameterFloat"
        return (VBVMR)[func](this.BUS_STRIP_ID, parameter)
    }

    ; Returns 1 if the bus/strip is a physical one (Hardware bus/strip), 0 otherwise
    isPhysical(){
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

    __setDevice(device){
        if (!this.isPhysical())
            return -4
        if device.driver not in wdm,mme,ks,asio
            return -5
        return this.setParameter("device." . device.driver,device.name)
    }
    
    __getDeviceObj(substring,driver){
        local devices:= VMR.BusStrip[this.BUS_STRIP_TYPE . "Devices"]
        for i in devices 
            if (devices[i].driver = driver && InStr(devices[i].name, substring))
                return devices[i]
        return {name:"",driver:"wdm"}
    }

    __updateLevel(){
        local type := this.BUS_STRIP_TYPE="Bus" ? 3 : 1
        loop % this.LEVEL_INDEX.Length() {
            level := VBVMR.GetLevel(type, this.LEVEL_INDEX[A_Index])
            this.level[A_Index] := Max(Round(20 * Log(level)), -999)
        }
    }
}