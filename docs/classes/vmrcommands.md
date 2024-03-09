# `VMRCommands`  <!-- {docsify-ignore-all} -->

  Write-only actions that control voicemeeter

## Properties
* #### `Button` : `Any` :id=button
  Sets a macro button's parameter

## Methods
* ### `Restart()` :id=restart
  Restarts the Audio Engine

  **Returns**: `Boolean` - true if the command was successful


______
* ### `Shutdown()` :id=shutdown
  Shuts down Voicemeeter

  **Returns**: `Boolean` - true if the command was successful


______
* ### `Show(p_open := true)` :id=show
  Shows the Voicemeeter window

  **Parameters**:
  - **Optional** `p_open` : `Boolean` - `true` to show the window, `false` to hide it

  **Returns**: `Boolean` - true if the command was successful


______
* ### `Lock(p_state := true)` :id=lock
  Locks the Voicemeeter UI

  **Parameters**:
  - **Optional** `p_state` : `number` - `true` to lock the UI, `false` to unlock it

  **Returns**: `Boolean` - true if the command was successful


______
* ### `Eject()` :id=eject
  Ejects the recorder's cassette

  **Returns**: `Boolean` - true if the command was successful


______
* ### `Reset()` :id=reset
  Resets all voicemeeeter configuration

  **Returns**: `Boolean` - true if the command was successful


______
* ### `Save(p_filePath)` :id=save
  Saves the current configuration to a file

  **Parameters**:
  - `p_filePath` : `String` - The path to save the configuration to

  **Returns**: `Boolean` - true if the command was successful


______
* ### `Load(p_filePath)` :id=load
  Loads configuration from a file

  **Parameters**:
  - `p_filePath` : `String` - The path to load the configuration from

  **Returns**: `Boolean` - true if the command was successful


______
* ### `ShowVBANChat(p_show := true)` :id=showvbanchat
  Shows the VBAN chat dialog

  **Parameters**:
  - **Optional** `p_show` : `Boolean` - `true` to show the dialog, `false` to hide it

  **Returns**: `Boolean` - true if the command was successful


______
* ### `SaveBusEQ(p_busIndex, p_filePath)` :id=savebuseq
  Saves a bus's EQ settings to a file

  **Parameters**:
  - `p_busIndex` : `Number` - The one-based index of the bus to save

  - `p_filePath` : `String` - The path to save the EQ settings to

  **Returns**: `Boolean` - true if the command was successful


______
* ### `LoadBusEQ(p_busIndex, p_filePath)` :id=loadbuseq
  Loads a bus's EQ settings from a file

  **Parameters**:
  - `p_busIndex` : `Number` - The one-based index of the bus to load

  - `p_filePath` : `String` - The path to load the EQ settings from

  **Returns**: `Boolean` - true if the command was successful


______
* ### `SaveStripEQ(p_stripIndex, p_filePath)` :id=savestripeq
  Saves a strip's EQ settings to a file

  **Parameters**:
  - `p_stripIndex` : `Number` - The one-based index of the strip to save

  - `p_filePath` : `String` - The path to save the EQ settings to

  **Returns**: `Boolean` - true if the command was successful


______
* ### `LoadStripEQ(p_stripIndex, p_filePath)` :id=loadstripeq
  Loads a strip's EQ settings from a file

  **Parameters**:
  - `p_stripIndex` : `Number` - The one-based index of the strip to load

  - `p_filePath` : `String` - The path to load the EQ settings from

  **Returns**: `Boolean` - true if the command was successful


______
* ### `RecallPreset(p_preset)` :id=recallpreset
  Recalls a Preset Scene

  **Parameters**:
  - `p_preset` : `String | Number` - The name of the preset to recall or its one-based index

  **Returns**: `Boolean` - true if the command was successful