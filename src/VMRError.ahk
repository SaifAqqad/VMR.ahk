#Requires AutoHotkey >=2.0

class VMRError extends Error {
    __New(errorValue, funcName) {
        if (errorValue is Error) {
            errorValue := "DllCall Error (" . errorValue.Message . ")"
        } else if (IsNumber(errorValue)) {
            errorValue := "VMR Return Code (" . errorValue . ")"
        }

        this.What := funcName
        this.Message := "VMR failure in " . funcName
        this.Extra := errorValue
    }
}