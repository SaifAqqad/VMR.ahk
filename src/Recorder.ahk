class recorder_base {
    
    __Set(p_name,p_value){
        local type:= "Float"
        if p_name contains load
            type:= "String"
        return (VBVMR)["SetParameter" type]("Recorder", p_name, p_value)
    }

    __Get(p_name){
        local type:= "Float"
        if p_name contains load
            type:= "String"
        return (VBVMR)["GetParameter" type]("Recorder", p_name)
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