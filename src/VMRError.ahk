#Requires AutoHotkey >=2.0

class VMRError extends Error {
    __New(p_errorValue, p_funcName) {
        this.returnCode := ""
        this.What := p_funcName
        this.Extra := p_errorValue
        this.Message := "VMR failure in " . p_funcName

        if (p_errorValue is Error) {
            this.Extra := "Inner error message (" . p_errorValue.Message . ")"
        } else if (IsNumber(p_errorValue)) {
            this.returnCode := p_errorValue
            this.Extra := "VMR Return Code (" . p_errorValue . ")"
        }
    }
}