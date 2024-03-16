# `VMR`  <!-- {docsify-ignore-all} -->

  A wrapper class for Voicemeeter Remote that hides the low-level API to simplify usage.  
  Must be initialized by calling [`Login()`](/classes/vmr?id=login) after creating the VMR instance.
## Constructor `__New(p_path := "")` :id=constructor
  Creates a new VMR instance and initializes the [`VBVMR`](/classes/vbvmr) class.

  **Parameters**:
  - **Optional** `p_path` : `String` - The path to the Voicemeeter Remote DLL. If not specified, [`VBVMR`](/classes/vbvmr) will attempt to find it in the registry.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the DLL is not found in the specified path or if voicemeeter is not installed.


## Properties
* #### `Type` : `VMR.Types` :id=type
  The type of Voicemeeter that is currently running.
  
  **See also**:
  [`VMR.Types`](/classes/vmrtypes) for a list of available types.
* #### `Version` : `String` :id=version
  The version of Voicemeeter that is currently running.
  The AHK function [`VerCompare`](https://www.autohotkey.com/docs/v2/lib/VerCompare.htm) can be used to compare version strings.
* #### `Bus` : `Array` :id=bus
  An array of voicemeeter buses
* #### `Strip` : `Array` :id=strip
  An array of voicemeeter strips
* #### `Command` : [`VMRCommands`](/classes/vmrcommands) :id=command
  Commands that control various aspects of Voicemeeter
  
  **See also**:
  [`VMRCommands`](/classes/vmrcommands) for a list of available commands.
* #### `Fx` : [`VMRControllerBase`](/classes/vmrcontrollerbase) :id=fx
  Controls Voicemeeter Potato's FX settings

  ?> This property is only available when running Voicemeeter Potato (`vm.Type == VMR.Types.Potato`).
* #### `Patch` : [`VMRControllerBase`](/classes/vmrcontrollerbase) :id=patch
  Controls Voicemeeter's Patch parameters
* #### `Option` : [`VMRControllerBase`](/classes/vmrcontrollerbase) :id=option
  Controls Voicemeeter's System Settings
* #### `MacroButton` : [`VMRMacroButton`](/classes/vmrmacrobutton) :id=macrobutton
  Controls Voicemeeter's Macro Buttons app
* #### `Recorder` : [`VMRRecorder`](/classes/vmrrecorder) :id=recorder
  Controls Voicemeeter's Recorder

  ?> This property is only available when running Voicemeeter Banana or Potato (`vm.Type == VMR.Types.Banana || VMR.Type == VMR.Types.Potato`).

## Methods
* ### `Login(p_launchVoicemeeter := true)` :id=login
  Initializes the VMR instance and opens the communication pipe with Voicemeeter.

  **Parameters**:
  - **Optional** `p_launchVoicemeeter` : `Boolean` - Whether to launch Voicemeeter if it's not already running. Defaults to `true`.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

  **Returns**: [`VMR`](/classes/vmr) - The `VMR` instance.


______
* ### `RunVoicemeeter(p_type := unset)` :id=runvoicemeeter
  Attempts to run Voicemeeter.
  When passing a `p_type`, it will only attempt to run the specified Voicemeeter type,
  otherwise it will attempt to run every voicemeeter type descendingly until one is successfully launched.

  **Parameters**:
  - **Optional** `p_type` : `Number` - The type of Voicemeeter to run.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the specified Voicemeeter type is invalid, or if no Voicemeeter type could be launched.

  **Returns**: `Number` - The PID of the launched Voicemeeter process.


______
* ### `On(p_event, p_listener)` :id=on
  Registers a callback function to be called when the specified event is fired.
  
  
  **See also**:
  `VMRConsts.Events` for a list of available events.

  **Parameters**:
  - `p_event` : `String` - The name of the event to listen for.

  - `p_listener` : `Func` - The function to call when the event is fired.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the specified event is invalid, or if the listener is not a valid `Func` object.



______
* ### `Off(p_event, p_listener := unset)` :id=off
  Removes a callback function from the specified event.
  
  
  **See also**:
  `VMRConsts.Events` for a list of available events.

  **Parameters**:
  - `p_event` : `String` - The name of the event.

  - **Optional** `p_listener` : `Func` - The function to remove, if omitted, all listeners for the specified event will be removed.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If the specified event is invalid, or if the listener is not a valid `Func` object.

  **Returns**: `Boolean` - Whether the listener was removed.


______
* ### `Sync()` :id=sync
  Synchronizes the VMR instance with Voicemeeter.

  **Returns**: `Boolean` - Whether voicemeeter state has changed since the last sync.


______
* ### `Exec(p_script)` :id=exec
  Executes a Voicemeeter script (**not** an AutoHotkey script).
  - Scripts can contain one or more parameter changes
  - Changes can be seperated by a new line, `;` or `,`.
  - Indices in the script are zero-based.

  **Parameters**:
  - `p_script` : `String` - The script to execute.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an error occurs while executing the script.


______
* ### `UpdateDevices(p_wParam := unset, *)` :id=updatedevices
  Updates the list of strip/bus devices.

  **Parameters**:
  - **Optional** `p_wParam` : `Number` - If passed, must be equal to `VMRConsts.WM_DEVICE_CHANGE_PARAM` to update the device arrays.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs.

