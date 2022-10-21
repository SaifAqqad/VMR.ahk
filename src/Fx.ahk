class FXBase {

    reverb(onOff := -2) {
        switch (onOff) {
            case -2: ;getParam
                return VBVMR.GetParameterFloat("Fx.Reverb", "on")
            case -1: ;invert state
                onOff := !VBVMR.GetParameterFloat("Fx.Reverb", "on")
        }
        return VBVMR.SetParameterFloat("Fx.Reverb","on", onOff)
    }

    delay(onOff := -2) {
        switch (onOff) {
            case -2: ;getParam
                return VBVMR.GetParameterFloat("Fx.delay", "on")
            case -1: ;invert state
                onOff := !VBVMR.GetParameterFloat("Fx.delay", "on")
        }
        return VBVMR.SetParameterFloat("Fx.delay","on", onOff)
    }
}