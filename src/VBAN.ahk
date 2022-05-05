class vban {
    static instream:=""
    , outstream:=""

    enable{
        set{
            return VBVMR.SetParameterFloat("vban", "Enable", value)
        }
        get{
            return VBVMR.GetParameterFloat("vban", "Enable")
        }
    }

    init(){
        VMR.vban.instream:= Array()
        VMR.vban.outstream:= Array()
        loop % VBVMR.VBANINCOUNT
            VMR.vban.instream.Push(new VMR.vban.stream("in", A_Index))
        loop % VBVMR.VBANOUTCOUNT
            VMR.vban.outstream.Push(new VMR.vban.stream("out", A_Index))
    }
    
    class stream{
        static initiated:= 0
        __New(p_type,p_index){
            this.PARAM_PREFIX:= Format("vban.{}stream[{}]", p_type, p_index)
        }
        __Set(p_name,p_value){
            if(VMR.vban.stream.initiated) {
                if p_name contains name, ip
                    return VBVMR.SetParameterString(this.PARAM_PREFIX, p_name, p_value)
                return VBVMR.SetParameterFloat(this.PARAM_PREFIX, p_name, p_value)
            }
            
        }
        __Get(p_name){
            if(VMR.vban.stream.initiated){
                if p_name contains name, ip
                    return VBVMR.GetParameterString(this.PARAM_PREFIX, p_name)
                return VBVMR.GetParameterFloat(this.PARAM_PREFIX, p_name)
            }
        }		
    }
}