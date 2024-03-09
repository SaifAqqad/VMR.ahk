# `VMRUtils`  <!-- {docsify-ignore-all} -->



## Methods
* ### `DbToPercentage(p_dB)` :id=static-dbtopercentage
  Converts a dB value to a percentage value.

  **Parameters**:
  - `p_dB` : `Number` - The dB value to convert.

  **Returns**: `Number` - The percentage value.


______
* ### `PercentageToDb(p_percentage)` :id=static-percentagetodb
  Converts a percentage value to a dB value.

  **Parameters**:
  - `p_percentage` : `Number` - The percentage value to convert.

  **Returns**: `Number` - The dB value.


______
* ### `EnsureBetween(p_value, p_min, p_max)` :id=static-ensurebetween
  Applies an upper and a lower bound on a passed value.

  **Parameters**:
  - `p_value` : `Number` - The value to apply the bounds on.

  - `p_min` : `Number` - The lower bound.

  - `p_max` : `Number` - The upper bound.

  **Returns**: `Number` - The value with the bounds applied.


______
* ### `IndexOf(p_array, p_value)` :id=static-indexof
  Returns the index of the first occurrence of a value in an array, or -1 if it's not found.

  **Parameters**:
  - `p_array` : `Array` - The array to search in.

  - `p_value` : `Any` - The value to search for.

  **Returns**: `Number` - The index of the first occurrence of the value in the array, or -1 if it's not found.


______
* ### `Join(p_params, p_seperator, p_maxLength := 30)` :id=static-join
  Returns a string with the passed parameters joined using the passed seperator.

  **Parameters**:
  - `p_params` : `Array` - The parameters to join.

  - `p_seperator` : `String` - The seperator to use.

  - **Optional** `p_maxLength` : `Number` - The maximum length of each parameter.

  **Returns**: `String` - The joined string.


______
* ### `ToString(p_value)` :id=static-tostring
  Converts a value to a string.

  **Parameters**:
  - `p_value` : `Any` - The value to convert to a string.

  **Returns**: `String` - The string representation of the passed value