# `VMRRecorder`  <!-- {docsify-ignore-all} -->



#### Extends: [`VMRControllerBase`](/classes/vmrcontrollerbase)

## Properties
* #### `ArmBus` : `Boolean` :id=armbus
  Arms the specified bus for recording, switching the recording mode to `1` (bus).
  Or returns the state of the specified bus (whether it's armed or not).
* #### `ArmStrip` : `Boolean` :id=armstrip
  Arms the specified strip for recording, switching the recording mode to `0` (strip).
  Or returns the state of the specified strip (whether it's armed or not).

## Methods
* ### `ArmStrips(p_strips)` :id=armstrips
  Arms the specified strips for recording, switching the recording mode to `0` (strip) and disarming any armed strips.

  **Parameters**:
  - `p_strips` : `Array` - The strips' one-based indices.



______
* ### `Load(p_path)` :id=load
  Loads a file into the recorder.

  **Parameters**:
  - `p_path` : `String`