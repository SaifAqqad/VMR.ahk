#Include, ..\VMR.ahk
#Persistent

global voicemeeter := new VMR()
voicemeeter.login()
voicemeeter.onMidiMessage:= Func("writeMidi")
return

; recieves an array of bytes that represents midi messages (every 3 elements represent a single midi message)
; writes midi messages to a file (messages.txt)
writeMidi(midi){
    FileAppend,% Format("Midi Message: {}, {}, {}`n",midi[1],midi[2],midi[3]), messages.txt
}
