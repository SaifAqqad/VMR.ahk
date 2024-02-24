## `VBVMR` <!-- {docsify-ignore-all} -->

A static wrapper class for the Voicemeeter Remote DLL.

?> The class must be initialized by calling [`Init()`](#static-init) before using any of its static methods.

## Properties

* **Static** `DLL` : `Ptr`      
    The handle to the loaded Voicemeeter DLL
* **Static** `DLL_PATH` : `String`      
    The path to the loaded Voicemeeter DLL

## Methods

* ### **Static** `Init([p_path := ""])` :id=static-init
  Initializes the VBVMR class by loading the Voicemeeter Remote DLL and getting the addresses of all needed functions. If the DLL is already loaded, it returns immediately.

  **Parameters:**
    - **Optional** `p_path` : `String` - The path to the Voicemeeter Remote DLL. If not specified, it will be looked up in the registry.

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If the DLL is not found in the specified path or if Voicemeeter is not installed.

  **Returns:** `N/A`

______
* ### **Static** `Login()` :id=static-login
  Opens a communication pipe with Voicemeeter.

  **Returns:** `Number`
    - `0` : OK (no error).
    - `1` : OK but Voicemeeter is not launched (need to launch it manually).

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `Logout()` :id=static-logout
  Closes the communication pipe with Voicemeeter.

  **Returns:** `Number`
    - `0` : OK (no error).

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `SetParameterFloat(p_prefix, p_parameter, p_value)` :id=static-setparameterfloat
  Sets the value of a float (numeric) parameter.

  **Parameters:**
    - `p_prefix` : `String` - The prefix of the parameter, usually the name of the bus/strip (ex: `Bus[0]`).
    - `p_parameter` : `String` - The name of the parameter (ex: `gain`).
    - `p_value` : `Number` - The value to set.

  **Returns:** `Number`
    - `0` : OK (no error).

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If the parameter is not found, or an internal error occurs.

______
* ### **Static** `SetParameterString(p_prefix, p_parameter, p_value)` :id=static-setparameterstring
  Sets the value of a string parameter.

  **Parameters:**
    - `p_prefix` : `String` - The prefix of the parameter, usually the name of the bus/strip (ex: `Strip[1]`).
    - `p_parameter` : `String` - The name of the parameter (ex: `name`).
    - `p_value` : `String` - The value to set.

  **Returns:** `Number`
    - `0` : OK (no error).

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If the parameter is not found, or an internal error occurs.

______
* ### **Static** `GetParameterFloat(p_prefix, p_parameter)` :id=static-getparameterfloat
  Returns the value of a float (numeric) parameter.

  **Parameters:**
    - `p_prefix` : `String` - The prefix of the parameter, usually the name of the bus/strip (ex: `Bus[2]`).
    - `p_parameter` : `String` - The name of the parameter (ex: `gain`).

  **Returns:** `Number` - The value of the parameter.

  **Throws:**
    - [`VMRError`](/classes/vmrerror.md) - If the parameter is not found, or an internal error occurs. 

______
* ### **Static** `GetParameterString(p_prefix, p_parameter)` :id=static-getparameterstring
  Returns the value of a string parameter.

  **Parameters:**
    - `p_prefix` : `String` - The prefix of the parameter, usually the name of the bus/strip (ex: `Strip[1]`).
    - `p_parameter` : `String` - The name of the parameter (ex: `name`).

  **Returns:** `String` - The value of the parameter.

  **Throws:**
    - [`VMRError`](/classes/vmrerror.md) - If the parameter is not found, or an internal error occurs. 

______
* ### **Static** `GetLevel(p_type, p_channel)` :id=static-getlevel
  Returns the level of a single bus/strip channel.

  **Parameters:**
    - `p_type` : `Number` - The type of the returned level:
      - `0`: pre-fader
      - `1`: post-fader
      - `2`: post-mute
      - `3`: output-levels
    - `p_channel` : `Number` - The channel's zero-based index. See the method description for notes on channel indices.

  **Returns:** `Number` - The level of the requested channel.

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If the channel index is invalid, or an internal error occurs. 

______
* ### **Static** `GetVoicemeeterType()` :id=static-getvoicemeetertype
  Returns the type of Voicemeeter running. See [`VMR.Types`](/classes/vmr_types.md) for possible return values. 

  **Returns:** `Number` - The type of Voicemeeter running.

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `GetVoicemeeterVersion()` :id=static-getvoicemeeterversion
   Returns the version of Voicemeeter running as a string (v1.v2.v3.v4)

  **Returns:** `String` - The version of Voicemeeter running.

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `Output_GetDeviceNumber()` :id=static-output-getdevicenumber
  Retrieves the number of output devices available on the system.

  **Returns:** `Number` - The number of output devices.

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `Output_GetDeviceDesc(p_index)` :id=static-output-getdevicedesc
  Returns the descriptor of an output device.

  **Parameters:**
    - `p_index` : `Number` - The zero-based index of the device.

  **Returns:** `VMRDevice` - An object containing the `Name`, `Driver`, and `Hwid` of the device.

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `Input_GetDeviceNumber()` :id=static-input-getdevicenumber
  Retrieves the number of input devices available on the system.

  **Returns:** `Number` - The number of input devices.

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `Input_GetDeviceDesc(p_index)` :id=static-input-getdevicedesc
  Returns the descriptor of an input device.

  **Parameters:**
    - `p_index` : `Number` - The zero-based index of the device.

  **Returns:** `VMRDevice` - An object containing the `Name`, `Driver`, and `Hwid` of the device.

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `IsParametersDirty()` :id=static-isparametersdirty
  Checks if any parameters have changed.

  **Returns:** `Number`
    - `0` : No change
    - `1` : Some parameters have changed

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `MacroButton_GetStatus(p_logicalButton, p_bitMode)` :id=static-macrobutton-getstatus
  Returns the current state of a given macro button.

  **Parameters:**
    - `p_logicalButton` : `Number` - The index of the button (zero-based).
    - `p_bitMode` : `Number` - The type of the returned value.
       - `0`: button-state
       - `2`: displayed-state
       - `3`: trigger-state

  **Returns:** `Number` - The status of the button
    - `0`: Off
    - `1`: On

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `MacroButton_SetStatus(p_logicalButton, p_value, p_bitMode)` :id=static-macrobutton-setstatus
  Sets the status of a given macro button.

  **Parameters:**
    - `p_logicalButton` : `Number` - The index of the button (zero-based).
    - `p_value` : `Number` - The value to set (0 = Off, 1 = On)
    - `p_bitMode` : `Number` - The type of value to set.
       - `0`: button-state
       - `2`: displayed-state
       - `3`: trigger-state

  **Returns:** `Number` - The new status of the button
    - `0`: Off
    - `1`: On

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `MacroButton_IsDirty()` :id=static-macrobutton-isdirty
  Checks if any macro button states have changed.

  **Returns:** `Number` 
    - `0` : No change 
    - `> 0` : Some buttons have changed

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `GetMidiMessage()` :id=static-getmidimessage
  Returns available MIDI messages from Voicemeeter's MIDI mapping.

  **Returns:** 
   - `Array` - `[0xF0, 0xFF, ...]` An array of hex-formatted bytes representing MIDI messages, or an empty string `""` if no messages are available.

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

______
* ### **Static** `SetParameters(p_script)` :id=static-setparameters
  Sets one or more parameters using a Voicemeeter script.

  **Parameters:**
    - `p_script` : `String` - The script to execute (must be less than 48kb). See the method description for notes on script formats.

  **Returns:** `Number`
     - `0` : OK (no error)
     - `> 0` : Number of the line causing an error

  **Throws:** 
    - [`VMRError`](/classes/vmrerror.md) - If an internal error occurs.

## Notes
While this class can be used to directly call the Voicemeeter Remote DLL functions, it's recommended to use the `VMR` class instead of this one, as it simplifies usage of the API.