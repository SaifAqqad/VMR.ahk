#Requires AutoHotkey >=2.0

#Include %A_ScriptDir%\..\src\VMR.ahk

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
auxInput := voicemeeter.Strip[5]

; Set initial Spotify volume
spotifyVol := 0.5
auxInput.AppGain["Spotify"] := spotifyVol

; Bind ctrl+M to toggle mute bus[1]
^M:: mainOutput.mute := -1

; Bind volume keys to increase/decrease bus[1] gain
Volume_Up:: mainOutput.Increment("gain", 1)
Volume_Down:: mainOutput.Increment("gain", -1)

/**
 * `Increment` and several other methods return a {@link VMRAsyncOp|`VMRAsyncOp`} object which allows you to pass a callback function that receives the result of the operation once it's done.    
 * 
 * While incrementing the gain directly (like `mainOutput.gain++`) and then getting the new value immediately might work, more often than not, the returned value will be wrong as the parameter has not been set yet,
 * this is because the voicemeeter API is asynchronous.
 * 
 * Functionally, VMRAsyncOp is similar to a js promise, but it actually just uses a timer to resolve the operation which then calls all registered callbacks.
 * @example <caption>Equivalent to the code below</caption>
 *    auxInput.gain += 5
 *    SetTimer(() => ToolTip(auxInput.gain) && SetTimer(() => ToolTip(), -1000), -50)
 */
^Volume_Up:: auxInput
    .Increment("gain", 5)
    .Then(gain => ToolTip(gain), 1000)
    .Then(() => ToolTip())
^Volume_Down:: auxInput
    .Increment("gain", -5)
    .Then(gain => ToolTip(gain), 1000)
    .Then(() => ToolTip())

monitorSpeakers := voicemeeter.GetBusDevice("LG") ; Get the first output device with "LG" in its name using the default driver (wdm)
microphone := voicemeeter.GetStripDevice("amazonbasics", "mme") ; Get the first input device with "amazonbasics" in its name using the mme driver
F6:: mainOutput.device := monitorSpeakers
F7:: voicemeeter.Strip[2].device := microphone

^G:: {
    MsgBox(mainOutput.Name " gain:" . mainOutput.gain . " dB")
    MsgBox(mainOutput.Name " gain percentage:" mainOutput.GainPercentage "%")
    MsgBox(mainOutput.Name " " (mainOutput.mute ? "Muted" : "Unmuted"))
}

; Not Supported yet
; ^Y:: voicemeeter.Commands.Show()

^K:: mainOutput.FadeBy(-3, 2000)
    .Then(finalGain => ToolTip("Faded to " finalGain " dB"))
; Or using a normal parameter setter:
; ^K:: mainOutput.FadeBy := "(-3.0, 2000)"

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
    ; auxInput.AppGain[1] := spotifyVol
}

; Increase Spotify volume by 0.1
^D:: {
    global spotifyVol += 0.1
    auxInput.AppGain["Spotify"] := spotifyVol
}
