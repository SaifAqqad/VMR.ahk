#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\src\VMR.ahk

Persistent(true)

; This is just an example to demo the `Level` array
; It works best when the limits are set 20dBs apart

voicemeeter := VMR().Login()

/** @type {VMRBus} */
device := voicemeeter.Bus[1]

defaultGain := device.gain
upperLimit := -20
lowerLimit := -40

voicemeeter.On(VMRConsts.Events.LevelsUpdated, levelStabilizer)
OnExit(reset, -1)

; stabilizes the audio level by adjusting the gain
levelStabilizer() {
    static isStable := false

    ; get the current peak level
    lvl := Max(device.Level*)
    if (lvl = -999) { ; There's no sound
        device.gain := defaultGain
    }
    else if (lvl >= upperLimit) { ; The level is higher than the upper limit
        ; Lower the gain by 5dBs over 300 ms
        device.FadeBy(-5, 300)
        isStable := false
    }
    else if ((!isStable && device.gain < defaultGain) || lvl <= lowerLimit) {
        ; Raise the gain if the level isn't stable and is lower than the default_limit
        ; or if the level is lower than the lower_limit
        device.FadeBy(1, 200)
        if (lvl >= upperLimit)
            device.FadeBy(-1, 200)
        isStable := true
    }
}

reset() {
    ; Reset the bus's gain
    device.gain := defaultGain
    Sleep(100)
}

; Bind LCtrl + LShift + Q to exit
*<^<+Q:: ExitApp()