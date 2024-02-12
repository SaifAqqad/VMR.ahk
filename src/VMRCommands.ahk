#Requires AutoHotkey >=2.0
#Include VBVMR.ahk

/**
 * Write-only actions that control voicemeeter
 */
class VMRCommands {

    /**
     * Restarts the Audio Engine
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    Restart() => VBVMR.SetParameterFloat("Command", "Restart", true) == 0

    /**
     * Shuts down Voicemeeter
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    Shutdown() => VBVMR.SetParameterFloat("Command", "Shutdown", true) == 0

    /**
     * Shows the Voicemeeter window
     * 
     * @param {Boolean} p_open - (Optional) `true` to show the window, `false` to hide it
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    Show(p_open := true) => VBVMR.SetParameterFloat("Command", "Show", p_open) == 0

    /**
     * Locks the Voicemeeter UI
     * 
     * @param {number} p_state - (Optional) `true` to lock the UI, `false` to unlock it
     * _________
     * @returns {Boolean} - true if the command was successful
     */
    Lock(p_state := true) => VBVMR.SetParameterFloat("Command", "Lock", p_state) == 0

    /**
     * Ejects the recorder's cassette
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    Eject() => VBVMR.SetParameterFloat("Command", "Eject", true) == 0

    /**
     * Resets all voicemeeeter configuration
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    Reset() => VBVMR.SetParameterFloat("Command", "Reset", true) == 0

    /**
     * Saves the current configuration to a file
     * 
     * @param {String} p_filePath - The path to save the configuration to
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    Save(p_filePath) => VBVMR.SetParameterString("Command", "Save", p_filePath) == 0

    /**
     * Loads configuration from a file
     * 
     * @param {String} p_filePath - The path to load the configuration from
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    Load(p_filePath) => VBVMR.SetParameterString("Command", "Load", p_filePath) == 0

    /**
     * Shows the VBAN chat dialog
     * 
     * @param {Boolean} p_show - (Optional) `true` to show the dialog, `false` to hide it
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    ShowVBANChat(p_show := true) => VBVMR.SetParameterFloat("Command", "dialogshow.VBANCHAT", p_show) == 0

    /**
     * Sets a macro button's parameter
     * 
     * @param {Array} p_params - An array containing the button's one-based index and parameter name.
     * @example
     * vm.Command.Button[1, "State"] := 1
     * vm.Command.Button[1, "Trigger"] := false
     * vm.Command.Button[1, "Color"] := 8
     */
    Button[p_params*] {
        set {
            if (p_params.length() != 2)
                throw VMRError("Invalid number of parameters for Command.Button[]", "Command.Button[]", p_params*)
            return VBVMR.SetParameterFloat("Command.Button[" . (p_params[1] - 1) . "]", p_params[2], Value) == 0
        }
    }

    /**
     * Saves a bus's EQ settings to a file
     * 
     * @param {Number} p_busIndex - The one-based index of the bus to save
     * @param {String} p_filePath - The path to save the EQ settings to
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    SaveBusEQ(p_busIndex, p_filePath) {
        return VBVMR.SetParameterFloat("Command", "SaveBUSEQ[" p_busIndex - 1 "]", p_filePath) == 0
    }

    /**
     * Loads a bus's EQ settings from a file
     * 
     * @param {Number} p_busIndex - The one-based index of the bus to load
     * @param {String} p_filePath - The path to load the EQ settings from
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    LoadBusEQ(p_busIndex, p_filePath) {
        return VBVMR.SetParameterFloat("Command", "LoadBUSEQ[" p_busIndex - 1 "]", p_filePath) == 0
    }

    /**
     * Saves a strip's EQ settings to a file
     * 
     * @param {Number} p_stripIndex - The one-based index of the strip to save
     * @param {String} p_filePath - The path to save the EQ settings to
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    SaveStripEQ(p_stripIndex, p_filePath) {
        return VBVMR.SetParameterFloat("Command", "SaveStripEQ[" p_stripIndex - 1 "]", p_filePath) == 0
    }

    /**
     * Loads a strip's EQ settings from a file
     * 
     * @param {Number} p_stripIndex - The one-based index of the strip to load
     * @param {String} p_filePath - The path to load the EQ settings from
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    LoadStripEQ(p_stripIndex, p_filePath) {
        return VBVMR.SetParameterFloat("Command", "LoadStripEQ[" p_stripIndex - 1 "]", p_filePath) == 0
    }

    /**
     * Recalls a Preset Scene
     * 
     * @param {String | Number} p_preset - The name of the preset to recall or its one-based index
     * __________
     * @returns {Boolean} - true if the command was successful
     */
    RecallPreset(p_preset) {
        if(IsNumber(p_preset))
            return VBVMR.SetParameterFloat("Command", "Preset[" p_preset - 1 "].Recall", 1) == 0
        else
            return VBVMR.SetParameterString("Command", "RecallPreset", p_preset) == 0
    }
}
