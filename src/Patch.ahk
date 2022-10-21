class PatchBase {
    __Set(p_name, p_value){
        return VBVMR.SetParameterFloat("Patch", p_name, p_value)
    }
    
    __Get(p_name){
        return VBVMR.GetParameterFloat("Patch", p_name)
    }
}