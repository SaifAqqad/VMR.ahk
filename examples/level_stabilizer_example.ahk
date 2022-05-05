#Include, %A_ScriptDir%\..\dist\VMR.ahk
#Persistent

; This is just an example to demo the `level` array
; It works best when the limits are set 20dBs apart

global voicemeeter:= (new VMR).login()
, device := voicemeeter.bus[1]
, default_gain := device.gain
, upper_limit := -20
, lower_limit := -40
voicemeeter.onUpdateLevels:= Func("levelStabilizer")
OnExit("reset",-1)

; stabilize the audio level by adjusting the gain
levelStabilizer(){
    static is_stable
    lvl:= Max(device.level*) ; get the current peak level
    if(lvl = -999) ; if there's no sound
        device.gain:= default_gain
    else if(lvl >= upper_limit){ ; if the level is higher than the upper_limit
        device.FadeTo := "(" device.gain-5 ", 300)" ; lower the gain by 5dBs over 200 ms
        is_stable:=0
    }else if((device.gain < default_gain && !is_stable) || lvl <= lower_limit ){
        ; raise the gain if the level is lower than the lower_limit
        ; or if the level isn't stable and is lower than the default_limit
        device.FadeTo := "(" device.gain+1 ", 200)"
        if(lvl >= upper_limit)
            device.FadeTo := "(" device.gain-1 ", 200)"
        is_stable:=1
    }
}

reset(){
    device.gain:= default_gain ; reset to default gain
    Sleep, 100
}

*<^<+Q:: ;bind LCtrl + LShift + Q to exit
ExitApp