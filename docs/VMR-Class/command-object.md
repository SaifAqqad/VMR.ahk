---
layout: default
title: Command
parent: VMR Class
nav_order: 5
---
# `command`

Use this object to access command methods.

---

## Methods

## `restart()`
Restarts VoiceMeeter's audio engine

```lua
    voicemeeter.command.restart()
```

## `shutdown()`
Closes VoiceMeeter completely

```lua
    voicemeeter.command.shutdown()
```

## `show()`
Shows VoiceMeeter's window

```lua
    voicemeeter.command.show()
```

## `eject()`
Ejects the recorder's cassette (releases the audio file)

```lua
    voicemeeter.command.eject()
```

## `reset()`
Resets All configuration

```lua
    voicemeeter.command.reset()
```

## `save([filePath])`
Saves VoiceMeeter's configuration to a file

`filePath` : Name of the file to save the configuration to, if the path is not specified, the file will be saved in the `Documents` folder

```lua
    voicemeeter.command.save("VMconfig.xml")
```

## `load([filePath])`
Loads VoiceMeeter's configuration from a file

`filePath` : Name of the file to load the configuration from, if the path is not specified, the file is assumed to be in the `Documents` folder

```lua
    voicemeeter.command.load("C:\config\voicemeeter.xml")
```

## `showVBANChat([state])`
Shows/hides the VBAN-Chat Dialog

```lua
    voicemeeter.command.showVBANChat(false)
```

## `state(buttonIndex, [state])`
Changes the actual state of a macro button, pass `-1` to the `state` parameter to invert it

If `state` is not passed, the current state for the button is returned
```lua
    voicemeeter.command.state(1,-1)
    button_state:= voicemeeter.command.state(3)
```

## `stateOnly(buttonIndex, [state])`
Changes the visual state of a macro button, pass `-1` to the `state` parameter to invert it

If `state` is not passed, the current visual state for the button is returned
```lua
    voicemeeter.command.stateOnly(2,0)
    ;--> releases the key but does not run the release code programmed into the macrobutton.
```

## `trigger(buttonIndex, [state])`
Changes a button's trigger state, pass `-1` to the `state` parameter to invert it

If `state` is not passed, the current state for the button's trigger is returned
```lua
    voicemeeter.command.trigger(3,-1)
```