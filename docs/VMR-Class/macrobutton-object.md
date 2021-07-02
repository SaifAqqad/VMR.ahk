---
layout: default
title: MacroButton
parent: VMR Class
nav_order: 7
---
# `macroButton`

Use this object to access/modify macro buttons status.

---
## Methods

## `setStatus(nuLogicalButton, fValue, bitMode)`
Set the status of a macro button

```lua
    ;--> sets macro button 1 to have trigger on
    voicemeeter.macroButton.setStatus(1,1,3)

    ;--> set macrobutton 2 to on.
    voicemeeter.macroButton.setStatus(2,1,1)
```

## `getStatus(nuLogicalButton, bitMode)`
Retrieve the status of a macro button

```lua
    buttonStatus:= voicemeeter.macroButton.getStatus(1,3)
```
{: .fs-4 }

See [VBVMR docs](http://download.vb-audio.com/Download_CABLE/VoicemeeterRemoteAPI.pdf#page=8)
{: .fs-3 }