#Requires AutoHotkey >=2.0

#Include VBVMR.ahk

class VMRMacroButton {
    static EXECUTABLE := "VoicemeeterMacroButtons.exe"

    /**
     * Run the Voicemeeter Macro Buttons application.
     * 
     * @returns {void} 
     */
    Run() => Run(VBVMR.DLL_PATH "\" VMRMacroButton.EXECUTABLE, VBVMR.DLL_PATH)

    /**
     * Shows/Hides the Voicemeeter Macro Buttons application.
     * @param {Boolean} p_show - Whether to show or hide the application
     */
    Show(p_show := true) {
        if (p_show) {
            if (!WinExist("ahk_exe " VMRMacroButton.EXECUTABLE))
                this.Run(), Sleep(500)
            WinShow("ahk_exe " VMRMacroButton.EXECUTABLE)
        }
        else {
            WinHide("ahk_exe " VMRMacroButton.EXECUTABLE)
        }
    }

    /**
     * Sets the status of a given button.
     * @param {Number} p_index - The one-based index of the button
     * @param {Number} p_value - The value to set
     * - `0`: Off
     * - `1`: On
     * @param {Number} p_bitMode - The type of the returned value
     * - `0`: button-state
     * - `2`: displayed-state
     * - `3`: trigger-state
     * __________
     * @returns {Number} - The status of the button
     * - `0`: Off
     * - `1`: On
     * @throws {VMRError} - If an internal error occurs
     */
    SetStatus(p_index, p_value, p_bitMode := 0) => VBVMR.MacroButton_SetStatus(p_index - 1, p_value, p_bitMode)

    /**
     * Gets the status of a given button.
     * @param {Number} p_index - The one-based index of the button
     * @param {Number} p_bitMode - The type of the returned value
     * - `0`: button-state
     * - `2`: displayed-state
     * - `3`: trigger-state
     * __________
     * @returns {Number} - The status of the button
     * - `0`: Off
     * - `1`: On
     * @throws {VMRError} - If an internal error occurs
     */
    GetStatus(p_index, p_bitMode := 0) => VBVMR.MacroButton_GetStatus(p_index - 1, p_bitMode)
}
