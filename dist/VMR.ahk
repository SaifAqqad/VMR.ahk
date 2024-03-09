/**
 * VMR.ahk - A wrapper for Voicemeeter's Remote API
 * - Version 2.0.0
 * - Build timestamp 2024-03-09 19:51:57 UTC
 * - Repository: {@link https://github.com/SaifAqqad/VMR.ahk GitHub}
 * - Documentation: {@link https://saifaqqad.github.io/VMR.ahk VMR Docs}
 */
#Requires AutoHotkey >=2.0
class VMRUtils {
    static _MIN_PERCENTAGE := 0.001
    static _MAX_PERCENTAGE := 1.0
    /**
     * Converts a dB value to a percentage value.
     * 
     * @param {Number} p_dB The dB value to convert.
     * __________
     * @returns {Number} The percentage value.
     */
    static DbToPercentage(p_dB) {
        local value := ((10 ** (p_dB / 20)) - VMRUtils._MIN_PERCENTAGE) / (VMRUtils._MAX_PERCENTAGE - VMRUtils._MIN_PERCENTAGE)
        return value < 0 ? 0 : Round(value * 100)
    }
    /**
     * Converts a percentage value to a dB value.
     * 
     * @param {Number} p_percentage The percentage value to convert.
     * __________
     * @returns {Number} The dB value.
     */
    static PercentageToDb(p_percentage) {
        if (p_percentage < 0)
            p_percentage := 0
        local value := 20 * Log(VMRUtils._MIN_PERCENTAGE + p_percentage / 100 * (VMRUtils._MAX_PERCENTAGE - VMRUtils._MIN_PERCENTAGE))
        return Round(value, 2)
    }
    /**
     * Applies an upper and a lower bound on a passed value.
     * 
     * @param {Number} p_value The value to apply the bounds on.
     * @param {Number} p_min The lower bound.
     * @param {Number} p_max The upper bound.
     * __________
     * @returns {Number} The value with the bounds applied.
     */
    static EnsureBetween(p_value, p_min, p_max) => Round(Max(p_min, Min(p_max, p_value)), 2)
    /**
     * Returns the index of the first occurrence of a value in an array, or -1 if it's not found.
     * 
     * @param {Array} p_array The array to search in.
     * @param {Any} p_value The value to search for.
     * __________
     * @returns {Number} The index of the first occurrence of the value in the array, or -1 if it's not found.
     */
    static IndexOf(p_array, p_value) {
        local i, value
        if !(p_array is Array)
            throw Error("p_array: Expected an Array, got " Type(p_array))
        for (i, value in p_array) {
            if (value = p_value)
                return i
        }
        return -1
    }
    /**
     * Returns a string with the passed parameters joined using the passed seperator.
     * 
     * @param {Array} p_params - The parameters to join.
     * @param {String} p_seperator - The seperator to use.
     * @param {Number} p_maxLength - The maximum length of each parameter.
     * __________
     * @returns {String} The joined string.
     */
    static Join(p_params, p_seperator, p_maxLength := 30) {
        local str := ""
        for (param in p_params) {
            str .= SubStr(VMRUtils.ToString(param), 1, p_maxLength) . p_seperator
        }
        return SubStr(str, 1, -StrLen(p_seperator))
    }
    /**
     * Converts a value to a string.
     * 
     * @param {Any} p_value The value to convert to a string.
     * _________
     * @returns {String} The string representation of the passed value
     */
    static ToString(p_value) {
        if (p_value is String)
            return p_value
        else if (p_value is Array)
            return "[" . VMRUtils.Join(p_value, ", ") . "]"
        else if (IsObject(p_value))
            return p_value.ToString ? p_value.ToString() : Type(p_value)
        else
            return String(p_value)
    }
}
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
class VMRConsts {
    /**
     * Events fired by the {@link VMR|`VMR`} object.  
     * Use {@link @VMR.On|`VMR.On`} to register event listeners.
     * 
     * @event `ParametersChanged` - Called when bus/strip parameters change
     * @event `LevelsUpdated` - Called when the {@link @VMRAudioIO.Level|`Level`} arrays for bus/strips are updated
     * @event `DevicesUpdated` - Called when the list of available devices is updated
     * @event `MacroButtonsChanged` - Called when macro-buttons's states change
     * @event `MidiMessage` - Called when a midi message is received  
     * - The `MidiMessage` callback will be passed an array with the hex-formatted bytes of the message
     */
    static Events := {
        ParametersChanged: "ParametersChanged",
        LevelsUpdated: "LevelsUpdated",
        DevicesUpdated: "DevicesUpdated",
        MacroButtonsChanged: "MacroButtonsChanged",
        MidiMessage: "MidiMessage"
    }
    /**
     * Default names for Voicemeeter buses
     * @type {Array}
     */
    static BUS_NAMES := [
        ; Voicemeeter
        ["A", "B"],
        ; Voicemeeter Banana
        ["A1", "A2", "A3", "B1", "B2"],
        ; Voicemeeter Potato
        ["A1", "A2", "A3", "A4", "A5", "B1", "B2", "B3"]
    ]
    static STRIP_NAMES := [
        ; Voicemeeter
        ["Input #1", "Input #2", "Virtual Input #1"],
        ; Voicemeeter Banana
        ["Input #1", "Input #2", "Input #3", "Virtual Input #1", "Virtual Input #2"],
        ; Voicemeeter Potato
        ["Input #1", "Input #2", "Input #3", "Input #4", "Input #5", "Virtual Input #1", "Virtual Input #2", "Virtual Input #3"]
    ]
    /**
     * Known string parameters for {@link VMRAudioIO|`VMRAudioIO`} 
     * @type {Array}
     */
    static IO_STRING_PARAMETERS := [
        "Device",
        "Device.name",
        "Device.wdm",
        "Device.mme",
        "Device.ks",
        "Device.asio",
        "Label",
        "FadeTo",
        "FadeBy",
        "AppGain",
        "AppMute"
    ]
    /**
     * Known device drivers
     * @type {Array}
     */
    static DEVICE_DRIVERS := ["wdm", "mme", "asio", "ks"]
    /**
     * Default device driver, used when setting a device without specifying a driver
     * @type {String}
     */
    static DEFAULT_DEVICE_DRIVER := "wdm"
    static REGISTRY_KEY := Format("HKLM\Software{}\Microsoft\Windows\CurrentVersion\Uninstall\VB:Voicemeeter {17359A74-1236-5467}", A_Is64bitOS ? "\WOW6432Node" : "")
    static DLL_FILE := A_PtrSize == 8 ? "VoicemeeterRemote64.dll" : "VoicemeeterRemote.dll"
    static WM_DEVICE_CHANGE := 0x0219, WM_DEVICE_CHANGE_PARAM := 0x0007
    static SYNC_TIMER_INTERVAL := 10, LEVELS_TIMER_INTERVAL := 30
    static AUDIO_IO_GAIN_MIN := -60.0, AUDIO_IO_GAIN_MAX := 12.0
    static AUDIO_IO_LIMIT_MIN := -40.0, AUDIO_IO_LIMIT_MAX := 12.0
}
class VMRDevice {
    __New(name, driver, hwid) {
        this.Name := name
        this.Hwid := hwid
        if (IsNumber(driver)) {
            switch driver {
                case 3:
                    driver := "wdm"
                case 4:
                    driver := "ks"
                case 5:
                    driver := "asio"
                default:
                    driver := "mme"
            }
        }
        this.Driver := driver
    }
    ToString() {
        return this.name
    }
}
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
    static DLL := "", DLL_PATH := ""
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
        local result
        try result := DllCall(VBVMR.FUNC.Login)
        catch Error as err
            throw VMRError(err, VBVMR.Login.Name)
        if (result < 0)
            throw VMRError(result, VBVMR.Login.Name)
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
        local result
        try result := DllCall(VBVMR.FUNC.Logout)
        catch Error as err
            throw VMRError(err, VBVMR.Logout.Name)
        if (result < 0)
            throw VMRError(result, VBVMR.Logout.Name)
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
        local result
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
        local result
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
/**
 * A basic wrapper for an async operation.
 * 
 * This is needed because the VMR API is asynchronous which means that operations like `SetFloatParameter` do not take effect immediately,
 * and so if the same parameter was fetched right after it was set, the old value would be returned (or sometimes it would return a completely invalid value).
 * 
 * And unfortunately, the VMR API does not provide any meaningful way to wait for a particular operation to complete (callbacks, synchronous api), and so this class uses a normal timer to wait for the operation to complete.
 */
class VMRAsyncOp {
    static DEFAULT_DELAY := 50
    /**
     * Creates a new async operation.
     * 
     * @param {() => Any} p_supplier - (Optional) Supplies the result of the async operation.
     * @param {Number} p_autoResolveTimeout - (Optional) Automatically resolves the async operation after the specified number of milliseconds.
     */
    __New(p_supplier?, p_autoResolveTimeout?) {
        if (IsSet(p_supplier)) {
            if !(p_supplier is Func)
                throw VMRError("p_supplier must be a function.", this.__New.Name, p_supplier)
            this._supplier := p_supplier
        }
        this._value := ""
        this._listeners := []
        this.IsEmpty := false
        this.Resolved := false
        if (IsSet(p_autoResolveTimeout) && IsNumber(p_autoResolveTimeout)) {
            if (p_autoResolveTimeout = 0)
                this._Resolve()
            else
                SetTimer(this._Resolve.Bind(this), -Abs(p_autoResolveTimeout))
        }
    }
    /**
     * Creates an empty async operation that's already been resolved.
     * @type {VMRAsyncOp}
     */
    static Empty {
        get {
            local empty := VMRAsyncOp()
            empty.IsEmpty := true
            empty._Resolve()
            return empty
        }
    }
    /**
     * Adds a listener to the async operation.
     * 
     * @param {(Any) => Any} p_listener - A function that will be called when the async operation is resolved.
     * @param {Number} p_innerOpDelay - (Optional) If passed, the returned async operation will be delayed by the specified number of milliseconds.
     * __________
     * @returns {VMRAsyncOp} - a new async operation that will be resolved when the current operation is resolved and the listener is called.
     * @throws {VMRError} - if `p_listener` is not a function or has an invalid number of parameters.
     */
    Then(p_listener, p_innerOpDelay := 0) {
        if !(p_listener is Func)
            throw VMRError("p_listener must be a function.", this.Then.Name, p_listener)
        if (p_listener.MinParams > 1)
            throw VMRError("p_listener must require 0 or 1 parameters.", this.Then.Name, p_listener)
        if (this.Resolved) {
            local result := this._SafeCall(p_listener)
            return VMRAsyncOp(() => result, p_innerOpDelay)
        }
        else {
            local innerOp := VMRAsyncOp()
            this._listeners.push({ func: p_listener, op: innerOp, delay: Abs(p_innerOpDelay) })
            return innerOp
        }
    }
    /**
     * Waits for the async operation to be resolved.
     * 
     * @param {Number} p_timeoutMs - (Optional) The maximum number of milliseconds to wait before throwing an error.
     * __________
     * @returns {Any} - The result of the async operation.
     */
    Await(p_timeoutMs := 0) {
        if (this.Resolved)
            return this._value
        local currentMs := A_TickCount
        while (!this.Resolved) {
            if (p_timeoutMs > 0 && A_TickCount - currentMs > p_timeoutMs)
                throw VMRError("The async operation timed out", this.Await.Name, p_timeoutMs)
            Sleep(VMRAsyncOp.DEFAULT_DELAY)
        }
        return this._value
    }
    /**
     * Resolves the async operation.
     * 
     * @param {Any} p_value - (Optional) A value to resolve the async operation with, this will take precedence over the supplier.
     */
    _Resolve(p_value?) {
        if (this.Resolved)
            throw VMRError("This async operation has already been resolved.", this._Resolve.Name)
        if (IsSet(p_value))
            this._value := p_value
        else if (this._supplier is Func)
            this._value := this._supplier.Call()
        ; If the supplier returned another async operation, resolve to the actual value.
        if (this._value is VMRAsyncOp)
            this._value := this._value.Await()
        this.Resolved := true
        for (listener in this._listeners) {
            local value := this._SafeCall(listener.func)
                , delay := listener.delay > 0 ? listener.delay : VMRAsyncOp.DEFAULT_DELAY
            SetTimer(listener.op._Resolve.Bind(listener.op, value), -delay)
        }
    }
    /**
     * Calls the listener with the appropriate number of parameters and catches any thrown errors.
     * 
     * @param {Func} p_listener - A function that will be called when the async operation is resolved.
     * __________
     * @returns {Any} - The result of the listener call.
     */
    _SafeCall(p_listener) {
        try {
            if (p_listener.MaxParams = 0) {
                return p_listener.Call()
            }
            else if (p_listener.MinParams < 2) {
                return p_listener.Call(this._value)
            }
        }
    }
}
/**
 * A base class for {@link VMRBus|`VMRBus`} and {@link VMRStrip|`VMRStrip`}
 */
class VMRAudioIO {
    static IS_CLASS_INIT := false
    /**
     * The object's upper gain limit
     * @type {Number}
     * 
     * Setting the gain above the limit will reset it to this value.
     */
    GainLimit := VMRConsts.AUDIO_IO_GAIN_MAX
    /**
     * Gets/Sets the gain as a percentage
     * @type {Number} - The gain as a percentage (e.g. `44` = 44%)
     * 
     * @example
     * local gain := vm.Bus[1].GainPercentage ; get the gain as a percentage
     * vm.Bus[1].GainPercentage++ ; increases the gain by 1%
     */
    GainPercentage {
        get => VMRUtils.DbToPercentage(this.GetParameter("gain"))
        set => this.SetParameter("gain", VMRUtils.PercentageToDb(Value))
    }
    /**
     * Set/Get the object's EQ parameters.
     * 
     * @type {Number} - The EQ parameter's value.
     * @param {Array} p_params - An array containing the EQ parameter name and the channel/cell numbers.
     * 
     * - Bus EQ parameters: `EQ[param] := value`
     * - EQ channel/cells parameters: `EQ[param, channel, cell] := value`
     * 
     * @example
     * vm.Bus[1].EQ["gain", 1, 1] := -6
     * vm.Bus[1].EQ["q", 1, 1] := 90
     * vm.Bus[1].EQ["AB"] := true
     */
    EQ[p_params*] {
        get {
            if (p_params.Length == 3)
                this.GetParameter("EQ.channel[" p_params[2] - 1 "].cell[" p_params[3] - 1 "]." p_params[1])
            else
                this.GetParameter("EQ." p_params[1])
        }
        set {
            if (p_params.Length == 3)
                this.SetParameter("EQ.channel[" p_params[2] - 1 "].cell[" p_params[3] - 1 "]." p_params[1], Value)
            else
                this.SetParameter("EQ." p_params[1], Value)
        }
    }
    /**
     * Gets/Sets the object's current device
     * 
     * @type {VMRDevice} - The device object.
     * - When setting the device, either a device name or a device object can be passed, the latter can be retrieved using `VMRStrip`/`VMRBus` `GetDevice()` methods.
     * 
     * @param {String} p_driver - (Optional) The driver of the device (ex: `wdm`)
     * 
     * @example
     * vm.Bus[1].Device := VMRBus.GetDevice("Headphones") ; using a substring of the device name
     * vm.Bus[1].Device := "Headphones (Virtual Audio Device)" ; using a device's full name
     */
    Device[p_driver?] {
        get {
            local devices := this.Type == "Bus" ? VMRBus.Devices : VMRStrip.Devices
            ; TODO: Once Voicemeeter adds support for getting the type (driver) of the current device, we can ignore the p_driver parameter
            return this._MatchDevice(this.GetParameter("device.name"), p_driver ?? unset)
        }
        set {
            local deviceName := Value, deviceDriver := p_driver ?? VMRConsts.DEFAULT_DEVICE_DRIVER
            ; Allow setting the device using a device object
            if (IsObject(Value)) {
                deviceDriver := Value.Driver
                deviceName := Value.Name
            }
            if (VMRUtils.IndexOf(VMRConsts.DEVICE_DRIVERS, deviceDriver) == -1)
                throw VMRError(deviceDriver " is not a valid device driver", "Device", p_driver, Value)
            this.SetParameter("device." deviceDriver, deviceName)
        }
    }
    /**
     * An array of the object's channel levels
     * @type {Array}
     * 
     * Physical (hardware) strips have 2 channels (left, right), Buses and virtual strips have 8 channels
     * __________
     * @example <caption>Get the current peak level of a bus</caption>
     * local peakLevel := Max(vm.Bus[1].Level*)
     */
    Level := Array()
    /**
     * The object's identifier that's used when calling VMR's functions.    
     * Like `Bus[0]` or `Strip[3]`
     * 
     * @type {String}
     */
    Id := ""
    /**
     * The object's one-based index
     * @type {Number}
     */
    Index := 0
    /**
     * The object's type (`Bus` or `Strip`)
     * @type {String}
     */
    Type := ""
    /**
     * Creates a new `VMRAudioIO` object.
     * @param {Number} p_index - The zero-based index of the bus/strip.
     * @param {String} p_ioType - The type of the object. (`Bus` or `Strip`)
     */
    __New(p_index, p_ioType) {
        this._index := p_index
        this._isPhysical := false
        this.Id := p_ioType "[" p_index "]"
        this.Index := p_index + 1
        this.Type := p_ioType
    }
    /**
     * @private - Internal method
     * @description Implements a default property getter, this is invoked when using the object access syntax.
     * @example
     * local sampleRate := bus.device["sr"]
     * MsgBox("Gain is " bus.gain)
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Array} p_params - An extra param passed when using bracket syntax with a normal prop access (`bus.device["sr"]`).
     * __________
     * @returns {Any} The value of the parameter.
     * @throws {VMRError} - If an internal error occurs.
     */
    _Get(p_key, p_params) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return ""
        if (p_params.Length > 0) {
            for param in p_params {
                p_key .= IsNumber(param) ? "[" param - 1 "]" : "." param
            }
        }
        return this.GetParameter(p_key)
    }
    /**
     * @private - Internal method
     * @description Implements a default property setter, this is invoked when using the object access syntax.
     * @example
     * bus.gain := 0.5
     * bus.device["mme"] := "Headset"
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Array} p_params - An extra param passed when using bracket syntax with a normal prop access. `bus.device["wdm"] := "Headset"`
     * @param {Any} p_value - The value of the parameter.
     * __________
     * @returns {Boolean} - `true` if the parameter was set successfully.
     * @throws {VMRError} - If an internal error occurs.
     */
    _Set(p_key, p_params, p_value) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return false
        if (p_params.Length > 0) {
            for param in p_params {
                p_key .= IsNumber(param) ? "[" param - 1 "]" : "." param
            }
        }
        return !this.SetParameter(p_key, p_value).IsEmpty
    }
    /**
     * Implements a default indexer.
     * this is invoked when using the bracket access syntax.
     * @example
     * MsgBox(strip["mute"])
     * bus["gain"] := 0.5
     * 
     * @param {String} p_key - The name of the parameter.
     * __________
     * @type {Any} - The value of the parameter.
     * @throws {VMRError} - If an internal error occurs.
     */
    __Item[p_key] {
        get => this.GetParameter(p_key)
        set => this.SetParameter(p_key, Value)
    }
    /**
     * Sets the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * @param {Any} p_value - The value of the parameter.
     * __________
     * @returns {VMRAsyncOp} - An async operation that resolves to `true` if the parameter was set successfully.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    SetParameter(p_name, p_value) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return VMRAsyncOp.Empty
        local vmrFunc := VMRAudioIO._IsStringParam(p_name)
            ? VBVMR.SetParameterString.Bind(VBVMR)
            : VBVMR.SetParameterFloat.Bind(VBVMR)
        if (p_name = "gain") {
            p_value := VMRUtils.EnsureBetween(p_value, VMRConsts.AUDIO_IO_GAIN_MIN, this.GainLimit)
        }
        else if (p_name = "limit") {
            p_value := VMRUtils.EnsureBetween(p_value, VMRConsts.AUDIO_IO_LIMIT_MIN, VMRConsts.AUDIO_IO_LIMIT_MAX)
        }
        else if (p_name = "mute") {
            p_value := p_value < 0 ? !this.GetParameter("mute") : p_value
        }
        local result := vmrFunc.Call(this.Id, p_name, p_value)
        return VMRAsyncOp(() => result == 0, 50)
    }
    /**
     * Returns the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * __________
     * @returns {Any} - The value of the parameter.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    GetParameter(p_name) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return -1
        local vmrFunc := VMRAudioIO._IsStringParam(p_name) ? VBVMR.GetParameterString.Bind(VBVMR) : VBVMR.GetParameterFloat.Bind(VBVMR)
        switch p_name, false {
            case "gain", "limit":
                return Format("{:.2f}", vmrFunc.Call(this.Id, p_name))
            case "device":
                p_name := "device.name"
        }
        return vmrFunc.Call(this.Id, p_name)
    }
    /**
     * Increments a parameter by a specific amount.  
     * - It's recommended to use this method instead of incrementing the parameter directly (`++vm.Bus[1].Gain`).
     * - Since this method doesn't fetch the current value of the parameter to update it, {@link @VMRAudioIO.GainLimit|`GainLimit`} cannot be applied here.
     * 
     * @param {String} p_param - The name of the parameter, must be a numeric parameter (see {@link VMRConsts.IO_STRING_PARAMETERS|`VMRConsts.IO_STRING_PARAMETERS`}).
     * @param {Number} p_amount - The amount to increment the parameter by, can be set to a negative value to decrement instead.
     * __________
     * @returns {VMRAsyncOp} - An async operation that resolves with the incremented value.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     * __________
     * @example <caption>usage with callbacks</caption>
     * vm.Bus[1].Increment("gain", 1).Then(val => Tooltip(val)) ; increases the gain by 1dB
     * vm.Bus[1].Increment("gain", -5).Then(val => Tooltip(val)) ; decreases the gain by 5dB
     * 
     * @example <caption>"synchronous" usage</caption>
     * ; increases the gain by 1dB and waits for the operation to complete
     * ; this is equivalent to `vm.Bus[1].Gain++` followed by `Sleep(50)`
     * gainValue := vm.Bus[1].Increment("gain", 1).Await()
     * 
     */
    Increment(p_param, p_amount) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return VMRAsyncOp.Empty
        if (!IsNumber(p_amount))
            throw VMRError("p_amount must be a number", this.Increment.Name, p_param, p_amount)
        if (VMRAudioIO._IsStringParam(p_param))
            throw VMRError("p_param must be a numeric parameter", this.Increment.Name, p_param, p_amount)
        local script := Format("{}.{} {} {}", this.Id, p_param, p_amount < 0 ? "-=" : "+=", Abs(p_amount))
        VBVMR.SetParameters(script)
        return VMRAsyncOp(() => this.GetParameter(p_param), 50)
    }
    /**
     * Sets the gain to a specific value with a progressive fade.
     * 
     * @param {Number} p_db - The gain value in dBs.
     * @param {Number} p_duration - The duration of the fade in milliseconds.
     * __________
     * @returns {VMRAsyncOp} - An async operation that resolves with the final gain value.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    FadeTo(p_db, p_duration) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return VMRAsyncOp.Empty
        if (this.SetParameter("FadeTo", "(" p_db ", " p_duration ")").IsEmpty)
            return VMRAsyncOp.Empty
        return VMRAsyncOp(() => this.GetParameter("gain"), p_duration + 50)
    }
    /**
     * Fades the gain by a specific amount.
     * 
     * @param {Number} p_dbAmount - The amount to fade the gain by in dBs.
     * @param {Number} p_duration - The duration of the fade in milliseconds.
     * _________
     * @returns {VMRAsyncOp} - An async operation that resolves with the final gain value.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    FadeBy(p_dbAmount, p_duration) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return VMRAsyncOp.Empty
        if (!this.SetParameter("FadeBy", "(" p_dbAmount ", " p_duration ")"))
            return VMRAsyncOp.Empty
        return VMRAsyncOp(() => this.GetParameter("gain"), p_duration + 50)
    }
    /**
     * Returns `true` if the bus/strip is a physical (hardware) one.
     * __________
     * @returns {Boolean}
     */
    IsPhysical() => this._isPhysical
    /**
     * @private - Internal method
     * @description Returns `true` if the parameter is a string parameter.
     * 
     * @param {String} p_param - The name of the parameter.
     * @returns {Boolean}
     */
    static _IsStringParam(p_param) => VMRUtils.IndexOf(VMRConsts.IO_STRING_PARAMETERS, p_param) > 0
    /**
     * @private - Internal method
     * @description Returns a device object.
     * 
     * @param {Array} p_devicesArr - An array of {@link VMRDevice|`VMRDevice`} objects.
     * @param {String} p_name - The name of the device.
     * @param {String} p_driver - The driver of the device.
     * @see {@link VMRConsts.DEVICE_DRIVERS|`VMRConsts.DEVICE_DRIVERS`} for a list of valid drivers.
     * __________
     * @returns {VMRDevice} - A device object, or an empty string `""` if the device was not found.
     */
    static _GetDevice(p_devicesArr, p_name, p_driver?) {
        local device, index
        if (!IsSet(p_driver))
            p_driver := VMRConsts.DEFAULT_DEVICE_DRIVER
        for (index, device in p_devicesArr) {
            if (device.driver = p_driver && InStr(device.name, p_name))
                return device.Clone()
        }
        return ""
    }
    /**
     * @private - Internal method
     * @description Returns a device object that exactly matches the specified name.
     * @param {String} p_name - The name of the device.
     * __________
     * @returns {VMRDevice} 
     */
    _MatchDevice(p_name, p_driver?) {
        local devices := this.Type == "Bus" ? VMRBus.Devices : VMRStrip.Devices
        for device in devices {
            if (device.name == p_name && (!IsSet(p_driver) || device.driver = p_driver))
                return device.Clone()
        }
        return ""
    }
}
/**
 * A wrapper class for voicemeeter buses.
 * @extends {VMRAudioIO}
 */
class VMRBus extends VMRAudioIO {
    static LEVELS_COUNT := 0
    /**
     * An array of bus (output) devices
     * @type {Array} - An array of {@link VMRDevice} objects.
     */
    static Devices := Array()
    /**
     * The bus's name (as shown in voicemeeter's UI)
     * 
     * @type {String}
     * 
     * @example
     * local busName := VMRBus.Bus[1].Name ; "A1" or "A" depending on voicemeeter's type
     */
    Name := ""
    /**
     * Creates a new VMRBus object.
     * @param {Number} p_index - The zero-based index of the bus.
     * @param {Number} p_vmrType - The type of the running voicemeeter.
     */
    __New(p_index, p_vmrType) {
        super.__New(p_index, "Bus")
        this._channelCount := 8
        this.Name := VMRConsts.BUS_NAMES[p_vmrType][p_index + 1]
        switch p_vmrType {
            case 1:
                super._isPhysical := true
            case 2:
                super._isPhysical := this._index < 3
            case 3:
                super._isPhysical := this._index < 5
        }
        ; Setup the bus's levels array
        this.Level.Length := this._channelCount
        ; A bus's level index starts at the current total count
        this._levelIndex := VMRBus.LEVELS_COUNT
        VMRBus.LEVELS_COUNT += this._channelCount
        this.DefineProp("__Get", { Call: super._Get })
        this.DefineProp("__Set", { Call: super._Set })
    }
    _UpdateLevels() {
        loop this._channelCount {
            local vmrIndex := this._levelIndex + A_Index - 1
            local level := Round(20 * Log(VBVMR.GetLevel(3, vmrIndex)))
            this.Level[A_Index] := VMRUtils.EnsureBetween(level, -999, 999)
        }
    }
    /**
     * Retrieves a bus (output) device by its name/driver.
     * @param {String} p_name - The name of the device.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, {@link VMRConsts.DEFAULT_DEVICE_DRIVER|`VMRConsts.DEFAULT_DEVICE_DRIVER`} will be used.
     * @see {@link VMRConsts.DEVICE_DRIVERS|`VMRConsts.DEVICE_DRIVERS`} for a list of valid drivers.
     * __________
     * @returns {VMRDevice} - A device object, or an empty string `""` if the device was not found.
     */
    static GetDevice(p_name, p_driver?) => VMRAudioIO._GetDevice(VMRBus.Devices, p_name, p_driver ?? unset)
}
/**
 * A wrapper class for voicemeeter strips.
 * @extends {VMRAudioIO}
 */
class VMRStrip extends VMRAudioIO {
    static LEVELS_COUNT := 0
    /**
     * An array of strip (input) devices
     * @type {Array} - An array of {@link VMRDevice} objects.
     */
    static Devices := Array()
    /**
     * The strip's name (as shown in voicemeeter's UI)
     * 
     * @example
     * local stripName := VMRBus.Strip[1].Name ; "Input #1"
     * 
     * @readonly
     * @type {String}
     */
    Name := ""
    /**
     * Sets an application's gain on the strip.
     * 
     * @param {String|Number} p_app - The name of the application, or its one-based index.
     * @type {Number} - The application's gain (`0.0` to `1.0`).
     * __________
     * @throws {VMRError} - If an internal error occurs.
     */
    AppGain[p_app] {
        set {
            if (IsNumber(p_app))
                this.SetParameter("App[" p_app - 1 "].Gain", VMRUtils.EnsureBetween(Round(Value, 2), 0.0, 1.0))
            else
                this.SetParameter("AppGain", "(`"" p_app "`", " VMRUtils.EnsureBetween(Round(Value, 2), 0.0, 1.0) ")")
        }
    }
    /**
     * Sets an application's mute state on the strip.
     * 
     * @param {String|Number} p_app - The name of the application, or its one-based index.
     * @type {Boolean} - The application's mute state.
     * __________
     * @throws {VMRError} - If an internal error occurs.
     */
    AppMute[p_app] {
        set {
            if (IsNumber(p_app))
                this.SetParameter("App[" p_app - 1 "].Mute", Value)
            else
                this.SetParameter("AppMute", "(`"" p_app "`", " Value ")")
        }
    }
    /**
     * Creates a new VMRStrip object.
     * @param {Number} p_index - The zero-based index of the strip.
     * @param {Number} p_vmrType - The type of the running voicemeeter.
     */
    __New(p_index, p_vmrType) {
        super.__New(p_index, "Strip")
        this.Name := VMRConsts.STRIP_NAMES[p_vmrType][this.Index]
        switch p_vmrType {
            case 1:
                super._isPhysical := this._index < 2
            case 2:
                super._isPhysical := this._index < 3
            case 3:
                super._isPhysical := this._index < 5
        }
        ; physical strips have 2 channels, virtual strips have 8
        this._channelCount := this.IsPhysical() ? 2 : 8
        ; Setup the strip's levels array
        this.Level.Length := this._channelCount
        ; A strip's level index starts at the current total count
        this._levelIndex := VMRStrip.LEVELS_COUNT
        VMRStrip.LEVELS_COUNT += this._channelCount
        this.DefineProp("__Get", { Call: super._Get })
        this.DefineProp("__Set", { Call: super._Set })
    }
    _UpdateLevels() {
        loop this._channelCount {
            local vmrIndex := this._levelIndex + A_Index - 1
            local level := Round(20 * Log(VBVMR.GetLevel(1, vmrIndex)))
            this.Level[A_Index] := VMRUtils.EnsureBetween(level, -999, 999)
        }
    }
    /**
     * Retrieves a strip (input) device by its name/driver.
     * @param {String} p_name - The name of the device.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, {@link VMRConsts.DEFAULT_DEVICE_DRIVER|`VMRConsts.DEFAULT_DEVICE_DRIVER`} will be used.
     * @see {@link VMRConsts.DEVICE_DRIVERS|`VMRConsts.DEVICE_DRIVERS`} for a list of valid drivers.
     * __________
     * @returns {VMRDevice} - A device object, or an empty string `""` if the device was not found.
     */
    static GetDevice(p_name, p_driver?) => VMRAudioIO._GetDevice(VMRStrip.Devices, p_name, p_driver ?? unset)
}
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
        if (IsNumber(p_preset))
            return VBVMR.SetParameterFloat("Command", "Preset[" p_preset - 1 "].Recall", 1) == 0
        else
            return VBVMR.SetParameterString("Command", "RecallPreset", p_preset) == 0
    }
}
class VMRControllerBase {
    __New(p_id, p_stringParamChecker) {
        this.DefineProp("Id", { Get: (*) => p_id })
        this.DefineProp("StringParamChecker", { Call: p_stringParamChecker })
    }
    /**
     * @private - Internal method
     * @description Implements a default property getter, this is invoked when using the object access syntax.
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Array} p_params - An extra param passed when using bracket syntax with a normal prop access (`bus.device["sr"]`).
     * __________
     * @returns {Any} The value of the parameter.
     * @throws {VMRError} - If an internal error occurs.
     */
    __Get(p_key, p_params) {
        if (p_params.Length > 0) {
            for param in p_params {
                p_key .= IsNumber(param) ? "[" param "]" : "." param
            }
        }
        return this.GetParameter(p_key)
    }
    /**
     * @private - Internal method
     * @description Implements a default property setter, this is invoked when using the object access syntax.
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Array} p_params - An extra param passed when using bracket syntax with a normal prop access. `bus.device["wdm"] := "Headset"`
     * @param {Any} p_value - The value of the parameter.
     * __________
     * @returns {Boolean} - `true` if the parameter was set successfully.
     * @throws {VMRError} - If an internal error occurs.
     */
    __Set(p_key, p_params, p_value) {
        if (p_params.Length > 0) {
            for param in p_params {
                p_key .= IsNumber(param) ? "[" param "]" : "." param
            }
        }
        return this.SetParameter(p_key, p_value) == 0
    }
    /**
     * Implements a default indexer.
     * this is invoked when using the bracket access syntax.
     * 
     * @param {String} p_key - The name of the parameter.
     * __________
     * @type {Any} - The value of the parameter.
     * @throws {VMRError} - If an internal error occurs.
     */
    __Item[p_key] {
        get => this.GetParameter(p_key)
        set => this.SetParameter(p_key, Value)
    }
    /**
     * Sets the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * @param {Any} p_value - The value of the parameter.
     * __________
     * @returns {VMRAsyncOp} - An async operation that resolves to `true` if the parameter was set successfully.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    SetParameter(p_name, p_value) {
        local vmrFunc := this.StringParamChecker(p_name)
            ? VBVMR.SetParameterString.Bind(VBVMR)
            : VBVMR.SetParameterFloat.Bind(VBVMR)
        local result := vmrFunc.Call(this.Id, p_name, p_value)
        return VMRAsyncOp(() => result == 0, 50)
    }
    /**
     * Returns the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * __________
     * @returns {Any} - The value of the parameter.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    GetParameter(p_name) {
        local vmrFunc := this.StringParamChecker(p_name) ? VBVMR.GetParameterString.Bind(VBVMR) : VBVMR.GetParameterFloat.Bind(VBVMR)
        return vmrFunc.Call(this.Id, p_name) == 0
    }
}
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
class VMRRecorder extends VMRControllerBase {
    static _stringParameters := ["load"]
    __New(p_type) {
        super.__New("recorder", (_, p) => VMRUtils.IndexOf(VMRRecorder._stringParameters, p) != -1)
        this.DefineProp("TypeInfo", { Get: (*) => p_type })
    }
    /**
     * Arms the specified bus for recording, switching the recording mode to `1` (bus).
     * Or returns the state of the specified bus (whether it's armed or not).
     * @param {number} p_index - The bus's one-based index.
     * __________
     * @type {boolean} - Whether the bus is armed or not.
     * 
     * @example <caption>Arm the first bus for recording.</caption>
     * VMR.Recorder.ArmBus[1] := true
     */
    ArmBus[p_index] {
        get {
            return this.GetParameter("ArmBus(" (p_index - 1) ")")
        }
        set {
            this.SetParameter("mode.recbus", true)
            this.SetParameter("ArmBus(" . (p_index - 1) . ")", Value)
        }
    }
    /**
     * Arms the specified strip for recording, switching the recording mode to `0` (strip).
     * Or returns the state of the specified strip (whether it's armed or not).
     * @param {number} p_index - The strip's one-based index.
     * __________
     * @type {boolean} - Whether the strip is armed or not.
     * 
     * @example <caption>Arm a strip for recording.</caption>
     * VMR.Recorder.ArmStrip[4] := true
     */
    ArmStrip[p_index] {
        get {
            return this.GetParameter("ArmStrip(" (p_index - 1) ")")
        }
        set {
            this.SetParameter("mode.recbus", false)
            this.SetParameter("ArmStrip(" . (p_index - 1) . ")", Value)
        }
    }
    /**
     * Arms the specified strips for recording, switching the recording mode to `0` (strip) and disarming any armed strips.
     * @param {Array} p_strips - The strips' one-based indices.
     * 
     * @example <caption>Arm strips 1, 2, and 4 for recording.</caption>
     * VMR.Recorder.ArmStrips(1, 2, 4)
     */
    ArmStrips(p_strips*) {
        loop this.TypeInfo.StripCount
            this.ArmStrip[A_Index] := false
        for i in p_strips
            this.ArmStrip[i] := true
    }
    /**
     * Loads the specified file into the recorder.
     * @param {String} p_path - The file's path.
     * __________
     * @returns {VMRAsyncOp} - An async operation that resolves to `true` if the parameter was set successfully.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    Load(p_path) => this.SetParameter("load", p_path)
}
class VMRVBAN extends VMRControllerBase {
    /**
     * Controls a VBAN input stream
     * @type {VMRControllerBase}
     */
    Instream[p_index] {
        get {
            return this._instreams.Get(p_index)
        }
    }
    /**
     * Controls a VBAN output stream
     * @type {VMRControllerBase}
     */
    Outstream[p_index] {
        get {
            return this._outstreams.Get(p_index)
        }
    }
    __New(p_type) {
        super.__New("vban", (*) => false)
        this.DefineProp("TypeInfo", { Get: (*) => p_type })
        local stringParams := ["name", "ip"]
        local streamStringParamChecker := (_, p) => VMRUtils.IndexOf(stringParams, p) != -1
        local instreams := Array(), outstreams := Array()
        loop p_type.VbanCount {
            instreams.Push(VMRControllerBase("vban.instream[" A_Index - 1 "]", streamStringParamChecker))
            outstreams.Push(VMRControllerBase("vban.outstream[" A_Index - 1 "]", streamStringParamChecker))
        }
        this.DefineProp("_instreams", { Get: (*) => instreams })
        this.DefineProp("_outstreams", { Get: (*) => outstreams })
    }
}
/**
 * A wrapper class for Voicemeeter Remote that hides the low-level API to simplify usage.  
 * Must be initialized by calling {@link @VMR.Login|`Login()`} after creating the VMR instance.
 */
class VMR {
    /**
     * The type of Voicemeeter that is currently running.
     * @type {VMR.Types} - An object containing information about the current Voicemeeter type.
     * @see {@link VMR.Types|`VMR.Types`} for a list of available types.
     */
    Type := ""
    /**
     * The version of Voicemeeter that is currently running.
     * @type {String} - The version string in the format `v1.v2.v3.v4` (ex: `2.1.0.5`).
     * @see The AHK function {@link VerCompare|`VerCompare`} can be used to compare version strings.
     */
    Version := ""
    /**
     * An array of voicemeeter buses
     * @type {Array} - An array of {@link VMRBus|`VMRBus`} objects.
     */
    Bus := Array()
    /**
     * An array of voicemeeter strips
     * @type {Array} - An array of {@link VMRStrip|`VMRStrip`} objects.
     */
    Strip := Array()
    /**
     * Commands that control various aspects of Voicemeeter
     * @type {VMRCommands}
     * @see {@link VMRCommands|`VMRCommands`} for a list of available commands.
     */
    Command := VMRCommands()
    /**
     * Controls Voicemeeter Potato's FX settings
     * #### This property is only available when running Voicemeeter Potato (`VMR.Type.Id == 3`).
     * @type {VMRControllerBase}
     */
    Fx := ""
    /**
     * Controls Voicemeeter's Patch parameters
     * @type {VMRControllerBase}
     */
    Patch := VMRControllerBase("Patch", (*) => false)
    /**
     * Controls Voicemeeter's System Settings
     * @type {VMRControllerBase}
     */
    Option := VMRControllerBase("Option", (*) => false)
    /**
     * Controls Voicemeeter's Macro Buttons app
     * @type {VMRMacroButton}
     */
    MacroButton := VMRMacroButton()
    /**
     * Controls Voicemeeter's Recorder
     * #### This property is only available when running Voicemeeter Banana or Potato (`VMR.Type.Id == 2 || VMR.Type.Id == 3`).
     * @type {VMRRecorder}
     */
    Recorder := ""
    /**
     * Controls Voicemeeter's VBAN interface
     * @type {VMRVBAN}
     */
    VBAN := ""
    /**
     * Creates a new VMR instance and initializes the {@link VBVMR|`VBVMR`} class.
     * @param {String} p_path - (Optional) The path to the Voicemeeter Remote DLL. If not specified, VBVMR will attempt to find it in the registry.
     * __________
     * @throws {VMRError} - If the DLL is not found in the specified path or if voicemeeter is not installed.
     */
    __New(p_path := "") {
        VBVMR.Init(p_path)
        this._eventListeners := Map()
        this._eventListeners.CaseSense := "Off"
        for (event in VMRConsts.Events.OwnProps())
            this._eventListeners[event] := []
    }
    /**
     * Initializes the VMR instance and opens the communication pipe with Voicemeeter.
     * @param {Boolean} p_launchVoicemeeter - (Optional) Whether to launch Voicemeeter if it's not already running. Defaults to `true`.
     * __________
     * @returns {VMR} The {@link VMR|`VMR`} instance.
     * @throws {VMRError} - If an internal error occurs.
     */
    Login(p_launchVoicemeeter := true) {
        local loginStatus := VBVMR.Login()
        ; Check if we should launch the Voicemeeter UI
        if (loginStatus != 0 && p_launchVoicemeeter) {
            local vmPID := this.RunVoicemeeter()
            WinWait("ahk_class VBCABLE0Voicemeeter0MainWindow0 ahk_pid" vmPID)
            Sleep(2000)
        }
        this.Version := VBVMR.GetVoicemeeterVersion()
        this.Type := VMR.Types.GetType(VBVMR.GetVoicemeeterType())
        if (!this.Type)
            throw VMRError("Unsupported Voicemeeter type: " . VBVMR.GetVoicemeeterType(), this.Login.Name, p_launchVoicemeeter)
        OnExit(this.__Delete.Bind(this))
        ; Initialize VMR components (bus/strip arrays, macro buttons, etc)
        this._InitializeComponents()
        ; Setup timers
        this._syncTimer := this.Sync.Bind(this)
        this._levelsTimer := this._UpdateLevels.Bind(this)
        SetTimer(this._syncTimer, VMRConsts.SYNC_TIMER_INTERVAL)
        SetTimer(this._levelsTimer, VMRConsts.LEVELS_TIMER_INTERVAL)
        ; Listen for device changes to update the device arrays
        this._updateDevicesCallback := this.UpdateDevices.Bind(this)
        OnMessage(VMRConsts.WM_DEVICE_CHANGE, this._updateDevicesCallback)
        this.Sync()
        return this
    }
    /**
     * Attempts to run Voicemeeter.
     * When passing a `p_type`, it will only attempt to run the specified Voicemeeter type,
     * otherwise it will attempt to run every voicemeeter type descendingly until one is successfully launched.
     * 
     * @param {Number} p_type - (Optional) The type of Voicemeeter to run.
     * __________
     * @returns {Number} The PID of the launched Voicemeeter process.
     * @throws {VMRError} If the specified Voicemeeter type is invalid, or if no Voicemeeter type could be launched.
     */
    RunVoicemeeter(p_type?) {
        local vmPID := ""
        if (IsSet(p_type)) {
            local vmInfo := VMR.Types.GetType(p_type)
            if (!vmInfo)
                throw VMRError("Invalid Voicemeeter type: " . p_type, this.RunVoicemeeter.Name, p_type)
            local vmPath := VBVMR.DLL_PATH . "\" . vmInfo.Executable
            Run(vmPath, VBVMR.DLL_PATH, "Hide", &vmPID)
            return vmPID
        }
        local vmTypeCount := VMR.Types.Count
        loop vmTypeCount {
            try {
                vmPID := this.RunVoicemeeter((vmTypeCount + 1) - A_Index)
                return vmPID
            }
        }
        throw VMRError("Failed to launch Voicemeeter", this.RunVoicemeeter.Name)
    }
    /**
     * Registers a callback function to be called when the specified event is fired.
     * @param {String} p_event - The name of the event to listen for.
     * @param {Func} p_listener - The function to call when the event is fired.
     * __________
     * @example vm.On(VMRConsts.Events.ParametersChanged, () => MsgBox("Parameters changed!"))
     * @see {@link VMRConsts.Events|`VMRConsts.Events`} for a list of available events.
     * __________
     * @throws {VMRError} If the specified event is invalid, or if the listener is not a valid `Func` object.
     */
    On(p_event, p_listener) {
        if (!this._eventListeners.Has(p_event))
            throw VMRError("Invalid event: " p_event, this.On.Name, p_event, p_listener)
        if !(p_listener is Func)
            throw VMRError("Invalid listener: " String(p_listener), this.On.Name, p_event, p_listener)
        local eventListeners := this._eventListeners[p_event]
        if (VMRUtils.IndexOf(eventListeners, p_listener) == -1)
            eventListeners.Push(p_listener)
    }
    /**
     * Removes a callback function from the specified event.
     * @param {String} p_event - The name of the event.
     * @param {Func} p_listener - (Optional) The function to remove, if omitted, all listeners for the specified event will be removed.
     * __________
     * @example vm.Off("parametersChanged", myListener)
     * @see {@link VMRConsts.Events|`VMRConsts.Events`} for a list of available events.
     * __________
     * @returns {Boolean} Whether the listener was removed.
     * @throws {VMRError} If the specified event is invalid, or if the listener is not a valid `Func` object.
     */
    Off(p_event, p_listener?) {
        if (!this._eventListeners.Has(p_event))
            throw VMRError("Invalid event: " p_event, this.Off.Name, p_event, p_listener)
        if (!IsSet(p_listener)) {
            this._eventListeners[p_event] := Array()
            return true
        }
        if !(p_listener is Func)
            throw VMRError("Invalid listener: " String(p_listener), this.Off.Name, p_event, p_listener)
        local eventListeners := this._eventListeners[p_event]
        local listenerIndex := VMRUtils.IndexOf(eventListeners, p_listener)
        if (listenerIndex == -1)
            return false
        eventListeners.RemoveAt(listenerIndex)
        return true
    }
    /**
     * Synchronizes the VMR instance with Voicemeeter.
     * __________
     * @returns {Boolean} - Whether voicemeeter state has changed since the last sync.
     */
    Sync() {
        static ignoreMsg := false
        try {
            ; Prevent multiple syncs from running at the same time
            Critical("On")
            local dirtyParameters := VBVMR.IsParametersDirty()
                , dirtyMacroButtons := VBVMR.MacroButton_IsDirty()
            ; Api calls were successful -> reset ignoreMsg flag
            ignoreMsg := false
            if (dirtyParameters > 0)
                this._DispatchEvent(VMRConsts.Events.ParametersChanged)
            if (dirtyMacroButtons > 0)
                this._DispatchEvent(VMRConsts.Events.MacroButtonsChanged)
            ; Check if there are any listeners for midi messages
            local midiListeners := this._eventListeners[VMRConsts.Events.MidiMessage]
            if (midiListeners.Length > 0) {
                ; Get new midi messages and dispatch event if there's any
                local midiMessages := VBVMR.GetMidiMessage()
                if (midiMessages && midiMessages.Length > 0)
                    this._DispatchEvent(VMRConsts.Events.MidiMessage, midiMessages)
            }
            Critical("Off")
            return dirtyParameters || dirtyMacroButtons
        }
        catch Error as err {
            Critical("Off")
            if (ignoreMsg)
                return false
            result := MsgBox(
                Format("An error occurred during VMR sync:`n{}`nDetails: {}`nAttempt to restart Voicemeeter?", err.Message, err.Extra),
                "VMR",
                "YesNo Icon! T10"
            )
            switch (result) {
                case "Yes":
                    this.runVoicemeeter(this.Type.id)
                case "No", "Timeout":
                    ignoreMsg := true
            }
            Sleep(1000)
            return false
        }
    }
    /**
     * Executes a Voicemeeter script (**not** an AutoHotkey script).
     * - Scripts can contain one or more parameter changes
     * - Changes can be seperated by a new line, `;` or `,`.
     * - Indices in the script are zero-based.
     * 
     * @param {String} p_script - The script to execute.
     * __________
     * @throws {VMRError} If an error occurs while executing the script.
     */
    Exec(p_script) {
        local result := VBVMR.SetParameters(p_script)
        if (result > 0)
            throw VMRError("An error occurred while executing the script at line: " . result, this.Exec.Name, p_script)
    }
    /**
     * Updates the list of strip/bus devices.
     * @param {Number} p_wParam - (Optional) If passed, must be equal to {@link VMRConsts.WM_DEVICE_CHANGE_PARAM|`VMRConsts.WM_DEVICE_CHANGE_PARAM`} to update the device arrays.
     * __________
     * @throws {VMRError} If an internal error occurs.
     */
    UpdateDevices(p_wParam?, *) {
        if (IsSet(p_wParam) && p_wParam != VMRConsts.WM_DEVICE_CHANGE_PARAM)
            return
        VMRStrip.Devices := Array()
        loop VBVMR.Input_GetDeviceNumber()
            VMRStrip.Devices.Push(VBVMR.Input_GetDeviceDesc(A_Index - 1))
        VMRBus.Devices := Array()
        loop VBVMR.Output_GetDeviceNumber()
            VMRBus.Devices.Push(VBVMR.Output_GetDeviceDesc(A_Index - 1))
        SetTimer(() => this._DispatchEvent(VMRConsts.Events.DevicesUpdated), -20)
    }
    ToString() {
        local value := "VMR:`n"
        if (this.Type) {
            value .= "Logged into " . this.Type.name . " in (" . VBVMR.DLL_PATH . ")"
        }
        else {
            value .= "Not logged in"
        }
        return value
    }
    /**
     * @private - Internal method
     * @description Dispatches an event to all listeners.
     * 
     * @param {String} p_event - The name of the event to dispatch.
     * @param {Array} p_args - (Optional) An array of arguments to pass to the listeners.
     */
    _DispatchEvent(p_event, p_args*) {
        local eventListeners := this._eventListeners[p_event]
        if (eventListeners.Length == 0)
            return
        _eventDispatcher() {
            for (listener in eventListeners) {
                if (p_args.Length == 0 || listener.MaxParams < p_args.Length)
                    listener()
                else
                    listener(p_args*)
            }
        }
        SetTimer(_eventDispatcher, -1)
    }
    /**
     * @private - Internal method
     * @description Initializes VMR's components (bus/strip arrays, macroButton obj, etc).
     */
    _InitializeComponents() {
        this.Bus := Array()
        loop this.Type.busCount {
            this.Bus.Push(VMRBus(A_Index - 1, this.Type.id))
        }
        this.Strip := Array()
        loop this.Type.stripCount {
            this.Strip.Push(VMRStrip(A_Index - 1, this.Type.id))
        }
        if (this.Type.Id > 1)
            this.Recorder := VMRRecorder(this.Type)
        if (this.Type.Id == 3)
            this.Fx := VMRControllerBase("Fx", (*) => false)
        this.VBAN := VMRVBAN(this.Type)
        this.UpdateDevices()
        VMRAudioIO.IS_CLASS_INIT := true
    }
    /**
     * @private - Internal method
     * @description Updates the levels of all buses/strips.
     */
    _UpdateLevels() {
        local bus, strip
        for (bus in this.Bus) {
            bus._UpdateLevels()
        }
        for (strip in this.Strip) {
            strip._UpdateLevels()
        }
        this._DispatchEvent(VMRConsts.Events.LevelsUpdated)
    }
    /**
     * @private - Internal method
     * @description Prepares the VMR instance for deletion (turns off timers, etc..) and logs out of Voicemeeter.
     */
    __Delete(*) {
        if (!this.Type)
            return
        this.Type := ""
        this.Bus := ""
        this.Strip := ""
        if (this._syncTimer)
            SetTimer(this._syncTimer, 0)
        if (this._levelsTimer)
            SetTimer(this._levelsTimer, 0)
        if (this._updateDevicesCallback)
            OnMessage(VMRConsts.WM_DEVICE_CHANGE, this._updateDevicesCallback, 0)
        while (this.Sync()) {
        }
        ; Make sure all commands finish executing before logging out
        Sleep(100)
        VBVMR.Logout()
    }
    /**
     * Known Voicemeeter types info
     */
    class Types {
        static Count := 3
        static Standard := VMR.Types(1, "Voicemeeter", "voicemeeter.exe", 2, 3, 4)
        static Banana := VMR.Types(2, "Voicemeeter Banana", "voicemeeterpro.exe", 5, 5, 8)
        static Potato := VMR.Types(3, "Voicemeeter Potato", "voicemeeter8" (A_Is64bitOS ? "x64" : "") ".exe", 8, 8, 8)
        __New(id, name, executable, busCount, stripCount, vbanCount) {
            this.Id := id
            this.Name := name
            this.Executable := executable
            this.BusCount := busCount
            this.StripCount := stripCount
            this.VbanCount := vbanCount
        }
        /**
         * Returns the voicemeeter type with the specified id.
         * @param {Number} p_id - The id of the type.
         * @returns {VMR.Types} 
         */
        static GetType(p_id) {
            switch (p_id) {
                case 1:
                    return VMR.Types.Standard
                case 2:
                    return VMR.Types.Banana
                case 3:
                    return VMR.Types.Potato
            }
        }
    }
}
