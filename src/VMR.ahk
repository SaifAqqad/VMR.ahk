#Requires AutoHotkey >=2.0
#Include VMRError.ahk
#Include VBVMR.ahk
#Include VMRDevice.ahk
#Include VMRBus.ahk
#Include VMRStrip.ahk

class VMR {
    static VOICEMEETER_TYPES := ["Voicemeeter", "Voicemeeter Banana", "Voicemeeter Potato"]

    __New(p_path := "") {
        VBVMR.Init(p_path)
    }

    GetVoicemeeterType() {
        local vType := VBVMR.GetVoicemeeterType()
        return { type: vType, name: VMR.VOICEMEETER_TYPES[vType] }
    }

    ; TODO: Login, obj/arr init, auto update devices, sync timers

    /**
     * #### Retrieves a strip device (input device) by its name/driver.
     * 
     * @param {String} p_name - The name of the device, or any substring of it.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, `p_name` must be the full name of the device.
     * 
     * _____
     * @returns {{name, driver}} The device object, or an empty string if no device was found.
     */
    GetStripDevice(p_name, p_driver?) => VMRDevice._GetDevice(VMRStrip.DEVICES, p_name, p_driver)

    /**
     * #### Retrieves all strip devices (input devices).
     * 
     * _____
     * @returns {Array} An array of device objects `{name, driver}`.
     */
    GetStripDevices() => VMRStrip.DEVICES

    /**
     * #### Retrieves a bus device (output device) by its name/driver.
     * 
     * @param {String} p_name - The name of the device, or any substring of it.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, `p_name` must be the full name of the device.
     * 
     * _____
     * @returns {{name, driver}} The device object, or an empty string if no device was found.
     */
    GetBusDevice(p_name, p_driver?) => VMRDevice._GetDevice(VMRBus.DEVICES, p_name, p_driver)

    /**
     * #### Retrieves all bus devices (output devices).
     * 
     * _____
     * @returns {Array} An array of device objects `{name, driver}`.
     */
    GetBusDevices() => VMRBus.DEVICES
}