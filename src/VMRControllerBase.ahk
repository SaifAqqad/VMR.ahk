#Requires AutoHotkey >=2.0
#Include VBVMR.ahk
#Include VMRAsyncOp.ahk

class VMRControllerBase {
    __New(p_id, p_stringParamChecker) {
        this.DefineProp("Id", { Get: (*) => p_id })
        this.DefineProp("StringParamChecker", { Call: p_stringParamChecker })
    }

    /**
     * @private - Internal method
     * @description Implements a default property getter, this is invoked when using the object access syntax.
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Array} p_params - An extra param passed when using bracket syntax with a normal prop access (`bus.device["sr"]`).
     * __________
     * @returns {Any} The value of the parameter.
     * @throws {VMRError} - If an internal error occurs.
     */
    __Get(p_key, p_params) {
        if (p_params.Length > 0) {
            for param in p_params {
                p_key .= IsNumber(param) ? "[" param "]" : "." param
            }
        }

        return this.GetParameter(p_key)
    }

    /**
     * @private - Internal method
     * @description Implements a default property setter, this is invoked when using the object access syntax.
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Array} p_params - An extra param passed when using bracket syntax with a normal prop access. `bus.device["wdm"] := "Headset"`
     * @param {Any} p_value - The value of the parameter.
     * __________
     * @returns {Boolean} - `true` if the parameter was set successfully.
     * @throws {VMRError} - If an internal error occurs.
     */
    __Set(p_key, p_params, p_value) {
        if (p_params.Length > 0) {
            for param in p_params {
                p_key .= IsNumber(param) ? "[" param "]" : "." param
            }
        }

        return this.SetParameter(p_key, p_value) == 0
    }

    /**
     * Implements a default indexer.
     * this is invoked when using the bracket access syntax.
     * 
     * @param {String} p_key - The name of the parameter.
     * __________
     * @type {Any} - The value of the parameter.
     * @throws {VMRError} - If an internal error occurs.
     */
    __Item[p_key] {
        get => this.GetParameter(p_key)
        set => this.SetParameter(p_key, Value)
    }

    /**
     * Sets the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * @param {Any} p_value - The value of the parameter.
     * __________
     * @returns {Boolean} - True if the parameter was set successfully.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    SetParameter(p_name, p_value) {
        local vmrFunc := this.StringParamChecker(p_name) ? VBVMR.SetParameterString.Bind(VBVMR) : VBVMR.SetParameterFloat.Bind(VBVMR)

        return vmrFunc.Call(this.Id, p_name, p_value) == 0
    }

    /**
     * Returns the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * __________
     * @returns {Any} - The value of the parameter.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    GetParameter(p_name) {
        local vmrFunc := this.StringParamChecker(p_name) ? VBVMR.GetParameterString.Bind(VBVMR) : VBVMR.GetParameterFloat.Bind(VBVMR)

        return vmrFunc.Call(this.Id, p_name) == 0
    }
}
