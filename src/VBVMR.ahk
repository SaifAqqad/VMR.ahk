#Requires AutoHotkey >=2.0
#Include VMRError.ahk

class VBVMR {
    static REG_KEY := "HKLM\Software{}\Microsoft\Windows\CurrentVersion\Uninstall\VB:Voicemeeter {17359A74-1236-5467}"
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

    static Init(p_path := "") {
        if (VBVMR.DLL != "")
            return

        local dllPath := p_path ? p_path : VBVMR.GetDLLPath()
        dllPath .= A_PtrSize = 8 ? "\VoicemeeterRemote64.dll" : "\VoicemeeterRemote.dll"

        if (!FileExist(dllPath))
            throw VMRError(VBVMR.Init.Name, "Voicemeeter is not installed in the path :`n" . dllPath, A_LineNumber)

        ; Load the voicemeeter DLL
        VBVMR.DLL := DllCall("LoadLibrary", "Str", dllPath, "Ptr")

        ; Get the addresses of all needed function
        for fName in VBVMR.FUNC.OwnProps() {
            (VBVMR.FUNC)[fName] := DllCall("GetProcAddress", "Ptr", VBVMR.DLL, "AStr", "VBVMR_" . fName, "Ptr")
        }
    }

    static GetDLLPath() {
        local value := "", dir := ""
        try
            value := RegRead(Format(VBVMR.REG_KEY, A_Is64bitOS ? "\WOW6432Node" : ""), "UninstallString")
        catch
            Throw VMRError(VBVMR.GetDLLPath.Name, "Failed to retrieve the installation path of Voicemeeter", A_LineNumber)

        SplitPath(value, , &dir)
        return dir
    }

    static Login() {
        local result

        try result := DllCall(VBVMR.FUNC.Login)
        catch Error as err
            throw VMRError(VBVMR.Login.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.Login.Name, result, A_LineNumber)

        return result
    }

    static Logout() {
        local result

        try result := DllCall(VBVMR.FUNC.Logout)
        catch Error as err
            throw VMRError(VBVMR.Logout.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.Logout.Name, result, A_LineNumber)

        return result
    }

    static SetParameterFloat(p_prefix, p_parameter, p_value) {
        local result

        try result := DllCall(VBVMR.FUNC.SetParameterFloat, "AStr", p_prefix . "." . p_parameter, "Float", p_value, "Int")
        catch Error as err
            throw VMRError(VBVMR.SetParameterFloat.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.SetParameterFloat.Name, result, A_LineNumber)

        return result
    }

    static SetParameterString(p_prefix, p_parameter, p_value) {
        local result

        try result := DllCall(VBVMR.FUNC.SetParameterStringW, "AStr", p_prefix . "." . p_parameter, "WStr", p_value, "Int")
        catch Error as err
            throw VMRError(VBVMR.SetParameterString.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.SetParameterString.Name, result, A_LineNumber)

        return result
    }

    static GetParameterFloat(p_prefix, p_parameter) {
        local result, value := Buffer(4)

        try result := DllCall(VBVMR.FUNC.GetParameterFloat, "AStr", p_prefix . "." . p_parameter, "Ptr", value, "Int")
        catch Error as err
            throw VMRError(VBVMR.GetParameterFloat.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.GetParameterFloat.Name, result, A_LineNumber)

        value := NumGet(value, 0, "Float")
        return value
    }

    static GetParameterString(p_prefix, p_parameter) {
        local result, value := Buffer(1024)

        try result := DllCall(VBVMR.FUNC.GetParameterFloat, "AStr", p_prefix . "." . p_parameter, "Ptr", value, "Int")
        catch Error as err
            throw VMRError(VBVMR.GetParameterString.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.GetParameterString.Name, result, A_LineNumber)

        return StrGet(value, 512)
    }

    static GetLevel(p_type, p_channel) {
        local result, level := Buffer(4)

        try result := DllCall(VBVMR.FUNC.GetLevel, "Int", p_type, "Int", p_channel, "Ptr", level)
        catch Error as err
            throw VMRError(VBVMR.GetLevel.Name, err, A_LineNumber)

        if (result < 0) {
            SetTimer(unset, 0)
            return
        }

        return NumGet(level, 0, "Float")
    }

    static GetVoicemeeterType() {
        local result, vtype := Buffer(4)

        try result := DllCall(VBVMR.FUNC.GetVoicemeeterType, "Ptr", vtype, "Int")
        catch Error as err
            throw VMRError(VBVMR.GetVoicemeeterType.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.GetVoicemeeterType.Name, result, A_LineNumber)

        return NumGet(vtype, 0, "Int")
    }

    static Output_GetDeviceNumber() {
        local result

        try result := DllCall(VBVMR.FUNC.Output_GetDeviceNumber, "Int")
        catch Error as err
            throw VMRError(VBVMR.Output_GetDeviceNumber.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.Output_GetDeviceNumber.Name, result, A_LineNumber)

        return result
    }

    static Output_GetDeviceDesc(p_index) {
        local result, name := Buffer(1024),
            driver := Buffer(4)

        try result := DllCall(VBVMR.FUNC.Output_GetDeviceDescW, "Int", p_index, "Ptr", driver, "Ptr", name, "Ptr", 0, "Int")
        catch Error as err
            throw VMRError(VBVMR.Output_GetDeviceDesc.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.Output_GetDeviceDesc.Name, result, A_LineNumber)

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

    static Input_GetDeviceNumber() {
        local result

        try result := DllCall(VBVMR.FUNC.Input_GetDeviceNumber, "Int")
        catch Error as err
            throw VMRError(VBVMR.Input_GetDeviceNumber.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.Input_GetDeviceNumber.Name, result, A_LineNumber)

        return result
    }

    static Input_GetDeviceDesc(p_index) {
        local result, name := Buffer(1024),
            driver := Buffer(4)

        try result := DllCall(VBVMR.FUNC.Input_GetDeviceDescW, "Int", p_index, "Ptr", driver, "Ptr", name, "Ptr", 0, "Int")
        catch Error as err
            throw VMRError(VBVMR.Input_GetDeviceDesc.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.Input_GetDeviceDesc.Name, result, A_LineNumber)

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

    static IsParametersDirty() {
        local result

        try result := DllCall(VBVMR.FUNC.IsParametersDirty)
        catch Error as err
            throw VMRError(VBVMR.IsParametersDirty.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.IsParametersDirty.Name, result, A_LineNumber)

        return result
    }

    static MacroButton_GetStatus(nuLogicalButton, bitMode) {
        local pValue := Buffer(4)

        try errLevel := DllCall(VBVMR.FUNC.MacroButton_GetStatus, "Int", nuLogicalButton, "Ptr", pValue, "Int", bitMode, "Int")
        catch Error as err
            throw VMRError(VBVMR.MacroButton_GetStatus.Name, err, A_LineNumber)

        if (errLevel < 0)
            throw VMRError(VBVMR.MacroButton_GetStatus.Name, errLevel, A_LineNumber)

        return NumGet(pValue, 0, "Float")
    }

    static MacroButton_SetStatus(nuLogicalButton, fValue, bitMode) {
        local result

        try result := DllCall(VBVMR.FUNC.MacroButton_SetStatus, "Int", nuLogicalButton, "Float", fValue, "Int", bitMode, "Int")
        catch Error as err
            throw VMRError(VBVMR.MacroButton_SetStatus.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.MacroButton_SetStatus.Name, result, A_LineNumber)

        return fValue
    }

    static MacroButton_IsDirty() {
        local result

        try result := DllCall(VBVMR.FUNC.MacroButton_IsDirty)
        catch Error as err
            throw VMRError(VBVMR.MacroButton_IsDirty.Name, err, A_LineNumber)

        if (result < 0)
            throw VMRError(VBVMR.MacroButton_IsDirty.Name, result, A_LineNumber)

        return result
    }

    static GetMidiMessage() {
        local result, data := Buffer(1024),
            messages := []

        try result := DllCall(VBVMR.FUNC.GetMidiMessage, "Ptr", data, "Int", 1024)
        catch Error as err
            throw VMRError(VBVMR.GetMidiMessage.Name, err, A_LineNumber)

        if (result == -1)
            throw VMRError(VBVMR.GetMidiMessage.Name, result, A_LineNumber)

        if (result < 1)
            return ""

        loop (result) {
            messages.Push(Format("0x{:X}", NumGet(data, A_Index - 1, "UChar")))
        }

        return messages
    }

    static SetParameters(script) {
        local result

        try result := DllCall(VBVMR.FUNC.SetParametersW, "WStr", script, "Int")
        catch Error as err
            throw VMRError(VBVMR.SetParameters.Name, err, A_LineNumber)

        if (result < 0)
            return ""

        return result
    }
}