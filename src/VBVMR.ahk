#Requires AutoHotkey >=2.0

#Include VMRError.ahk
#Include VMRConsts.ahk
#Include VMRDevice.ahk

/**
 * A static wrapper class for the Voicemeeter Remote DLL.
 * 
 * Must be initialized by calling {@link VBVMR.Init|`Init()`} before using any of its static methods.
 */
class VBVMR {
    static FUNC := {
        Login: 0,
        Logout: 0,
        SetParameterFloat: 0,
        SetParameterStringW: 0,
        GetParameterFloat: 0,
        GetParameterStringW: 0,
        GetVoicemeeterType: 0,
        GetVoicemeeterVersion: 0,
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
    static DLL := "", DLL_PATH := "", LOGGED_IN := false

    /**
     * Initializes the VBVMR class by loading the Voicemeeter Remote DLL and getting the addresses of all needed functions.
     * If the DLL is already loaded, it returns immediately.
     * @param {String} p_path - (Optional) The path to the Voicemeeter Remote DLL. If not specified, it will be looked up in the registry.
     * __________
     * @throws {VMRError} - If the DLL is not found in the specified path or if voicemeeter is not installed.
     */
    static Init(p_path := "") {
        if (VBVMR.DLL != "")
            return

        VBVMR.DLL_PATH := p_path ? p_path : VBVMR._GetDLLPath()
        local dllPath := VBVMR.DLL_PATH "\" VMRConsts.DLL_FILE

        if (!FileExist(dllPath))
            throw VMRError("Voicemeeter is not installed in the path :`n" . dllPath, VBVMR.Init.Name, p_path)

        ; Load the voicemeeter DLL
        VBVMR.DLL := DllCall("LoadLibrary", "Str", dllPath, "Ptr")

        ; Get the addresses of all needed function
        for (fName in VBVMR.FUNC.OwnProps()) {
            VBVMR.FUNC.%fName% := DllCall("GetProcAddress", "Ptr", VBVMR.DLL, "AStr", "VBVMR_" . fName, "Ptr")
        }
    }

    /**
     * @private - Internal method
     * @description Looks up the installation path of Voicemeeter in the registry.
     * __________
     * @returns {String} - The installation path of Voicemeeter.
     */
    static _GetDLLPath() {
        local value := "", dir := ""
        try
            value := RegRead(VMRConsts.REGISTRY_KEY, "UninstallString")
        catch OSError
            throw VMRError("Failed to retrieve the installation path of Voicemeeter", VBVMR._GetDLLPath.Name)

        SplitPath(value, , &dir)
        return dir
    }

    /**
     * Opens a Communication Pipe With Voicemeeter.
     * __________
     * @returns {Number}
     * - `0` : OK (no error).
     * - `1` : OK but Voicemeeter is not launched (need to launch it manually).
     * @throws {VMRError} - If an internal error occurs.
     */
    static Login() {
        local result := 0

        if (VBVMR.LOGGED_IN)
            return result

        try result := DllCall(VBVMR.FUNC.Login)
        catch Error as err
            throw VMRError(err, VBVMR.Login.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.Login.Name)

        VBVMR.LOGGED_IN := true
        return result
    }

    /**
     * Closes the Communication Pipe With Voicemeeter.
     * __________
     * @returns {Number}
     * - `0` : OK (no error).
     * @throws {VMRError} - If an internal error occurs.
     */
    static Logout() {
        local result := 0

        if (!VBVMR.LOGGED_IN)
            return result

        try result := DllCall(VBVMR.FUNC.Logout)
        catch Error as err
            throw VMRError(err, VBVMR.Logout.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.Logout.Name)

        VBVMR.LOGGED_IN := false
        return result
    }

    /**
     * Sets the value of a float (numeric) parameter.
     * @param {String} p_prefix - The prefix of the parameter, usually the name of the bus/strip (ex: `Bus[0]`).
     * @param {String} p_parameter - The name of the parameter (ex: `gain`).
     * @param {Number} p_value - The value to set.
     * __________
     * @returns {Number}
     * - `0` : OK (no error).
     * @throws {VMRError} - If the parameter is not found, or an internal error occurs.
     */
    static SetParameterFloat(p_prefix, p_parameter, p_value) {
        local result

        try result := DllCall(VBVMR.FUNC.SetParameterFloat, "AStr", p_prefix . "." . p_parameter, "Float", p_value, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.SetParameterFloat.Name, p_prefix, p_parameter, p_value)

        if (result < 0)
            throw VMRError(result, VBVMR.SetParameterFloat.Name, p_prefix, p_parameter, p_value)

        return result
    }

    /**
     * Sets the value of a string parameter.
     * @param {String} p_prefix - The prefix of the parameter, usually the name of the bus/strip (ex: `Strip[1]`).
     * @param {String} p_parameter - The name of the parameter (ex: `name`).
     * @param {String} p_value - The value to set.
     * __________
     * @returns {Number}
     * - `0` : OK (no error).
     * @throws {VMRError} - If the parameter is not found, or an internal error occurs.
     */
    static SetParameterString(p_prefix, p_parameter, p_value) {
        local result

        try result := DllCall(VBVMR.FUNC.SetParameterStringW, "AStr", p_prefix . "." . p_parameter, "WStr", p_value, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.SetParameterString.Name, p_prefix, p_parameter, p_value)

        if (result < 0)
            throw VMRError(result, VBVMR.SetParameterString.Name, p_prefix, p_parameter, p_value)

        return result
    }

    /**
     * Returns the value of a float (numeric) parameter.
     * @param {String} p_prefix - The prefix of the parameter, usually the name of the bus/strip (ex: `Bus[2]`).
     * @param {String} p_parameter - The name of the parameter (ex: `gain`).
     * __________
     * @returns {Number} - The value of the parameter.
     * @throws {VMRError} - If the parameter is not found, or an internal error occurs.
     */
    static GetParameterFloat(p_prefix, p_parameter) {
        local result, value := Buffer(4)

        try result := DllCall(VBVMR.FUNC.GetParameterFloat, "AStr", p_prefix . "." . p_parameter, "Ptr", value, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.GetParameterFloat.Name, p_prefix, p_parameter)

        if (result < 0)
            throw VMRError(result, VBVMR.GetParameterFloat.Name, p_prefix, p_parameter)

        value := NumGet(value, 0, "Float")
        return value
    }

    /**
     * Returns the value of a string parameter.
     * @param {String} p_prefix - The prefix of the parameter, usually the name of the bus/strip (ex: `Strip[1]`).
     * @param {String} p_parameter - The name of the parameter (ex: `name`).
     * __________
     * @returns {String} - The value of the parameter.
     * @throws {VMRError} - If the parameter is not found, or an internal error occurs.
     */
    static GetParameterString(p_prefix, p_parameter) {
        local result, value := Buffer(1024)

        try result := DllCall(VBVMR.FUNC.GetParameterStringW, "AStr", p_prefix . "." . p_parameter, "Ptr", value, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.GetParameterString.Name, p_prefix, p_parameter)

        if (result < 0)
            throw VMRError(result, VBVMR.GetParameterString.Name, p_prefix, p_parameter)

        return StrGet(value, 512)
    }

    /**
     * Returns the level of a single bus/strip channel.
     * @param {Number} p_type - The type of the returned level 
     * - `0`: pre-fader
     * - `1`: post-fader
     * - `2`: post-mute
     * - `3`: output-levels
     * @param {Number} p_channel - The channel's zero-based index.
     * - Channel Indices depend on the type of voiceemeeter running.
     * - Channel Indices are incremented from the left to right (On the Voicemeeter UI), starting at `0`, Buses and Strips have separate Indices (see `p_type`).
     * - Physical (hardware) strips have 2 channels (left, right), Buses and virtual strips have 8 channels.
     * __________
     * @returns {Number} - The level of the requested channel.
     * @throws {VMRError} - If the channel index is invalid, or an internal error occurs.
     */
    static GetLevel(p_type, p_channel) {
        local result, level := Buffer(4)

        try result := DllCall(VBVMR.FUNC.GetLevel, "Int", p_type, "Int", p_channel, "Ptr", level)
        catch Error as err
            throw VMRError(err, VBVMR.GetLevel.Name, p_type, p_channel)

        if (result < 0)
            return 0

        return NumGet(level, 0, "Float")
    }

    /**
     * Returns the type of Voicemeeter running.
     * @see {@link VMR.Types|`VMR.Types`} for possible values.
     * __________
     * @returns {Number} - The type of Voicemeeter running.
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
     * Returns the version of Voicemeeter running.
     * - The version is returned as a 4-part string (v1.v2.v3.v4)
     * __________
     * @returns {String} - The version of Voicemeeter running.
     * @throws {VMRError} - If an internal error occurs.
     */
    static GetVoicemeeterVersion() {
        local result, version := Buffer(4)

        try result := DllCall(VBVMR.FUNC.GetVoicemeeterVersion, "Ptr", version, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.GetVoicemeeterVersion.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.GetVoicemeeterVersion.Name)

        version := NumGet(version, 0, "Int")
        local v1 := (version & 0xFF000000) >>> 24,
            v2 := (version & 0x00FF0000) >>> 16,
            v3 := (version & 0x0000FF00) >>> 8,
            v4 := version & 0x000000FF

        return Format("{:d}.{:d}.{:d}.{:d}", v1, v2, v3, v4)
    }

    /**
     * Returns the number of Output Devices available on the system.
     * __________
     * @returns {Number} - The number of output devices.
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
     * Returns the Descriptor of an output device.
     * @param {Number} p_index - The index of the device (zero-based).
     * __________
     * @returns {VMRDevice} - An object containing the `Name`, `Driver` and `Hwid` of the device.
     * @throws {VMRError} - If an internal error occurs.
     */
    static Output_GetDeviceDesc(p_index) {
        local result, name := Buffer(1024),
            hwid := Buffer(1024),
            driver := Buffer(4)

        try result := DllCall(VBVMR.FUNC.Output_GetDeviceDescW, "Int", p_index, "Ptr", driver, "Ptr", name, "Ptr", hwid, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.Output_GetDeviceDesc.Name, p_index)

        if (result < 0)
            throw VMRError(result, VBVMR.Output_GetDeviceDesc.Name, p_index)

        return VMRDevice(StrGet(name, 512), NumGet(driver, 0, "UInt"), StrGet(hwid, 512))
    }

    /**
     * Returns the number of Input Devices available on the system.
     * __________
     * @returns {Number} - The number of input devices.
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
     * Returns the Descriptor of an input device.
     * @param {Number} p_index - The index of the device (zero-based).
     * __________
     * @returns {VMRDevice} - An object containing the `Name`, `Driver` and `Hwid` of the device.
     * @throws {VMRError} - If an internal error occurs.
     */
    static Input_GetDeviceDesc(p_index) {
        local result, name := Buffer(1024),
            hwid := Buffer(1024),
            driver := Buffer(4)

        try result := DllCall(VBVMR.FUNC.Input_GetDeviceDescW, "Int", p_index, "Ptr", driver, "Ptr", name, "Ptr", hwid, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.Input_GetDeviceDesc.Name, p_index)

        if (result < 0)
            throw VMRError(result, VBVMR.Input_GetDeviceDesc.Name, p_index)

        return VMRDevice(StrGet(name, 512), NumGet(driver, 0, "UInt"), StrGet(hwid, 512))
    }

    /**
     * Checks if any parameters have changed.
     * __________
     * @returns {Number}
     * - `0` : No change
     * - `1` : Some parameters have changed
     * @throws {VMRError} - If an internal error occurs.
     */
    static IsParametersDirty() {
        local result := 0

        if (!VBVMR.LOGGED_IN)
            return result

        try result := DllCall(VBVMR.FUNC.IsParametersDirty)
        catch Error as err
            throw VMRError(err, VBVMR.IsParametersDirty.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.IsParametersDirty.Name)

        return result
    }

    /**
     * Returns the current status of a given button.
     * @param {Number} p_logicalButton - The index of the button (zero-based).
     * @param {Number} p_bitMode - The type of the returned value.
     * - `0`: button-state
     * - `2`: displayed-state
     * - `3`: trigger-state
     * __________
     * @returns {Number} - The status of the button
     * - `0`: Off
     * - `1`: On
     * @throws {VMRError} - If an internal error occurs.
     */
    static MacroButton_GetStatus(p_logicalButton, p_bitMode) {
        local pValue := Buffer(4)

        try errLevel := DllCall(VBVMR.FUNC.MacroButton_GetStatus, "Int", p_logicalButton, "Ptr", pValue, "Int", p_bitMode, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.MacroButton_GetStatus.Name, p_logicalButton, p_bitMode)

        if (errLevel < 0)
            throw VMRError(errLevel, VBVMR.MacroButton_GetStatus.Name, p_logicalButton, p_bitMode)

        return NumGet(pValue, 0, "Float")
    }

    /**
     * Sets the status of a given button.
     * @param {Number} p_logicalButton - The index of the button (zero-based).
     * @param {Number} p_value - The value to set.
     * - `0`: Off
     * - `1`: On
     * @param {Number} p_bitMode - The type of the returned value.
     * - `0`: button-state
     * - `2`: displayed-state
     * - `3`: trigger-state
     * __________
     * @returns {Number} - The status of the button
     * - `0`: Off
     * - `1`: On
     * @throws {VMRError} - If an internal error occurs.
     */
    static MacroButton_SetStatus(p_logicalButton, p_value, p_bitMode) {
        local result

        try result := DllCall(VBVMR.FUNC.MacroButton_SetStatus, "Int", p_logicalButton, "Float", p_value, "Int", p_bitMode, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.MacroButton_SetStatus.Name, p_logicalButton, p_value, p_bitMode)

        if (result < 0)
            throw VMRError(result, VBVMR.MacroButton_SetStatus.Name, p_logicalButton, p_value, p_bitMode)

        return p_value
    }

    /**
     * Checks if any Macro Buttons states have changed.
     * __________
     * @returns {Number} 
     *  - `0` : No change 
     *  - `> 0` : Some buttons have changed
     * @throws {VMRError} - If an internal error occurs.
     */
    static MacroButton_IsDirty() {
        local result := 0

        if (!VBVMR.LOGGED_IN)
            return result

        try result := DllCall(VBVMR.FUNC.MacroButton_IsDirty)
        catch Error as err
            throw VMRError(err, VBVMR.MacroButton_IsDirty.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.MacroButton_IsDirty.Name)

        return result
    }

    /**
     * Returns any available MIDI messages from Voicemeeter's MIDI mapping.
     * __________
     * @returns {Array} - `[0xF0, 0xFF, ...]` An array of hex-formatted bytes that compose one or more MIDI messages, or an empty string `""` if no messages are available.
     * - A single message is usually 2 or 3 bytes long
     * - The returned array will contain at most `1024` bytes.
     * @throws {VMRError} - If an internal error occurs.
     */
    static GetMidiMessage() {
        local result := "", data := Buffer(1024),
            messages := []

        if (!VBVMR.LOGGED_IN)
            return result

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
     * Sets one or more parameters using a voicemeeter script.
     * @param {String} p_script - The script to execute (must be less than `48kb`).
     * - Scripts can contain one or more parameter changes
     * - Changes can be seperated by a new line, `;` or `,`.
     * - Indices inside the script are zero-based.
     * __________
     * @returns {Number} 
     *  - `0` : OK (no error) 
     *  - `> 0` : Number of the line causing an error
     * @throws {VMRError} - If an internal error occurs.
     */
    static SetParameters(p_script) {
        local result

        try result := DllCall(VBVMR.FUNC.SetParametersW, "WStr", p_script, "Int")
        catch Error as err
            throw VMRError(err, VBVMR.SetParameters.Name)

        if (result < 0)
            throw VMRError(result, VBVMR.SetParameters.Name)

        return result
    }
}
