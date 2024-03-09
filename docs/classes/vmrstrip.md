# `VMRStrip`  <!-- {docsify-ignore-all} -->

  A wrapper class for voicemeeter strips.

#### Extends: [`VMRAudioIO`](/classes/vmraudioio)
## Constructor `__New(p_index, p_vmrType)` :id=constructor
  Creates a new VMRStrip object.

  **Parameters**:
  - `p_index` : `Number` - The zero-based index of the strip.

  - `p_vmrType` : `Number` - The type of the running voicemeeter.


## Properties
* #### **Static** `Devices` : `Array` :id=static-devices
  An array of strip (input) devices
* #### `AppGain` : `Number` :id=appgain
  Sets an application's gain on the strip.
* #### `AppMute` : `Boolean` :id=appmute
  Sets an application's mute state on the strip.
* #### `Name` : `String` :id=name
  The strip's name (as shown in voicemeeter's UI)

## Methods
* ### `GetDevice(p_name, p_driver := unset)` :id=static-getdevice
  Retrieves a strip (input) device by its name/driver.
  
  
  **See also**:
  `VMRConsts.DEVICE_DRIVERS` for a list of valid drivers.

  **Parameters**:
  - `p_name` : `String` - The name of the device.

  - **Optional** `p_driver` : `String` - The driver of the device, If omitted, `VMRConsts.DEFAULT_DEVICE_DRIVER` will be used.

  **Returns**: [`VMRDevice`](/classes/vmrdevice) - A device object, or an empty string `""` if the device was not found.