#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\dist\VMR.ahk

Persistent(true)

voicemeeter := VMR().login()

/**
 * Scripts can be written in AHK (indices are one-based)
 */
voicemeeter.Strip[1].A1 := true
voicemeeter.Strip[1].B1 := false
voicemeeter.Bus[2].gain := -6.0
voicemeeter.Strip[3].gain := 12.0
voicemeeter.Recorder.A1 := 1
voicemeeter.VBAN.Outstream[4].name := "stream example"

/**
 * Or as a string of voiceemeeter commands (indices are zero-based)
 * - Useful for loading scripts from a file
 * - Commands can be delimited by newlines or semicolons (see {@link VMR.Exec|VMR.Exec()})
 */
script := "
    ( LTrim
        Strip[0].A1 = 1
        Strip[0].B1 = 0
        Bus[1].gain = -6.0
        Strip[2].gain = 12.0
        Recorder.A1 = 1
        vban.outstream[3].name = "stream example"
    )"
voicemeeter.Exec(script)

ExitApp()