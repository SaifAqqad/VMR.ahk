#Requires AutoHotkey >=2.0
#Include VMRError.ahk

/**
 * #### A static wrapper class for the Voicemeeter Remote DLL.
 * 
 * Must be initialized by calling `Init()` before using any of its static methods.
 */
class VBVMR {
    static REG_KEY := Format("HKLM\Software{}\Microsoft\Windows\CurrentVersion\Uninstall\VB:Voicemeeter {17359A74-1236-5467}", A_Is64bitOS ? "\WOW6432Node" : "")
    static DLL := ""
    static FUNC := {
        Login: 0,
        Logout: 0,
        SetParameterFloat: 0,
        SetParameterStringW: 0,
        GetParameterFloat: 0,
        GetParameterStringW: 0,
        GetVoicemeeterType: 0,
        GetLevel: 0,
        Output_GetDeviceNumber: 0,
        Output_GetDeviceDescW: 0,
        Input_GetDeviceNumber: 0,
        Input_GetDeviceDescW: 0,
        IsParametersDirty: 0,
        MacroButton_IsDirty: 0,
        MacroButton_GetStatus: 0,
        MacroButton_SetStatus: 0,
        GetMidiMessage: 0,
        SetParameters: 0,
        SetParametersW: 0
    }

    /**
     * #### Initializes the VBVMR class by loading the Voicemeeter Remote DLL and getting the addresses of all needed functions.
     * If the DLL is already loaded, it returns immediately.
     * 
     * @param {String} p_path - (Optional) The path to the Voicemeeter Remote DLL. If not specified, it will try to find it in the registry.
     * 
     * ----
     * @throws {VMRError} - If the DLL is not found in the specified path or if voicemeeter is not installed.
     */
    static Init(p_path := "") {
        if (VBVMR.DLL != "")
            return

        local dllPath := p_path ? p_path : VBVMR._GetDLLPath()
        dllPath .= A_PtrSize = 8 ? "\VoicemeeterRemote64.dll" : "\VoicemeeterRemote.dll"

        if (!FileExist(dllPath))
            throw VMRError("Voicemeeter is not installed in the path :`n" . dllPath, VBVMR.Init.Name)

        ; Load the voicemeeter DLL
        VBVMR.DLL := DllCall("LoadLibrary", "Str", dllPath, "Ptr")

        ; Get the addresses of all needed function
        for fName in VBVMR.FUNC.OwnProps() {
            VBVMR.FUNC.%fName% := DllCall("GetProcAddress", "Ptr", VBVMR.DLL, "AStr", "VBVMR_" . fName, "Ptr")
        }
    }

    static _GetDLLPath() {
        local value := "", dir := ""
        try
            value := RegRead(VBVMR.REG_KEY, "UninstallString")
        catch OSError
            Throw VMRError("Failed to retrieve the installation path of Voicemeeter", VBVMR._GetDLLPath.Name)

        SplitPath(value, , &dir)
        return dir
    }

    /**
     * #### Opens Communication Pipe With Voicemeeter.
     * 
     * @returns {Number}
     * - `0` : OK (no error).
     * - `1` : OK but Voicemeeter Application not launched
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static Login() {
        local result

        try result := DllCall(VBVMR.FUNC.Login)
        catch Error as err
            throw VMRError(err, VBVMR.Login.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.Login.Name)

        return result
    }

    /**
     * #### Closes Communication Pipe With Voicemeeter.
     * 
     * @returns {Number}
     * - `0` : OK (no error).
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static Logout() {
        local result

        try result := DllCall(VBVMR.FUNC.Logout)
        catch Error as err
            throw VMRError(err, VBVMR.Logout.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.Logout.Name)

        return result
    }


    /**
     * #### Sets the value of a float (numeric) parameter.
     * 
     * @param {String} p_prefix - The prefix of the parameter, usually the name of the bus/strip (ex: `Bus[2]`).
     * @param {String} p_parameter - The name of the parameter (ex: `gain`).
     * @param {Number} p_value - The value to set.
     * 
     * ----
     * @returns {Number}
     * - `0` : OK (no error).
     * 
     * @throws {VMRError} - If the parameter is not found, or an internal error occurs.
     */
    static SetParameterFloat(p_prefix, p_parameter, p_value) {
        local result

        try result := DllCall(VBVMR.FUNC.SetParameterFloat, "AStr", p_prefix . "." . p_parameter, "Float", p_value, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.SetParameterFloat.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.SetParameterFloat.Name)

        return result
    }

    /**
     * #### Sets the value of a string parameter.
     * 
     * @param {String} p_prefix - The prefix of the parameter, usually the name of the bus/strip (ex: `Strip[1]`).
     * @param {String} p_parameter - The name of the parameter (ex: `name`).
     * @param {String} p_value - The value to set.
     * 
     * ----
     * @returns {Number}
     * - `0` : OK (no error).
     * 
     * @throws {VMRError} - If the parameter is not found, or an internal error occurs.
     */
    static SetParameterString(p_prefix, p_parameter, p_value) {
        local result

        try result := DllCall(VBVMR.FUNC.SetParameterStringW, "AStr", p_prefix . "." . p_parameter, "WStr", p_value, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.SetParameterString.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.SetParameterString.Name)

        return result
    }


    /**
     * #### Returns the value of a float (numeric) parameter.
     * 
     * @param {String} p_prefix - The prefix of the parameter, usually the name of the bus/strip (ex: `Bus[2]`).
     * @param {String} p_parameter - The name of the parameter (ex: `gain`).
     * 
     * ----
     * @returns {Number} - The value of the parameter.
     * 
     * @throws {VMRError} - If the parameter is not found, or an internal error occurs.
     */
    static GetParameterFloat(p_prefix, p_parameter) {
        local result, value := Buffer(4)

        try result := DllCall(VBVMR.FUNC.GetParameterFloat, "AStr", p_prefix . "." . p_parameter, "Ptr", value, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.GetParameterFloat.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.GetParameterFloat.Name)

        value := NumGet(value, 0, "Float")
        return value
    }

    /**
     * #### Returns the value of a string parameter.
     * 
     * @param {String} p_prefix - The prefix of the parameter, usually the name of the bus/strip (ex: `Strip[1]`).
     * @param {String} p_parameter - The name of the parameter (ex: `name`).
     * 
     * ----
     * @returns {String} - The value of the parameter.
     * 
     * @throws {VMRError} - If the parameter is not found, or an internal error occurs.
     */
    static GetParameterString(p_prefix, p_parameter) {
        local result, value := Buffer(1024)

        try result := DllCall(VBVMR.FUNC.GetParameterFloat, "AStr", p_prefix . "." . p_parameter, "Ptr", value, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.GetParameterString.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.GetParameterString.Name)

        return StrGet(value, 512)
    }

    /**
     * #### Returns the level of a single bus/strip channel.
     * 
     * @param {Number} p_type - The type of the returned level (`0`: pre-fader, `1`: post-fader, `2`: post-mute, `3`: output-levels).
     * @param {Number} p_channel - The channel index (ex: `1`), channels Indices are different depending on the type of voiceemeeter running.
     * 
     * Channel Indices are incremented from the left to right (On the UI), starting at `0`, Buses and Strips have separate Indices.
     * 
     * Physical (hardware) strips have 2 channels (left, right), Buses and virtual strips have 8 channels.
     * 
     * ----
     * @returns {Number} - The level of the requested channel.
     * 
     * @throws {VMRError} - If the channel index is invalid, or an internal error occurs.
     */
    static GetLevel(p_type, p_channel) {
        local result, level := Buffer(4)

        try result := DllCall(VBVMR.FUNC.GetLevel, "Int", p_type, "Int", p_channel, "Ptr", level)
        catch Error as err
            throw VMRError(err, VBVMR.GetLevel.Name)

        if (result < 0) {
            SetTimer(unset, 0)
            return
        }

        return NumGet(level, 0, "Float")
    }

    /**
     * #### Returns the type of voicemeeter running.
     * 
     * @returns {Number}
     * - `1` : Voicemeeter
     * - `2` : Voicemeeter Banana
     * - `3` : Voicemeeter Potato
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static GetVoicemeeterType() {
        local result, vtype := Buffer(4)

        try result := DllCall(VBVMR.FUNC.GetVoicemeeterType, "Ptr", vtype, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.GetVoicemeeterType.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.GetVoicemeeterType.Name)

        return NumGet(vtype, 0, "Int")
    }

    /**
     * #### Returns the number of Output Devices available on the system.
     * 
     * @returns {Number} - The number of output devices.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static Output_GetDeviceNumber() {
        local result

        try result := DllCall(VBVMR.FUNC.Output_GetDeviceNumber, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.Output_GetDeviceNumber.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.Output_GetDeviceNumber.Name)

        return result
    }

    /**
     * #### Returns the Descriptor of an output device.
     * 
     * @param {Number} p_index - The index of the device (zero-based).
     * 
     * ----
     * @returns {{name, driver}} - An object containing the `name` and `driver` of the device.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static Output_GetDeviceDesc(p_index) {
        local result, name := Buffer(1024),
            driver := Buffer(4)

        try result := DllCall(VBVMR.FUNC.Output_GetDeviceDescW, "Int", p_index, "Ptr", driver, "Ptr", name, "Ptr", 0, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.Output_GetDeviceDesc.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.Output_GetDeviceDesc.Name)

        name := StrGet(name, 512)
        switch NumGet(driver, 0, "UInt") {
            case 3:
                driver := "wdm"
            case 4:
                driver := "ks"
            case 5:
                driver := "asio"
            default:
                driver := "mme"
        }

        return { name: name, driver: driver }
    }

    /**
     * #### Returns the number of Input Devices available on the system.
     * 
     * @returns {Number} - The number of input devices.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static Input_GetDeviceNumber() {
        local result

        try result := DllCall(VBVMR.FUNC.Input_GetDeviceNumber, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.Input_GetDeviceNumber.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.Input_GetDeviceNumber.Name)

        return result
    }

    /**
     * #### Returns the Descriptor of an input device.
     * 
     * @param {Number} p_index - The index of the device (zero-based).
     * 
     * ----
     * @returns {{name, driver}} - An object containing the `name` and `driver` of the device.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static Input_GetDeviceDesc(p_index) {
        local result, name := Buffer(1024),
            driver := Buffer(4)

        try result := DllCall(VBVMR.FUNC.Input_GetDeviceDescW, "Int", p_index, "Ptr", driver, "Ptr", name, "Ptr", 0, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.Input_GetDeviceDesc.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.Input_GetDeviceDesc.Name)

        name := StrGet(name, 512)
        switch NumGet(driver, 0, "UInt") {
            case 3:
                driver := "wdm"
            case 4:
                driver := "ks"
            case 5:
                driver := "asio"
            default:
                driver := "mme"
        }

        return { name: name, driver: driver }
    }

    /**
     * #### Checks if any parameters have changed.
     * 
     * @returns {Number}
     * - `0` : No change
     * - `1` : Some parameters have changed
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static IsParametersDirty() {
        local result

        try result := DllCall(VBVMR.FUNC.IsParametersDirty)
        catch Error as err
            throw VMRError(err, VBVMR.IsParametersDirty.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.IsParametersDirty.Name)

        return result
    }

    /**
     * #### Returns the current status of a given button.
     * 
     * @param {Number} p_logicalButton - The index of the button (zero-based).
     * @param {Number} p_bitMode - The type of the returned value (`0`: button-state, `2`: displayed-state, `3`: trigger-state).
     * 
     * ----
     * @returns {Number} - The status of the button
     * - `0`: Off
     * - `1`: On
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static MacroButton_GetStatus(p_logicalButton, p_bitMode) {
        local pValue := Buffer(4)

        try errLevel := DllCall(VBVMR.FUNC.MacroButton_GetStatus, "Int", p_logicalButton, "Ptr", pValue, "Int", p_bitMode, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.MacroButton_GetStatus.Name)

        if (errLevel < 0)
            throw VMRError(errLevel, VBVMR.MacroButton_GetStatus.Name)

        return NumGet(pValue, 0, "Float")
    }

    /**
     * #### Sets the status of a given button.
     * 
     * @param {Number} p_logicalButton - The index of the button (zero-based).
     * @param {Number} p_value - The value to set (`0`: Off, `1`: On).
     * @param {Number} p_bitMode - The type of the returned value (`0`: button-state, `2`: displayed-state, `3`: trigger-state).
     * 
     * ----
     * @returns {Number} - The status of the button
     * - `0`: Off
     * - `1`: On
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static MacroButton_SetStatus(p_logicalButton, p_value, p_bitMode) {
        local result

        try result := DllCall(VBVMR.FUNC.MacroButton_SetStatus, "Int", p_logicalButton, "Float", p_value, "Int", p_bitMode, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.MacroButton_SetStatus.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.MacroButton_SetStatus.Name)

        return p_value
    }

    /**
     * #### Checks if any Macro Buttons states have changed.
     * 
     * @returns {Number} 
     *  - `0` : No change 
     *  - `> 0` : Some buttons have changed
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static MacroButton_IsDirty() {
        local result

        try result := DllCall(VBVMR.FUNC.MacroButton_IsDirty)
        catch Error as err
            throw VMRError(err, VBVMR.MacroButton_IsDirty.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.MacroButton_IsDirty.Name)

        return result
    }

    /**
     * #### Returns the MIDI message from a MIDI input device used by Voicemeeter MIDI mapping.
     * 
     * @returns {Array} - `[0xF0, 0xFF, ...]` An array of hex-formatted bytes that compose one or more MIDI messages. a single message is usually 2 or 3 bytes long.
     * @returns {String} `""` No MIDI messages available.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static GetMidiMessage() {
        local result, data := Buffer(1024),
            messages := []

        try result := DllCall(VBVMR.FUNC.GetMidiMessage, "Ptr", data, "Int", 1024)
        catch Error as err
            throw VMRError(err, VBVMR.GetMidiMessage.Name)

        if (result == -1)
            throw VMRError(result, VBVMR.GetMidiMessage.Name)

        if (result < 1)
            return ""

        loop (result) {
            messages.Push(Format("0x{:X}", NumGet(data, A_Index - 1, "UChar")))
        }

        return messages
    }

    /**
     * #### Sets one or several parameters using a script.
     * 
     * @param {String} p_script - The script to execute (must be less than `48kb`).
     * 
     * Scripts can contain one or more parameter changes, changes can be seperated by a new line, `;` or `,`.
     * 
     * Indices inside the script are zero-based.
     * 
     * ----
     * 
     * @returns {Number} 
     *  - `0` : OK (no error) 
     *  - `> 0` : Number of the line causing an error
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    static SetParameters(p_script) {
        local result

        try result := DllCall(VBVMR.FUNC.SetParametersW, "WStr", p_script, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.SetParameters.Name)

        if (result < 0)
            return ""

        return result
    }
}