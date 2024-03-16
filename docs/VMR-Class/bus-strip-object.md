## `bus`/`strip` <!-- {docsify-ignore-all} -->

Use this object to access or modify bus/strip parameters.

### Properties

* #### `gain_limit`
     The maximum gain (in dB) that can be applied to a bus/strip, Increamenting the gain above this value will reapply the limit
* #### `level` array
     Contains the current level (in dB) for every channel a bus/strip has, physical (hardware) strips have 2 channels (left, right), Buses and virtual strips have 8 channels
* #### `name`
     The name of the bus/strip (e.g. `A1`, `B1`, `Virtual Input #1`)

---
### Methods

* #### `setParameter(parameter, value)`
    Sets the value of a bus/strip's parameter
* #### `getParameter(parameter)`
    Returns the value of a bus/strip's parameter
* #### `getGainPercentage()`
    Returns the bus/strip's gain as a scalar percentage
* #### `setGainPercentage(percentage)`
    Sets the bus/strip's gain using a scalar percentage
* #### `getPercentage(dB)`
    Converts a dB value to a scalar percentage
* #### `getdB(percentage)`
    Converts a scalar percentage to a dB value
* #### `isPhysical()`
    Returns `1` if the bus/strip is a physical one (Hardware bus/strip), otherwise return `0`

---

### Parameters
for an up-to-date list of all `bus`/`strip` parameters, check out [VBVMR docs](http://download.vb-audio.com/Download_CABLE/VoicemeeterRemoteAPI.pdf#page=11)

---

### Examples
#### Set any parameter

```autohotkey
    voicemeeter.bus[1].gain := 10.5
    voicemeeter.strip[3].FadeTo := "(-10.0, 3000)"
    ; or you can use setParameter()
    voicemeeter.bus[1].setParameter("gain", 10.5)
```

#### Retrieve any parameter
```autohotkey
    current_gain := voicemeeter.bus[3].gain
    is_assigned := voicemeeter.strip[1].B2
    is_muted := voicemeeter.bus[1].mute
```

#### Set/Retrieve the device
```autohotkey
    ; bus[1].device[driver] := device_name
    ; driver can be ["wdm","mme","asio","ks]
    ; device_name can be any substring of the full name
    voicemeeter.strip[2].device["ks"] := "Microphone (2)" 

    ; Retrieve the device's name
    device_name := voicemeeter.bus[2].device
```

#### Increment/decrement gain parameter
```autohotkey
    voicemeeter.bus[3].gain--
    db := ++voicemeeter.bus[1].gain 
    ; db contains the incremented value
```

#### Toggle mute parameter
```autohotkey
    voicemeeter.bus[1].mute := 1

    voicemeeter.bus[1].mute := -1
    is_muted := voicemeeter.bus[1].mute ; 0
    ; or
    voicemeeter.bus[1].mute--
    is_muted := voicemeeter.bus[1].mute ; 1
```

#### Retrieve the current peak level of a bus/strip


```autohotkey
    peak_level := Max(voicemeeter.bus[1].level*)
```
<sub>See [level_stabilizer_example.ahk](https://github.com/SaifAqqad/VMR.ahk/blob/v1/examples/level_stabilizer_example.ahk)</sub>
