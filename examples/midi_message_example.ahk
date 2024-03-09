#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\dist\VMR.ahk

Persistent(true)

voicemeeter := VMR().login()
voicemeeter.On(VMRConsts.Events.MidiMessage, WriteMidi)

/**
 * Receives an array with the hex-formatted bytes of the message and writes them to a file
 * 
 * @param {Array} p_midi - `[0xF0, 0xFF, ...]` An array of hex-formatted bytes that compose one or more MIDI messages.
 * - A single message is usually 2 or 3 bytes long
 * - The returned array will contain at most `1024` bytes.
 */
WriteMidi(p_midi) {
    FileAppend(Format("Midi Message: {}, {}, {}`n", p_midi[1], p_midi[2], p_midi[3]), "messages.txt")
}
