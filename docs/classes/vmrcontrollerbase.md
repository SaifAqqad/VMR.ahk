# `VMRControllerBase`  <!-- {docsify-ignore-all} -->


## Methods
* ### `SetParameter(p_name, p_value)` :id=setparameter
  Sets the value of a parameter.

  **Parameters**:
  - `p_name` : `String` - The name of the parameter.

  - `p_value` : `Any` - The value of the parameter.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If invalid parameters are passed or if an internal error occurs.

  **Returns**: [`VMRAsyncOp`](/classes/vmrasyncop) - An async operation that resolves to `true` if the parameter was set successfully.


______
* ### `GetParameter(p_name)` :id=getparameter
  Returns the value of a parameter.

  **Parameters**:
  - `p_name` : `String` - The name of the parameter.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If invalid parameters are passed or if an internal error occurs.

  **Returns**: `Any` - The value of the parameter.
