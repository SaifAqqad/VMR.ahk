# `VMR.Types`  <!-- {docsify-ignore-all} -->

## Properties
* #### **Static** `Count` : `Number` :id=count
    The number of available Voicemeeter types.
* #### **Static** `Standard` : `VMR.Types` :id=standard
* #### **Static** `Banana` : `VMR.Types` :id=banana
* #### **Static** `Potato` : `VMR.Types` :id=potato
* #### `Id` : `Number` :id=id
* #### `Name` : `String` :id=name
* #### `Executable` : `String` :id=executable
* #### `BusCount` : `Number` :id=buscount
* #### `StripCount` : `Number` :id=stripcount
* #### `VbanCount` : `Number` :id=vbancount

## Methods

* ### `GetType(p_id)` :id=gettype
    Returns the Voicemeeter type with the specified ID.

  **Parameters**:
  - `p_id` : `Number` - The ID of the Voicemeeter type to retrieve.
    
  **Returns**: [`VMR.Types`](/classes/vmr.types) - The Voicemeeter type, or an empty string `""` if `p_id` is invalid.
