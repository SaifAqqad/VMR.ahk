## `recorder` <!-- {docsify-ignore-all} -->

Use this object to control VoiceMeeter Banana/Potato's recorder.

### Methods

* #### `ArmBus(index, [onOff])`
If `onOff` is passed to the method, it switches the recording mode to 1 (bus) and arms/disarms the given bus, otherwise it returns the state of the given bus.

* #### `ArmStrip(index, [onOff])`
If `onOff` is passed to the method, it switches the recording mode to 0 (strip) and arms/disarms the given strip, otherwise it returns the state of the given strip.

* #### `ArmStrips(index*)`
Switches the recording mode to 0 (strip), arms the given strips, disarming the others

---

### Parameters
for an up-to-date list of all `recorder` parameters, check out [VBVMR docs](https://download.vb-audio.com/Download_CABLE/VoicemeeterRemoteAPI.pdf#page=15)

---

### Examples
#### Set any parameter

```autohotkey
    voicemeeter.recorder.record := true
    voicemeeter.recorder.goto := "00:04:23"

    ; if no path is specified, the file is assumed to be in the Documents folder
    voicemeeter.recorder.load := "C:\audio\audioFile.mp3"
    
    ; use bracket syntax for parameters with '.'
    voicemeeter.recorder["mode.PlayOnLoad"] := true 
```

#### Retrieve any parameter
```autohotkey
    recorder_gain := voicemeeter.recorder.gain
```

#### Arm/Disarm buses and strips
```autohotkey
    voicemeeter.recorder.ArmBus(3,true)
    isArmed := voicemeeter.recorder.ArmBus(2)
    voicemeeter.recorder.ArmStrip(1,true)

    voicemeeter.recorder.ArmStrip(2,true) ; strip[2] is armed
    voicemeeter.recorder.ArmStrips(1,3,5) ; strip[2] is disarmed and strip[1,3,5] are all armed

```
