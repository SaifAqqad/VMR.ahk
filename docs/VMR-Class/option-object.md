## `option` <!-- {docsify-ignore-all} -->

Use this object to access/modify option parameters.

### Methods

* #### `delay(busIndex, [delay])`
Set the bus output delay. If `delay` is not passed, it will return the current delay for that bus

---

### Parameters
for an up-to-date list of all `option` parameters, check out [VBVMR docs](https://download.vb-audio.com/Download_CABLE/VoicemeeterRemoteAPI.pdf#page=14)

---

### Examples
#### Set any parameter

```autohotkey
    voicemeeter.option.sr := 44.1
    voicemeeter.option["buffer.wdm"] := 1024
    voicemeeter.option.delay(2,200)
```
#### Retrieve any parameter
```autohotkey
    is_exclusif := voicemeeter.option["mode.exclusif"]
    delay := voicemeeter.option.delay(1)
```

