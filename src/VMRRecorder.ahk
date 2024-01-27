#Requires AutoHotkey >=2.0

#Include VMRControllerBase.ahk
#Include VMRUtils.ahk

class VMRRecorder extends VMRControllerBase {
    static _stringParameters := ["load"]

    __New(p_type) {
        super.__New("recorder", (_, p) => VMRUtils.IndexOf(VMRRecorder._stringParameters, p) != -1)
        this.DefineProp("TypeInfo", { Get: (*) => p_type })
    }

    /**
     * Arms the specified bus for recording, switching the recording mode to `1` (bus).
     * Or returns the state of the specified bus (whether it's armed or not).
     * @param {number} p_index - The bus's one-based index.
     * __________
     * @type {boolean} - Whether the bus is armed or not.
     * 
     * @example <caption>Arm the first bus for recording.</caption>
     * VMR.Recorder.ArmBus[1] := true
     */
    ArmBus[p_index] {
        get {
            return this.GetParameter("ArmBus(" (p_index - 1) ")")
        }
        set {
            this.SetParameter("mode.recbus", true)
            this.SetParameter("ArmBus(" . (p_index - 1) . ")", Value)
        }
    }

    /**
     * Arms the specified strip for recording, switching the recording mode to `0` (strip).
     * Or returns the state of the specified strip (whether it's armed or not).
     * @param {number} p_index - The strip's one-based index.
     * __________
     * @type {boolean} - Whether the strip is armed or not.
     * 
     * @example <caption>Arm a strip for recording.</caption>
     * VMR.Recorder.ArmStrip[4] := true
     */
    ArmStrip[p_index] {
        get {
            return this.GetParameter("ArmStrip(" (p_index - 1) ")")
        }
        set {
            this.SetParameter("mode.recbus", false)
            this.SetParameter("ArmStrip(" . (p_index - 1) . ")", Value)
        }
    }

    /**
     * Arms the specified strips for recording, switching the recording mode to `0` (strip) and disarming any armed strips.
     * @param {Array} p_strips - The strips' one-based indices.
     * 
     * @example <caption>Arm strips 1, 2, and 4 for recording.</caption>
     * VMR.Recorder.ArmStrips(1, 2, 4)
     */
    ArmStrips(p_strips*) {
        loop this.TypeInfo.StripCount
            this.ArmStrip[A_Index] := false

        for i in p_strips
            this.ArmStrip[i] := true
    }

    Load(p_path) => this.SetParameter("load", p_path)
}
