#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\dist\VMR.ahk

Persistent(true)

voicemeeter := VMR().login()
voicemeeter.On(VMRConsts.Events.MidiMessage, writeMidi)

; Receives an array with the hex-formatted bytes of the message (every 3 elements represent a single midi message)
; Writes midi messages to a file (messages.txt)
writeMidi(midi) {
    FileAppend(Format("Midi Message: {}, {}, {}`n", midi[1], midi[2], midi[3]), "messages.txt")
}
