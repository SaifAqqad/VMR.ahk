#Include, %A_ScriptDir%\..\VMR.ahk
#Persistent

global voicemeeter := (new VMR).login()
AhkScript()
;VoiceMeeterScript()
ExitApp

AhkScript(){
    ; this is an AHK script
    ; indexes are one-based
    voicemeeter.strip[1].A1 := 1
    voicemeeter.strip[1].B1 := 0
    voicemeeter.bus[2].gain := -6.0
    voicemeeter.strip[3].gain := 12.0
    voicemeeter.recorder.A1 := 1
    voicemeeter.vban.outstream[4].name := "stream example"
}

; OR

VoiceMeeterScript(){
    script =
    ( LTrim Comments
        ; this is a voicemeeter script (not AHK)
        ; indexes are zero-based
        Strip[0].A1 = 1
        Strip[0].B1 = 0
        Bus[1].gain = -6.0
        Strip[2].gain = 12.0
        Recorder.A1 = 1
        vban.outstream[3].name = "stream example"
    )
    voicemeeter.exec(script)
}