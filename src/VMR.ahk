; VMR-header
class VMR{
    bus:=""
    , strip:=""
    , recorder:=""
    , option:=""
    , patch:=""
    , fx:=""
    , onUpdateLevels:=""
    , onUpdateParameters:=""
    , onUpdateMacrobuttons:=""
    , onMidiMessage:=""
    
    __New(p_path:=""){
        VBVMR.DLL_PATH :=  p_path? p_path : this.__getDLLPath()
        VBVMR.DLL_FILE := A_PtrSize = 8 ? "VoicemeeterRemote64.dll" : "VoicemeeterRemote.dll"
        if(!FileExist(VBVMR.DLL_PATH . "\" . VBVMR.DLL_FILE))
            Throw, Exception(Format("Voicemeeter is not installed in the path :`n{}", VBVMR.DLL_PATH))
        VBVMR.STR_TYPE := A_IsUnicode? "W" : "A"
        VBVMR.DLL := DllCall("LoadLibrary", "Str", VBVMR.DLL_PATH . "\" . VBVMR.DLL_FILE, "Ptr")
        VBVMR.__getAddresses()
    }

    login(){
        if(VBVMR.Login()){
            this.runVoicemeeter()
            WinWait, ahk_class VBCABLE0Voicemeeter0MainWindow0
            sleep, 2000
        }
        OnExit(ObjBindMethod(this, "__onExit"))
        syncWithDLL := ObjBindMethod(this, "__syncWithDLL")
        SetTimer, %syncWithDLL%, 20
        this.getType()
        this.__init_arrays()
        this.__init_obj()
        this.__syncWithDLL()
        return this
    }
    
    
    getType(){
        if(!VBVMR.VM_TYPE){
            VBVMR.VM_TYPE:= VBVMR.GetVoicemeeterType()
            Switch VBVMR.VM_TYPE {
                case 1:
                    VBVMR.BUSCOUNT:= 2
                    VBVMR.STRIPCOUNT:= 3
                    VBVMR.VBANINCOUNT:= 4
                    VBVMR.VBANOUTCOUNT:= 4
                case 2:
                    VBVMR.BUSCOUNT:= 5
                    VBVMR.STRIPCOUNT:= 5
                    VBVMR.VBANINCOUNT:= 8
                    VBVMR.VBANOUTCOUNT:= 8
                case 3:
                    VBVMR.BUSCOUNT:= 8
                    VBVMR.STRIPCOUNT:= 8
                    VBVMR.VBANINCOUNT:= 8
                    VBVMR.VBANOUTCOUNT:= 8
            }
        }
        return VBVMR.VM_TYPE
    }

    runVoicemeeter(p_type := ""){
        if(p_type){
            Run, % VBVMR.DLL_PATH "\" this.__getTypeExecutable(p_type) , % VBVMR.DLL_PATH, UseErrorLevel Hide
        }else{
            loop 3 {
                Run, % VBVMR.DLL_PATH "\" this.__getTypeExecutable(4-A_Index) , % VBVMR.DLL_PATH, UseErrorLevel Hide
                if(!ErrorLevel)
                    return
            }
        }
        if(ErrorLevel)
            Throw, Exception("Could not run Voicemeeter")
    }

    updateDevices(){
        VMR.BusStrip.BusDevices:= Array()
        VMR.BusStrip.StripDevices:= Array()
        loop % VBVMR.Output_GetDeviceNumber()
            VMR.BusStrip.BusDevices.Push(VBVMR.Output_GetDeviceDesc(A_Index-1))
        loop % VBVMR.Input_GetDeviceNumber()
            VMR.BusStrip.StripDevices.Push(VBVMR.Input_GetDeviceDesc(A_Index-1))
    }

    getBusDevices(){
        return VMR.BusStrip.BusDevices
    }

    getStripDevices(){
        return VMR.BusStrip.StripDevices
    }

    exec(script){
        Try errLn:= VBVMR.SetParameters(script)
        if(errLn != 0)
            Throw, Exception("exec:`nScript error at line " . errLn)
        return errLn
    }

    __getDLLPath(){
        vmkey := "VB:Voicemeeter {17359A74-1236-5467}"
        key := "HKLM\Software{}\Microsoft\Windows\CurrentVersion\Uninstall\{}"
        Try RegRead, value, % Format(key, A_Is64bitOS?"\WOW6432Node":"", vmkey), UninstallString
        catch {
            Throw, Exception("Voicemeeter is not installed")
        }
        SplitPath, value,, dir
        return dir
    }
    
    __init_obj(){
        this.option:= new this.OptionBase
        this.vban.init()
        this.vban.stream.initiated:=1
        if(this.getType() >= 2){
            this.patch:= new this.PatchBase
            this.recorder:= new this.RecorderBase
        }
        if(this.getType() >= 3)
            this.fx := new this.FXBase
    }

    __init_arrays(){
        this.bus:= Array()
        this.strip:= Array()
        loop % VBVMR.BUSCOUNT {
            this.bus.Push(new this.BusStrip("Bus"))
        }
        loop % VBVMR.STRIPCOUNT {
            this.strip.Push(new this.BusStrip("Strip"))
        }
        this.updateDevices()
        VMR.BusStrip.initiated:=1
    }

    __getTypeExecutable(p_type){
        switch (p_type) {
            case 1: return "voicemeeter.exe"
            case 2: return "voicemeeterpro.exe"
            case 3: return Format("voicemeeter8{}.exe", A_Is64bitOS? "x64":"")
        }
    }

    __syncWithDLL(){
        static ignore_msg:=0
        try {
            ;sync vmr parameters
            isParametersDirty:= VBVMR.IsParametersDirty()
            
            ;sync macro buttons states
            isMacroButtonsDirty:= VBVMR.MacroButton_IsDirty()

            ;sync bus/strip level arrays
            loop % VBVMR.BUSCOUNT {
                this.bus[A_Index].__updateLevel()
            }
            loop % VBVMR.STRIPCOUNT {
                this.strip[A_Index].__updateLevel()
            }

            ;sync successful
            ignore_msg:=0

            ;level callback
            if(this.onUpdateLevels){
                this.onUpdateLevels.Call()
            }

            ;parameter callback
            if(isParametersDirty && this.onUpdateParameters){
                this.onUpdateParameters.Call()
            }

            ;macrobutton callback
            if(isMacroButtonsDirty && this.onUpdateMacrobuttons){
                this.onUpdateMacrobuttons.Call()
            }

            ;midi callback
            if(this.onMidiMessage && midiMessages:= VBVMR.GetMidiMessage()){
                this.onMidiMessage.Call(midiMessages)
            }
            return isParametersDirty || isMacroButtonsDirty || midiMessages
        } catch e {
            if(!ignore_msg){
                MsgBox, 52, VMR.ahk, % Format("An error occurred during synchronization: {}`nAttempt to restart VoiceMeeter?", e.Message), 10
                IfMsgBox Yes
                    this.runVoicemeeter(VBVMR.VM_TYPE)
                IfMsgBox, No
                    ignore_msg:=1
                IfMsgBox, Timeout
                    ignore_msg:=1
                sleep, 1000
            }
        }
    }

    __onExit(){
        while(this.__syncWithDLL()){ 
        }
        Sleep, 100 ; to make sure all commands are executed before exiting
        VBVMR.Logout()
        DllCall("FreeLibrary", "Ptr", VBVMR.DLL)
    }
    
    ; VMR-include './BusStrip.ahk'

    ; VMR-include './Fx.ahk'

    ; VMR-include './Command.ahk'
    
    ; VMR-include './VBAN.ahk'

    ; VMR-include './MacroButton.ahk'

    ; VMR-include './Patch.ahk'

    ; VMR-include './Option.ahk'

    ; VMR-include './Recorder.ahk'
}

; VMR-include './VBVMR.ahk'