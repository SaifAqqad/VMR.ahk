#Requires AutoHotkey >=2.0

#Include %A_ScriptDir%\..\dist\VMR.ahk

voicemeeter := VMR().Login()

; Set the gain to 0 for all busses at startup
for (bus in voicemeeter.Bus) {
    bus.gain := 0
}

; jsdoc type annotations are not needed, but might allow your editor to offer relevant suggestions (see vscode-autohotkey2-lsp plugin)
/** @type {VMRBus} */
mainOutput := voicemeeter.Bus[1]
mainOutput.GainLimit := 0

/** @type {VMRStrip} */
auxInput := voicemeeter.Strip[3]

; Check if we're running voicemeeter potato
if (voicemeeter.Type == VMR.Types.Potato) {
    ; Set initial Spotify volume
    spotifyVol := 0.5
    auxInput.AppGain["Spotify"] := spotifyVol
}

; Bind ctrl+M to toggle mute bus[1]
^M:: mainOutput.mute := -1

; Bind volume keys to increase/decrease bus[1] gain
Volume_Up:: mainOutput.gain++
Volume_Down:: mainOutput.gain--
; Or using the increment method (check below for an explanation)
; Volume_Up:: mainOutput.Increment("gain", 1).Then(DisplayTooltip)
; Volume_Down:: mainOutput.Increment("gain", -1).Then(DisplayTooltip)

/**
 * `Increment` and several other methods return a {@link VMRAsyncOp|`VMRAsyncOp`} object which allows you to pass a callback function that receives the result of the operation once it's done.    
 * 
 * Although incrementing the gain directly (like this: `mainOutput.gain++`) and then getting the new value immediately might work, more often than not, the returned value will be wrong as the parameter has not been set yet,
 * this happens because the voicemeeter API is asynchronous.
 * 
 * Functionally, VMRAsyncOp is similar to a javascript promise, but it actually just uses a timer to resolve the operation which then calls all registered callbacks.
 * 
 * @example <caption>Equivalent to the code below but without VMRAsyncOp</caption>
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

monitorSpeakers := voicemeeter.GetBusDevice("LG") ; Returns the first output device with "LG" in its name using the default driver (wdm)
microphone := voicemeeter.GetStripDevice("amazonbasics", "mme") ; Get the first input device with "amazonbasics" in its name using the mme driver
F6:: mainOutput.device := monitorSpeakers
F7:: voicemeeter.Strip[2].device := microphone

^G:: {
    MsgBox(mainOutput.Name " gain:" . mainOutput.gain . " dB")
    MsgBox(mainOutput.Name " gain percentage:" mainOutput.GainPercentage "%")
    MsgBox(mainOutput.Name " " (mainOutput.mute ? "Muted" : "Unmuted"))
}

^Y:: voicemeeter.Command.Show()

^K:: mainOutput.FadeBy(-3, 2000)
    .Then(finalGain => ToolTip("Faded to " finalGain " dB"), 3000)
    .Then(() => ToolTip())
; Or using a normal parameter setter:
; ^K:: mainOutput.FadeBy := "(-3.0, 2000)"

^T:: MsgBox(mainOutput.Name " Level: " . mainOutput.Level[1])

!r:: {
    voicemeeter.Recorder.ArmStrip[4] := true
    voicemeeter.Recorder.mode["loop"] := 1 ; Or voicemeeter.Recorder.SetParameter("mode.loop", 1)
    voicemeeter.Recorder.record := true
}

!e:: {
    voicemeeter.Recorder.stop := true
    voicemeeter.Command.Eject()
}

; Decrease Spotify volume by 0.1
^A:: {
    global spotifyVol := VMRUtils.EnsureBetween(spotifyVol - 0.1, 0, 1)
    auxInput.AppGain["Spotify"] := spotifyVol
    DisplayTooltip("Spotify: " spotifyVol)
    ; Or using an index
    ; auxInput.AppGain[1] := spotifyVol
}

; Increase Spotify volume by 0.1
^D:: {
    global spotifyVol := VMRUtils.EnsureBetween(spotifyVol + 0.1, 0, 1)
    auxInput.AppGain["Spotify"] := spotifyVol
    DisplayTooltip("Spotify: " spotifyVol)
}

; Show/hide voicemeeter
!S:: voicemeeter.Command.Show(true)
^!S:: voicemeeter.Command.Show(false)

DisplayTooltip(txt) {
    ToolTip(txt)
    SetTimer(HideTooltip, -2000)

    static HideTooltip() {
        ToolTip()
    }
}
