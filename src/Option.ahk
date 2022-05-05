class option_base {
    
    __Set(p_name, p_value){
        return VBVMR.SetParameterFloat("Option", p_name, p_value)
    }
    
    __Get(p_name){
        return VBVMR.GetParameterFloat("Option", p_name)
    }
    
    delay(busNum, p_delay := "") {
        ; in keeping with the 1 indexed class...
        busNum := busNum - 1
        if(p_delay == "") {
            ; get the value
            return VBVMR.GetParameterFloat("Option", "delay[" . busNum . "]")
        }
        else {
            ; set it to a new value
            return VBVMR.SetParameterFloat("Option", "delay[" . busNum . "]", Min(Max(p_delay,0),500))
        }
        
    }
}