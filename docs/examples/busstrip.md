### Examples
#### Set any parameter

```autohotkey
    voicemeeter.Bus[1].gain := 10.5
    voicemeeter.Strip[3].FadeTo(-10.0, 3000)
    ; or you can use setParameter()
    voicemeeter.Bus[1].setParameter("gain", 10.5)
```

#### Retrieve any parameter
```autohotkey
    current_gain := voicemeeter.Bus[3].gain
    is_assigned := voicemeeter.Strip[1].B2
    is_muted := voicemeeter.Bus[1].mute
```

#### Set/Retrieve the device
```autohotkey
    ; Set the device of a bus/strip
    ; Bus[1].Device := VMRBus.GetDevice(deviceName, driver)
    ; driver can be ["wdm","mme","asio","ks]
    ; deviceName can be any substring of the full name
    voicemeeter.Strip[2].Device := VMRStrip.GetDevice("Microphone (2)", "ks")

    ; Retrieve the current device name
    device_name := voicemeeter.Bus[2].device.Name
```

#### Increment/decrement gain parameter
```autohotkey
    voicemeeter.Bus[3].gain--
    db := ++voicemeeter.Bus[1].gain 
    ; db contains the incremented value
```

#### Toggle mute parameter
```autohotkey
    voicemeeter.Bus[1].mute := 1

    ; a negative value will toggle the mute state
    voicemeeter.Bus[1].mute := -1
    is_muted := voicemeeter.Bus[1].mute ; 0

    ; or keep decrementing the value to toggle
    voicemeeter.Bus[1].mute--
    is_muted := voicemeeter.Bus[1].mute ; 1
```

#### Retrieve the current peak level of a Bus/Strip


```autohotkey
    peak_level := Max(voicemeeter.Bus[1].Level*)
```
<sub>See [level_stabilizer_example.ahk](https://github.com/SaifAqqad/VMR.ahk/blob/master/examples/level_stabilizer_example.ahk)</sub>
