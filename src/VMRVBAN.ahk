#Requires AutoHotkey >=2.0

#Include VMRControllerBase.ahk

class VMRVBAN extends VMRControllerBase {

    /**
     * Controls a VBAN input stream
     * @type {VMRControllerBase}
     */
    Instream[p_index] {
        get {
            return this._instreams.Get(p_index)
        }
    }

    /**
     * Controls a VBAN output stream
     * @type {VMRControllerBase}
     */
    Outstream[p_index] {
        get {
            return this._outstreams.Get(p_index)
        }
    }

    __New(p_type) {
        super.__New("vban", (*) => false)
        this.DefineProp("TypeInfo", { Get: (*) => p_type })

        local stringParams := ["name", "ip"]
        local streamStringParamChecker := (p) => VMRUtils.IndexOf(stringParams, p) != -1

        local instreams := Array(), outstreams := Array()
        loop p_type.VbanCount {
            instreams.Push(VMRControllerBase("vban.instream[" A_Index - 1 "]", streamStringParamChecker))
            outstreams.Push(VMRControllerBase("vban.outstream[" A_Index - 1 "]", streamStringParamChecker))
        }

        this.DefineProp("_instreams", { Get: (*) => instreams })
        this.DefineProp("_outstreams", { Get: (*) => outstreams })
    }
}
