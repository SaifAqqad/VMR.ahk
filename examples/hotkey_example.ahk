#Requires AutoHotkey >=2.0

#Include %A_ScriptDir%\..\dist\VMR.ahk

voicemeeter := VMR().login()

; Set the gain to 0 for all busses at startup
for (bus in voicemeeter.Bus) {
    bus.gain := 0
}

; jsdoc type annotations are not needed, but might allow your editor to offer relevant suggestions (see vscode-autohotkey2-lsp plugin)
/** @type {VMRBus} */
mainOutput := voicemeeter.Bus[1]
mainOutput.GainLimit := 0

/** @type {VMRStrip} */
auxInput := voicemeeter.Strip[6]

; Set initial Spotify volume
spotifyVol := 0.5
auxInput.AppGain["Spotify"] := spotifyVol

; Bind volume keys to increase/decrease bus[1] gain
Volume_Up:: mainOutput.gain++
Volume_Down:: mainOutput.gain--

; Bind ctrl+M to toggle mute bus[1]
^M:: mainOutput.mute := -1

^Volume_Up:: ToolTip(auxInput.gain += 5)
^Volume_Down:: ToolTip(auxInput.gain -= 5)

F6:: mainOutput.device := voicemeeter.GetBusDevice("LG") ; Sets bus[1] to the first device with "LG" in its name using the default driver (wdm)
F7:: voicemeeter.Strip[2].device := voicemeeter.GetStripDevice("amazonbasics", "mme")

^G:: {
    MsgBox(mainOutput.Name " gain:" . mainOutput.gain . " dB")
    MsgBox(mainOutput.Name " gain percentage:" mainOutput.GainPercentage "%")
    MsgBox(mainOutput.Name " " (mainOutput.mute ? "Muted" : "Unmuted"))
}

; Not Supported yet
; ^Y:: voicemeeter.Commands.Show()

^K:: mainOutput.FadeTo(-18.0, 2000)
; Or using a normal parameter setter:
; ^K:: mainOutput.FadeTo := "(-18.0, 2000)"

^T:: MsgBox(mainOutput.Name " Level: " . mainOutput.Level[1])

; Not Supported yet
; !r:: {
;     voicemeeter.recorder.ArmStrip(4, 1)
;     voicemeeter.recorder["mode.Loop"] := 1
;     voicemeeter.recorder.record := 1
; }

; Not Supported yet
; !s:: {
;     voicemeeter.recorder.stop := 1
;     voicemeeter.command.eject(1)
; }

; Decrease Spotify volume by 0.1
^A:: {
    global spotifyVol -= 0.1
    auxInput.AppGain["Spotify"] := spotifyVol
    ; Or using an index
    ; auxInput.App[1, "Gain"] := spotifyVol
}

; Increase Spotify volume by 0.1
^D:: {
    global spotifyVol += 0.1
    auxInput.AppGain["Spotify"] := spotifyVol
}
