#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\dist\VMR.ahk

; Persistent() is needed to keep the script running in the background since no hotkeys are defined
Persistent(true)

/**
 *  This is just an example to demo the bus/strip `Level` array
 */
voicemeeter := VMR().Login()

/** @type {VMRBus} */
device := voicemeeter.Bus[1]

defaultGain := device.gain
upperLimit := -20
lowerLimit := -30

voicemeeter.On(VMRConsts.Events.LevelsUpdated, StabilizeLevel)
OnExit(Reset, -1)

; stabilizes the audio level by adjusting the gain
StabilizeLevel() {
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
        device.FadeBy(1, 300)
        if (lvl >= upperLimit)
            device.FadeBy(-1, 300)
        isStable := true
    }
}

Reset(*) {
    ; Reset the bus's gain
    device.gain := defaultGain
    Sleep(100)
}

; Bind LCtrl + LShift + Q to exit
*<^<+Q:: ExitApp()