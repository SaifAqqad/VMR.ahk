# `VMRAudioIO`  <!-- {docsify-ignore-all} -->

  A base class for [`VMRBus`](/classes/vmrbus) and [`VMRStrip`](/classes/vmrstrip)
## Constructor `__New(p_index, p_ioType)` :id=constructor
  Creates a new `VMRAudioIO` object.

  **Parameters**:
  - `p_index` : `Number` - The zero-based index of the bus/strip.

  - `p_ioType` : `String` - The type of the object. (`Bus` or `Strip`)


## Properties
* #### `GainPercentage` : `Number` :id=gainpercentage
  Gets/Sets the gain as a percentage
* #### `Device` : [`VMRDevice`](/classes/vmrdevice) :id=device
  Gets/Sets the object's current device
* #### `GainLimit` : `Number` :id=gainlimit
  The object's upper gain limit
* #### `Level` : `Array` :id=level
  An array of the object's channel levels
* #### `Id` : `String` :id=id
  The object's identifier that's used when calling VMR's functions.    
  ex: `Bus[0]` or `Strip[3]`
* #### `Index` : `Number` :id=index
  The object's one-based index
* #### `Type` : `String` :id=type
  The object's type (`Bus` or `Strip`)

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


______
* ### `Increment(p_param, p_amount)` :id=increment
  Increments a parameter by a specific amount.  
  - It's recommended to use this method instead of incrementing the parameter directly (`++vm.Bus[1].Gain`).
  - Since this method doesn't fetch the current value of the parameter to update it, [`GainLimit`](/classes/vmraudioio?id=gainlimit) cannot be applied here.

  **Parameters**:
  - `p_param` : `String` - The name of the parameter, must be a numeric parameter.

  - `p_amount` : `Number` - The amount to increment the parameter by, can be set to a negative value to decrement instead.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If invalid parameters are passed or if an internal error occurs.

  **Returns**: [`VMRAsyncOp`](/classes/vmrasyncop) - An async operation that resolves with the incremented value.


______
* ### `FadeTo(p_db, p_duration)` :id=fadeto
  Sets the gain to a specific value with a progressive fade.

  **Parameters**:
  - `p_db` : `Number` - The gain value in dBs.

  - `p_duration` : `Number` - The duration of the fade in milliseconds.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If invalid parameters are passed or if an internal error occurs.

  **Returns**: [`VMRAsyncOp`](/classes/vmrasyncop) - An async operation that resolves with the final gain value.


______
* ### `FadeBy(p_dbAmount, p_duration)` :id=fadeby
  Fades the gain by a specific amount.

  **Parameters**:
  - `p_dbAmount` : `Number` - The amount to fade the gain by in dBs.

  - `p_duration` : `Number` - The duration of the fade in milliseconds.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - If invalid parameters are passed or if an internal error occurs.

  **Returns**: [`VMRAsyncOp`](/classes/vmrasyncop) - An async operation that resolves with the final gain value.


______
* ### `IsPhysical()` :id=isphysical
  Returns `true` if the bus/strip is a physical (hardware) one.

  **Returns**: `Boolean`