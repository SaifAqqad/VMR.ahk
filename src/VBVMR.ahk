class VBVMR {
    static DLL
    , DLL_PATH
    , DLL_FILE
    , VM_TYPE
    , BUSCOUNT
    , STRIPCOUNT
    , STR_TYPE
    , VBANINCOUNT
    , VBANOUTCOUNT
    , FUNC_ADDR:={ Login:0
                 , Logout:0
                 , SetParameterFloat:0
                 , SetParameterStringW:0
                 , SetParameterStringA:0
                 , GetParameterFloat:0
                 , GetParameterStringW:0
                 , GetParameterStringA:0
                 , GetVoicemeeterType:0
                 , GetLevel:0
                 , Output_GetDeviceNumber:0
                 , Output_GetDeviceDescW:0
                 , Output_GetDeviceDescA:0
                 , Input_GetDeviceNumber:0
                 , Input_GetDeviceDescW:0
                 , Input_GetDeviceDescA:0
                 , IsParametersDirty:0
                 , MacroButton_IsDirty:0
                 , MacroButton_GetStatus:0
                 , MacroButton_SetStatus:0
                 , GetMidiMessage:0
                 , SetParameters:0
                 , SetParametersW:0}

    Login(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Login)
        if(errLevel<0)
            Throw, Exception(Format("`nVBVMR_Login returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        return errLevel
    }

    Logout(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Logout)
        if(errLevel<0)
            Throw, Exception(Format("`nVBVMR_Logout returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        return errLevel
    }

    SetParameterFloat(p_prefix, p_parameter, p_value){
        errLevel := DllCall(VBVMR.FUNC_ADDR.SetParameterFloat, "AStr" , p_prefix . "." . p_parameter , "Float" , p_value, "Int")
        if (errLevel<0)
            Throw, Exception(Format("`nVBVMR_SetParameterFloat returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        return p_value
    }

    SetParameterString(p_prefix, p_parameter, p_value){
        errLevel := DllCall(VBVMR.FUNC_ADDR["SetParameterString" . VBVMR.STR_TYPE], "AStr", p_prefix . "." . p_parameter , VBVMR.STR_TYPE . "Str" , p_value , "Int")
        if (errLevel<0)
            Throw, Exception(Format("`nVBVMR_SetParameterString returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        return p_value
    }

    GetParameterFloat(p_prefix, p_parameter){
        local value
        VarSetCapacity(value, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetParameterFloat, "AStr" , p_prefix . "." . p_parameter , "Ptr" , &value, "Int")
        if (errLevel<0)
            Throw, Exception(Format("`nVBVMR_GetParameterFloat returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        value := NumGet(&value, 0, "Float")
        return value
    }

    GetParameterString(p_prefix, p_parameter){
        local value
        VarSetCapacity(value, A_IsUnicode? 1024 : 512)
        errLevel := DllCall(VBVMR.FUNC_ADDR["GetParameterString" . VBVMR.STR_TYPE], "AStr" , p_prefix . "." . p_parameter , "Ptr" , &value , "Int")
        if (errLevel<0)
            Throw, Exception(Format("`nVBVMR_GetParameterString returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        value := StrGet(&value,512)
        return value
    }

    GetLevel(p_type, p_channel){
        local level
        VarSetCapacity(level,4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetLevel, "Int", p_type, "Int", p_channel, "Ptr", &level)
        if(errLevel<0){
            SetTimer,, Off
            Throw, Exception(Format("`nVBVMR_GetLevel returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        }
        level := NumGet(&level, 0, "Float")
        return level
    }

    GetVoicemeeterType(){
        local vtype
        VarSetCapacity(vtype, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetVoicemeeterType, "Ptr", &vtype, "Int")
        if(errLevel<0)
            Throw, Exception(Format("`nVBVMR_GetVoicemeeterType returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        vtype:= NumGet(&vtype, 0, "Int")
        return vtype
    }

    Output_GetDeviceNumber(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Output_GetDeviceNumber,"Int") 
        if(errLevel<0)
            Throw, Exception(Format("`nVBVMR_Output_GetDeviceNumber returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        else
            return errLevel
    }
    
    Output_GetDeviceDesc(p_index){
        local name, driver, device := {}
        VarSetCapacity(name, A_IsUnicode? 1024 : 512)
        VarSetCapacity(driver, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR["Output_GetDeviceDesc" . VBVMR.STR_TYPE], "Int", p_index, "Ptr" , &driver , "Ptr", &name, "Ptr", 0, "Int")
        if(errLevel<0)
            Throw, Exception(Format("`nVBVMR_Output_GetDeviceDesc returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        driver := NumGet(&driver, 0, "UInt")
        name := StrGet(&name,512)
        device.name := name
        device.driver := (driver=3 ? "wdm" : (driver=4 ? "ks" : (driver=5 ? "asio" : "mme"))) 
        return device
    }

    Input_GetDeviceNumber(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.Input_GetDeviceNumber,"Int") 
        if(errLevel<0)
            Throw, Exception(Format("`nVBVMR_Input_GetDeviceNumber returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        else
            return errLevel
    }

    Input_GetDeviceDesc(p_index){
        local name, driver, device := {}
        VarSetCapacity(name, A_IsUnicode? 1024 : 512)
        VarSetCapacity(driver, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR["Input_GetDeviceDesc" . VBVMR.STR_TYPE], "Int", p_index, "Ptr" , &driver , "Ptr", &name, "Ptr", 0, "Int")
        if(errLevel<0)
            Throw, Exception(Format("`nVBVMR_Input_GetDeviceDesc returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        driver := NumGet(&driver, 0, "UInt")
        name := StrGet(&name,512)
        device.name := name
        device.driver := (driver=3 ? "wdm" : (driver=4 ? "ks" : (driver=5 ? "asio" : "mme"))) 
        return device
    }

    IsParametersDirty(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.IsParametersDirty)
        if(errLevel<0)
            Throw, Exception(Format("`nVBVMR_IsParametersDirty returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        else
            return errLevel 
    }

    MacroButton_GetStatus(nuLogicalButton, bitMode){
        local pValue
        VarSetCapacity(pValue, 4)
        errLevel := DllCall(VBVMR.FUNC_ADDR.MacroButton_GetStatus, "Int" , nuLogicalButton , "Ptr", &pValue, "Int", bitMode, "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_MacroButton_GetStatus returned " . errLevel . "`n DllCall returned " . ErrorLevel, -1)
        pValue := NumGet(&pValue, 0, "Float")
        return pValue
    }
    
    MacroButton_SetStatus(nuLogicalButton, fValue, bitMode){
        errLevel := DllCall(VBVMR.FUNC_ADDR.MacroButton_SetStatus, "Int" ,  nuLogicalButton , "Float" , fValue, "Int", bitMode, "Int")
        if (errLevel<0)
            Throw, Exception("VBVMR_MacroButton_SetStatus returned " . errLevel, -1)
        return fValue
    }
    
    MacroButton_IsDirty(){
        errLevel := DllCall(VBVMR.FUNC_ADDR.MacroButton_IsDirty)
        if(errLevel<0)
            Throw, Exception("VBVMR_MacroButton_IsParametersDirty returned " . errLevel, -1)
        else
            return errLevel 
    }

    GetMidiMessage(){
        local nBytes:= 1024, dBuffer:="", tempArr:= Array()
        VarSetCapacity(dBuffer, nBytes)
        errLevel := DllCall(VBVMR.FUNC_ADDR.GetMidiMessage, "Ptr", &dBuffer, "Int", nBytes)
        if errLevel between -1 and -2
            Throw, Exception("VBVMR_GetMidiMessage returned " . errLevel, -1)
        loop %errLevel% {
            tempArr[A_Index]:= Format("0x{:X}",NumGet(&dBuffer, A_Index - 1, "UChar"))
        }
        return tempArr.Length()? tempArr : ""
    }

    SetParameters(script){
        errLevel := DllCall(VBVMR.FUNC_ADDR["SetParameters" . VBVMR.STR_TYPE], VBVMR.STR_TYPE . "Str" , script , "Int")
        if (errLevel<0)
            Throw, Exception(Format("`nVBVMR_SetParameters returned {}`nDllCall returned {}", errLevel, ErrorLevel))
        return errLevel
    }

    __getAddresses(){
        for fName in VBVMR.FUNC_ADDR 
            (VBVMR.FUNC_ADDR)[fName]:= DllCall("GetProcAddress", "Ptr", VBVMR.DLL, "AStr", "VBVMR_" . fName, "Ptr")
    }
}