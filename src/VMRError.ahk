#Requires AutoHotkey >=2.0
#Include VMRUtils.ahk

class VMRError extends Error {

    /**.
     * The return code of the Voicemeeter function that failed
     * @type {Number}
     */
    ReturnCode := ""

    /**
     * The name of the function that threw the error
     * @type {String}
     */
    What := ""

    /**
     * An error message
     * @type {String}
     */
    Message := ""

    /**
     * Extra information about the error
     * @type {String}
     */
    Extra := ""

    /**
     * @param {Any} p_errorValue -  The error value
     * @param {String} p_funcName -  The name of the function that threw the error
     * @param {Array} p_funcParams The parameters of the function that threw the error
     */
    __New(p_errorValue, p_funcName, p_funcParams*) {
        this.What := p_funcName
        this.Extra := p_errorValue
        this.Message := "VMR failure in " p_funcName "(" VMRUtils.Join(p_funcParams, ", ") ")"

        if (p_errorValue is Error) {
            this.Extra := "Inner error message (" p_errorValue.Message ")"
        }
        else if (IsNumber(p_errorValue)) {
            this.ReturnCode := p_errorValue
            this.Extra := "VMR Return Code (" p_errorValue ")"
        }
    }
}
