# `VBVMR`  <!-- {docsify-ignore-all} -->

  A static wrapper class for the Voicemeeter Remote DLL.

?> The class must be initialized by calling [`Init()`](/classes/vbvmr?id=static-init) before using any of its static methods.

## Properties
* #### **Static** `DLL` : `Ptr` :id=static-dll
    The handle to the loaded Voicemeeter DLL
* #### **Static** `DLL_PATH` : `String` :id=static-dll-path
    The path to the loaded Voicemeeter DLL


## Methods
* ### `Init(p_path := "")` :id=static-init
  Initializes the VBVMR class by loading the Voicemeeter Remote DLL and getting the addresses of all needed functions.
  If the DLL is already loaded, it returns immediately.

  **Parameters**:
  - **Optional** `p_path` : `String` - The path to the Voicemeeter Remote DLL. If not specified, it will be looked up in the registry.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the DLL is not found in the specified path or if voicemeeter is not installed.



______
* ### `Login()` :id=static-login
  Opens a Communication Pipe With Voicemeeter.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - `0` : OK (no error).
    - `1` : OK but Voicemeeter is not launched (need to launch it manually).


______
* ### `Logout()` :id=static-logout
  Closes the Communication Pipe With Voicemeeter.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - `0` : OK (no error).


______
* ### `SetParameterFloat(p_prefix, p_parameter, p_value)` :id=static-setparameterfloat
  Sets the value of a float (numeric) parameter.

  **Parameters**:
  - `p_prefix` : `String` - The prefix of the parameter, usually the name of the bus/strip (ex: `Bus[0]`).

  - `p_parameter` : `String` - The name of the parameter (ex: `gain`).

  - `p_value` : `Number` - The value to set.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the parameter is not found, or an internal error occurs.

  **Returns**: `Number` - `0` : OK (no error).


______
* ### `SetParameterString(p_prefix, p_parameter, p_value)` :id=static-setparameterstring
  Sets the value of a string parameter.

  **Parameters**:
  - `p_prefix` : `String` - The prefix of the parameter, usually the name of the bus/strip (ex: `Strip[1]`).

  - `p_parameter` : `String` - The name of the parameter (ex: `name`).

  - `p_value` : `String` - The value to set.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the parameter is not found, or an internal error occurs.

  **Returns**: `Number` - `0` : OK (no error).


______
* ### `GetParameterFloat(p_prefix, p_parameter)` :id=static-getparameterfloat
  Returns the value of a float (numeric) parameter.

  **Parameters**:
  - `p_prefix` : `String` - The prefix of the parameter, usually the name of the bus/strip (ex: `Bus[2]`).

  - `p_parameter` : `String` - The name of the parameter (ex: `gain`).

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the parameter is not found, or an internal error occurs.

  **Returns**: `Number` - The value of the parameter.


______
* ### `GetParameterString(p_prefix, p_parameter)` :id=static-getparameterstring
  Returns the value of a string parameter.

  **Parameters**:
  - `p_prefix` : `String` - The prefix of the parameter, usually the name of the bus/strip (ex: `Strip[1]`).

  - `p_parameter` : `String` - The name of the parameter (ex: `name`).

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the parameter is not found, or an internal error occurs.

  **Returns**: `String` - The value of the parameter.


______
* ### `GetLevel(p_type, p_channel)` :id=static-getlevel
  Returns the level of a single bus/strip channel.

  **Parameters**:
  - `p_type` : `Number` - The type of the returned level 
    - `0`: pre-fader
    - `1`: post-fader
    - `2`: post-mute
    - `3`: output-levels

  - `p_channel` : `Number` - The channel's zero-based index.
    - Channel Indices depend on the type of voiceemeeter running.
    - Channel Indices are incremented from the left to right (On the Voicemeeter UI), starting at `0`, Buses and Strips have separate Indices (see `p_type`).
    - Physical (hardware) strips have 2 channels (left, right), Buses and virtual strips have 8 channels.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the channel index is invalid, or an internal error occurs.

  **Returns**: `Number` - The level of the requested channel.


______
* ### `GetVoicemeeterType()` :id=static-getvoicemeetertype
  Returns the type of Voicemeeter running.
  
  
  **See also**:
  [`VMR.Types`](/classes/vmr?id=static-types) for possible values.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - The type of Voicemeeter running.


______
* ### `GetVoicemeeterVersion()` :id=static-getvoicemeeterversion
  Returns the version of Voicemeeter running.
  - The version is returned as a 4-part string (v1.v2.v3.v4)

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `String` - The version of Voicemeeter running.


______
* ### `Output_GetDeviceNumber()` :id=static-output_getdevicenumber
  Returns the number of Output Devices available on the system.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - The number of output devices.


______
* ### `Output_GetDeviceDesc(p_index)` :id=static-output_getdevicedesc
  Returns the Descriptor of an output device.

  **Parameters**:
  - `p_index` : `Number` - The index of the device (zero-based).

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: [`VMRDevice`](/classes/vmrdevice) - An object containing the `Name`, `Driver` and `Hwid` of the device.


______
* ### `Input_GetDeviceNumber()` :id=static-input_getdevicenumber
  Returns the number of Input Devices available on the system.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - The number of input devices.


______
* ### `Input_GetDeviceDesc(p_index)` :id=static-input_getdevicedesc
  Returns the Descriptor of an input device.

  **Parameters**:
  - `p_index` : `Number` - The index of the device (zero-based).

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: [`VMRDevice`](/classes/vmrdevice) - An object containing the `Name`, `Driver` and `Hwid` of the device.


______
* ### `IsParametersDirty()` :id=static-isparametersdirty
  Checks if any parameters have changed.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - `0` : No change
    - `1` : Some parameters have changed


______
* ### `MacroButton_GetStatus(p_logicalButton, p_bitMode)` :id=static-macrobutton_getstatus
  Returns the current status of a given button.

  **Parameters**:
  - `p_logicalButton` : `Number` - The index of the button (zero-based).

  - `p_bitMode` : `Number` - The type of the returned value.
    - `0`: button-state
    - `2`: displayed-state
    - `3`: trigger-state

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - The status of the button
    - `0`: Off
    - `1`: On


______
* ### `MacroButton_SetStatus(p_logicalButton, p_value, p_bitMode)` :id=static-macrobutton_setstatus
  Sets the status of a given button.

  **Parameters**:
  - `p_logicalButton` : `Number` - The index of the button (zero-based).

  - `p_value` : `Number` - The value to set.
    - `0`: Off
    - `1`: On

  - `p_bitMode` : `Number` - The type of the returned value.
    - `0`: button-state
    - `2`: displayed-state
    - `3`: trigger-state

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - The status of the button
    - `0`: Off
    - `1`: On


______
* ### `MacroButton_IsDirty()` :id=static-macrobutton_isdirty
  Checks if any Macro Buttons states have changed.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - `0` : No change 
     - `> 0` : Some buttons have changed


______
* ### `GetMidiMessage()` :id=static-getmidimessage
  Returns any available MIDI messages from Voicemeeter's MIDI mapping.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Array` - `[0xF0, 0xFF, ...]` An array of hex-formatted bytes that compose one or more MIDI messages, or an empty string `""` if no messages are available.
    - A single message is usually 2 or 3 bytes long
    - The returned array will contain at most `1024` bytes.


______
* ### `SetParameters(p_script)` :id=static-setparameters
  Sets one or more parameters using a voicemeeter script.

  **Parameters**:
  - `p_script` : `String` - The script to execute (must be less than `48kb`).
    - Scripts can contain one or more parameter changes
    - Changes can be seperated by a new line, `;` or `,`.
    - Indices inside the script are zero-based.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: `Number` - `0` : OK (no error) 
     - `> 0` : Number of the line causing an error

## Notes
While this class can be used to directly call the Voicemeeter Remote DLL functions, it's recommended to use the `VMR` class instead of this one, as it simplifies usage of the API.