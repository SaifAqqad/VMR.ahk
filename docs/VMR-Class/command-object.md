## `command` <!-- {docsify-ignore-all} -->

Use this object to access command methods.

### Methods

* #### `restart()`
Restarts Voicemeeter's audio engine
* #### `shutdown()`
Closes Voicemeeter completely
* #### `show([state])`
Shows/Hides Voicemeeter's window
```autohotkey
    voicemeeter.command.show(false) ; hides the window
```
* #### `lock([state])`
Locks/Unlocks Voicemeeter's window
```autohotkey
    voicemeeter.command.lock(true) ; locks the window
```
* #### `eject()`
Ejects the recorder's cassette (releases the audio file)
* #### `reset()`
Resets All configuration
* #### `save([filePath])`
Saves Voicemeeter's configuration to a file
```autohotkey
    voicemeeter.command.save("VMconfig.xml") ; saves the file in the user's documents folder
```
* #### `load([filePath])`
Loads Voicemeeter's configuration from a file
```autohotkey
    voicemeeter.command.load("C:\config\voicemeeter.xml")
```
* #### `showVBANChat([state])`
Shows/hides the VBAN-Chat Dialog
```autohotkey
    voicemeeter.command.showVBANChat(true)
```
* #### `state(buttonIndex, state)`
Changes the actual state of a macro button. `buttonIndex` is zero-based.
```autohotkey
    voicemeeter.command.state(0,1) ; sets the state of the first macro button to 1
```
* #### `stateOnly(buttonIndex, state)`
Changes the visual state of a macro button.
```autohotkey
    voicemeeter.command.stateOnly(2,0)
    ; releases the key visually but does not run the code programmed into the macrobutton.
```
* #### `trigger(buttonIndex, state)`
Changes a button's trigger state.
```autohotkey
    voicemeeter.command.trigger(3,1)
```
* #### `saveBusEQ(busIndex, filePath)`
Saves the bus EQ settings to a file. `busIndex` is zero-based.
```autohotkey
    voicemeeter.command.saveBusEQ(0,"C:\config\bus0_eq.xml")
```
* #### `loadBusEQ(busIndex, filePath)`
Loads the bus EQ settings from a file.
```autohotkey
    voicemeeter.command.loadBusEQ(2,"C:\config\bus2_eq.xml")
```