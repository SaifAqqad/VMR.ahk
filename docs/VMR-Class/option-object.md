---
layout: default
title: Option
parent: VMR Class
nav_order: 6
---
# `option`

Use this object to access/modify option parameters.

---
for a list of all `option` parameters, check out [VBVMR docs](http://download.vb-audio.com/Download_CABLE/VoicemeeterRemoteAPI.pdf#page=14)
{: .fs-3 }

## Set any parameter

```lua
    voicemeeter.option.sr:= 44.1
    voicemeeter.option["buffer.wdm"]:= 1024
```

## Retrieve any parameter
```lua
    is_exclusif:= voicemeeter.option["mode.exclusif"]
```

---

## Methods

## `delay(busIndex, [delay])`
Changes the bus's output delay

```lua
    voicemeeter.option.delay(2,200)
```
If `delay` is not passed, it will return the current delay  for that bus
```lua
    delay:= voicemeeter.option.delay(1)
```
