---
layout: default
title: VMR Class
has_children: true
nav_order: 2
permalink: /VMR-Class 
has_toc: false
---

# VMR Class

---

## `__New([p_path])` Constructor
Initilizes the VBVMR class (the actual wrapper) by setting the DLL path and type (64/32) as well as the string encoding which is based on the type of AHK that's running the script (Unicode/ANSI), then loads the correct DLL and its functions addresses.


---

## Methods

## `login()`
Calls voicemeeter's login function and initilizes VMR class properties (objects and arrays).

This method needs to be called first, in order to use the VMR class.

*Note: for VMR to work properly, the script needs to be persistent, scripts that have GUIs or hotkeys are implicitly persistent, to make a regular script persistent add `#Persistent` to the top of the script*
{: .fs-3 }
## `getType()`
Returns voicemeeter's type.

`1` : voicemeeter

`2` : voicemeeter Banana

`3` : voicemeeter Potato
## `runVoicemeeter([type])`
Runs the highest version installed , or a specific version if `type` is passed

`type` : 

`1` : voicemeeter

`2` : voicemeeter Banana

`3` : voicemeeter Potato
## `updateDevices()`
Updates the internal array of input and output devices, that's used for setting bus/strips devices
## `exec(script)`
Executes a string of voicemeeter commands, see [`script_example.ahk`](https://github.com/SaifAqqad/VMR.ahk/blob/master/examples/script_example.ahk)

## `getBusDevices()/getStripDevices()`
Returns an array of input/output devices, each device is an object with `name` and `driver` properties

---

## Properties

## `bus` and `strip` Arrays
Array of [`bus`/`strip` objects]({{ site.baseurl }}{% link VMR-Class/bus-strip-object.md %}).

## [`recorder`]({{ site.baseurl }}{% link VMR-Class/recorder-object.md %})
Use this object to control voicemeeter's recorder.

## [`vban`]({{ site.baseurl }}{% link VMR-Class/vban-object.md %})
Use this object to control voicemeeter's VBAN interface

## [`command`]({{ site.baseurl }}{% link VMR-Class/command-object.md %})
Use this object to access command methods.

## [`option`]({{ site.baseurl }}{% link VMR-Class/option-object.md %})
Use this object to access/modify option parameters.

## [`macroButton`]({{ site.baseurl }}{% link VMR-Class/macrobutton-object.md %})
Use this object to access/modify macro buttons statuses.

## Callback functions
Set callback functions for certain events (e.g. to update a user interface)

* `onUpdateLevels` : called whenever the [`level`]({{ site.baseurl }}{% link VMR-Class/bus-strip-object.md %}#retrieve-the-current-level-of-a-busstrip) array for bus/strip objects is updated.
* `onUpdateParameters` : called whenever voicemeeter's parameters change on the UI or by another app.
* `onUpdateMacrobuttons` : called whenever a macrobutton's state is changed.
* `onMidiMessage`: called whenever voicemeeter receives a MIDI message
    
```lua
    ;--> Set a function object
    voicemeeter.onUpdateLevels:= Func("syncLevels")
```

{: .fs-4 }
* [See ui_example.ahk](https://github.com/SaifAqqad/VMR.ahk/blob/master/examples/ui_example.ahk)
<br>
* [See midi_message_example.ahk](https://github.com/SaifAqqad/VMR.ahk/blob/master/examples/midi_message_example.ahk)
<br>
* [More info on function objects (AHK docs)](https://www.autohotkey.com/docs/objects/Func.htm)
{: .fs-3 }
