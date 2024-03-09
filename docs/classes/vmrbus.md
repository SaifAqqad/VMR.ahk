# `VMRBus`  <!-- {docsify-ignore-all} -->

  A wrapper class for voicemeeter buses.

#### Extends: [`VMRAudioIO`](/classes/vmraudioio)
## Constructor `__New(p_index, p_vmrType)` :id=constructor
  Creates a new VMRBus object.

  **Parameters**:
  - `p_index` : `Number` - The zero-based index of the bus.

  - `p_vmrType` : `Number` - The type of the running voicemeeter.


## Properties
* #### **Static** `Devices` : `Array` :id=static-devices
  An array of bus (output) devices
* #### `Name` : `String` :id=name
  The bus's name (as shown in voicemeeter's UI)

## Methods
* ### `GetDevice(p_name, p_driver := unset)` :id=static-getdevice
  Retrieves a bus (output) device by its name/driver.
  
  
  **See also**:
  `VMRConsts.DEVICE_DRIVERS` for a list of valid drivers.

  **Parameters**:
  - `p_name` : `String` - The name of the device.

  - **Optional** `p_driver` : `String` - The driver of the device, If omitted, `VMRConsts.DEFAULT_DEVICE_DRIVER` will be used.

  **Returns**: [`VMRDevice`](/classes/vmrdevice) - A device object, or an empty string `""` if the device was not found.