---
layout: default
title: Recorder
parent: VMR Class
nav_order: 3
---
# `recorder`

Use this object to control VoiceMeeter Banana/Potato's recorder.

---
for a list of all `recorder` parameters, check out [VBVMR docs](http://download.vb-audio.com/Download_CABLE/VoicemeeterRemoteAPI.pdf#page=15)
{: .fs-3 }

## Set any parameter

```lua
    voicemeeter.recorder.record:= true
    voicemeeter.recorder.goto:= "00:04:23"

    ;--if no path is specified, the file is assumed to be in the Documents folder
    voicemeeter.recorder.load:= "C:\audio\audioFile.mp3"
    
    ;--use bracket syntax for parameters with '.'
    voicemeeter.recorder["mode.PlayOnLoad"]:= true 
```

## Retrieve any parameter
```lua
    recorder_gain:= voicemeeter.recorder.gain
```

---

## Methods

## `ArmBus(index, [onOff])`
If `onOff` is passed to the method, it switches the recording mode to 1 (bus) and arms/disarms the given bus

```lua
    voicemeeter.recorder.ArmBus(3,true)
```
If `onOff` is not passed, it will return the state of the given bus (armed/disarmed)

```lua
    isArmed:= voicemeeter.recorder.ArmBus(2)
```

## `ArmStrip(index, [onOff])`
If `onOff` is passed to the method, it switches the recording mode to 0 (strip) and arms/disarms the given strip

```lua
    voicemeeter.recorder.ArmStrip(1,true)
    voicemeeter.recorder.ArmStrip(2,false)
```
If `onOff` is not passed, it will return the state of the given strip (armed/disarmed)

```lua
    isArmed:= voicemeeter.recorder.ArmStrip(5)
```

## `ArmStrips(index*)`
Swtiches the recording mode to 0 (strip), arms the given strips, disarming the others

```lua
    voicemeeter.recorder.ArmStrip(2,true) ;--> 2->armed
    voicemeeter.recorder.ArmStrips(1,3,5) ;--> 2->disarmed 1,3,5->armed
```