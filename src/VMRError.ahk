#Requires AutoHotkey >=2.0

class VMRError extends Error {
    __New(errorValue, funcName) {
        this.What := funcName
        this.Message := "VMR failure in " . funcName
        this.returnCode := ""

        if (errorValue is Error) {
            errorValue := "DllCall Error (" . errorValue.Message . ")"
        } else if (IsNumber(errorValue)) {
            this.returnCode := errorValue
            errorValue := "VMR Return Code (" . errorValue . ")"
        }

        this.Extra := errorValue
    }
}