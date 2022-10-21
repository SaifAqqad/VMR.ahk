class MacroButton {

    run(){
        Run, % VBVMR.DLL_PATH "\VoicemeeterMacroButtons.exe", % VBVMR.DLL_PATH, UseErrorLevel
        if(ErrorLevel)
            Throw, Exception("Could not run MacroButtons")
    }

    show(state := 1){
        if(state)
            WinShow, ahk_exe VoicemeeterMacroButtons.exe
        else
            WinHide, ahk_exe VoicemeeterMacroButtons.exe
    }

    setStatus(buttonIndex, newStatus, bitmode:=0) {
        return VBVMR.MacroButton_SetStatus(buttonIndex, newStatus, bitmode)
    }
    
    getStatus(buttonIndex, bitmode:=0){
        return VBVMR.MacroButton_GetStatus(buttonIndex, bitmode)
    }
    
}
