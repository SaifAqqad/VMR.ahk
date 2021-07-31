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
* #### `state(buttonIndex, [state])`
Changes the actual state of a macro button. If `state` is not passed, the current state for the button is returned
```autohotkey
    voicemeeter.command.state(1,-1) ; passing -1 will toggle it
    button_state := voicemeeter.command.state(3)
```
* #### `stateOnly(buttonIndex, [state])`
Changes the visual state of a macro button, If `state` is not passed, the current visual state for the button is returned
```autohotkey
    voicemeeter.command.stateOnly(2,0)
    ; releases the key visually but does not run the code programmed into the macrobutton.
```
* #### `trigger(buttonIndex, [state])`
Changes a button's trigger state, If `state` is not passed, the current state for the button's trigger is returned
```autohotkey
    voicemeeter.command.trigger(3,-1) ; passing -1 will toggle it
```