#Requires AutoHotkey >=2.0

class VMRError extends Error {
    static MessageFormat := "
    (
    VMR Error:
        Function: {s}
        Error: {s}
        Line: {s}
    )"

    __New(funcName, errorValue, lineNumber) {
        if (errorValue is Error) {
            errorValue := "DllCall Error (" . errorValue.Message . ")"
        } else if (IsNumber(errorValue)) {
            errorValue := "VMR Return Code (" . errorValue . ")"
        }

        this.Message := Format(VMRError.MessageFormat, funcName, errorValue, lineNumber)
    }
}