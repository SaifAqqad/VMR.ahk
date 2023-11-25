#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\dist\VMR.ahk

Persistent(true)

voicemeeter := VMR().login()
AhkScript()
VoiceMeeterScript()
ExitApp()

AhkScript(){
    global voicemeeter
    ; this is an AHK script
    ; indices are one-based
    voicemeeter.Strip[1].A1 := true
    voicemeeter.Strip[1].B1 := false
    voicemeeter.Bus[2].gain := -6.0
    voicemeeter.Strip[3].gain := 12.0
    ; Not Supported yet
    ; voicemeeter.recorder.A1 := 1
    ; voicemeeter.vban.outstream[4].name := "stream example"
}

; OR

VoiceMeeterScript(){
    local script := "
    ( LTrim Comments
        ; this is a voicemeeter script (not AHK)
        ; indices are zero-based
        Strip[0].A1 = 1
        Strip[0].B1 = 0
        Bus[1].gain = -6.0
        Strip[2].gain = 12.0
        Recorder.A1 = 1
        vban.outstream[3].name = "stream example"
    )"
    voicemeeter.Exec(script)
}