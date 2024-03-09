# `VMRMacroButton`  <!-- {docsify-ignore-all} -->



## Methods
* ### `Run()` :id=run
  Runs the Voicemeeter Macro Buttons application.


______
* ### `Show(p_show := true)` :id=show
  Shows/Hides the Voicemeeter Macro Buttons application.

  **Parameters**:
  - **Optional** `p_show` : `Boolean` - Whether to show or hide the application



______
* ### `SetStatus(p_index, p_value, p_bitMode := 0)` :id=setstatus
  Sets the status of a given button.

  **Parameters**:
  - `p_index` : `Number` - The one-based index of the button

  - `p_value` : `Number` - The value to set
    - `0`: Off
    - `1`: On

  - **Optional** `p_bitMode` : `Number` - The type of the returned value
    - `0`: button-state
    - `2`: displayed-state
    - `3`: trigger-state

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs

  **Returns**: `Number` - The status of the button
    - `0`: Off
    - `1`: On


______
* ### `GetStatus(p_index, p_bitMode := 0)` :id=getstatus
  Gets the status of a given button.

  **Parameters**:
  - `p_index` : `Number` - The one-based index of the button

  - **Optional** `p_bitMode` : `Number` - The type of the returned value
    - `0`: button-state
    - `2`: displayed-state
    - `3`: trigger-state

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If an internal error occurs

  **Returns**: `Number` - The status of the button
    - `0`: Off
    - `1`: On