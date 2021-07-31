## `VMR` Class <!-- {docsify-ignore-all} -->


### `__New([p_path])` Constructor
Initilizes the VBVMR class (the actual wrapper) by setting the DLL path and type (64/32) as well as the string encoding which is based on the type of AHK that's running the script (Unicode/ANSI), then loads the correct DLL and its functions addresses.

<sub>*Note: for VMR to work properly, the script needs to be persistent, scripts that have GUIs or hotkeys are implicitly persistent, to make a regular script persistent add `#Persistent` to the top of the script*</sub>

---

### Properties

* #### `bus` and `strip` Arrays
Array of [`bus`/`strip` objects](/VMR-Class/bus-strip-object.md 'Bus/Strip object').
* #### [`recorder`](/VMR-Class/recorder-object.md 'Recorder object')
Use this object to control voicemeeter's recorder.
* #### [`vban`](/VMR-Class/vban-object.md 'VBAN object')
Use this object to control voicemeeter's VBAN interface
* #### [`command`](/VMR-Class/command-object.md 'Command object')
Use this object to access command methods.
* #### [`option`](/VMR-Class/option-object.md 'Option object')
Use this object to access/modify option parameters.
* #### [`macroButton`](/VMR-Class/macrobutton-object.md 'MacroButton object')
Use this object to access/modify macro buttons statuses.

---

### Methods

* #### `login()`
Calls voicemeeter's login function and initilizes VMR class properties (objects and arrays).
This method needs to be called first, in order to use the VMR class.
* #### `getType()`
Returns voicemeeter's type. (1 -> voicemeeter, 2 -> banana, 3 -> potato).
* #### `runVoicemeeter([type])`
Runs the highest version installed , or a specific version if `type` is passed.
* #### `updateDevices()`
Updates the internal array of input and output devices, that's used for setting bus/strips devices
* #### `exec(script)`
Executes a string of voicemeeter commands, see [`script_example.ahk`](https://github.com/SaifAqqad/VMR.ahk/blob/master/examples/script_example.ahk)
* #### `getBusDevices()`/`getStripDevices()`
Returns an array of input/output devices, each device is an object with `name` and `driver` properties

---

### Callback functions
Set callback functions for certain events (e.g. to update a user interface)

* #### `onUpdateLevels`
called whenever the [`level`](/VMR-Class/bus-strip-object?id=level-array) array for bus/strip objects is updated.
* #### `onUpdateParameters`
called whenever voicemeeter's parameters change on the UI or by another app.
* #### `onUpdateMacrobuttons` 
called whenever a macrobutton's state is changed.
* #### `onMidiMessage`
called whenever voicemeeter receives a MIDI message
    
```autohotkey
    ; Set a function object
    voicemeeter.onUpdateLevels := Func("syncLevels")
```

- See [ui_example.ahk](https://github.com/SaifAqqad/VMR.ahk/blob/master/examples/ui_example.ahk)
- See [midi_message_example.ahk](https://github.com/SaifAqqad/VMR.ahk/blob/master/examples/midi_message_example.ahk)
- [More info on function objects (AHK docs)](https://www.autohotkey.com/docs/objects/Func.htm)
