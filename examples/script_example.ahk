#Include, ..\VMR.ahk
#Persistent

voicemeeter := new VMR()
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
voicemeeter.login()
voicemeeter.exec(script)
sleep 100 ; delay exit to alow the script to be executed
ExitApp