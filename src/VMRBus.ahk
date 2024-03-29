#Requires AutoHotkey >=2.0
#Include VBVMR.ahk
#Include VMRAudioIO.ahk
#Include VMRConsts.ahk
#Include VMRUtils.ahk

/**
 * A wrapper class for voicemeeter buses.
 * @extends {VMRAudioIO}
 */
class VMRBus extends VMRAudioIO {
    static LEVELS_COUNT := 0

    /**
     * An array of bus (output) devices
     * @type {Array} - An array of {@link VMRDevice} objects.
     */
    static Devices := Array()

    /**
     * The bus's name (as shown in voicemeeter's UI)
     * 
     * @type {String}
     * 
     * @example
     * local busName := VMRBus.Bus[1].Name ; "A1" or "A" depending on voicemeeter's type
     */
    Name := ""

    /**
     * Creates a new VMRBus object.
     * @param {Number} p_index - The zero-based index of the bus.
     * @param {Number} p_vmrType - The type of the running voicemeeter.
     */
    __New(p_index, p_vmrType) {
        super.__New(p_index, "Bus")
        this._channelCount := 8
        this.Name := VMRConsts.BUS_NAMES[p_vmrType][p_index + 1]

        switch p_vmrType {
            case 1:
                super._isPhysical := true
            case 2:
                super._isPhysical := this._index < 3
            case 3:
                super._isPhysical := this._index < 5
        }

        ; Setup the bus's levels array
        this.Level.Length := this._channelCount

        ; A bus's level index starts at the current total count
        this._levelIndex := VMRBus.LEVELS_COUNT
        VMRBus.LEVELS_COUNT += this._channelCount

        this.DefineProp("__Get", { Call: super._Get })
        this.DefineProp("__Set", { Call: super._Set })
    }

    _UpdateLevels() {
        loop this._channelCount {
            local vmrIndex := this._levelIndex + A_Index - 1
            local level := Round(20 * Log(VBVMR.GetLevel(3, vmrIndex)))
            this.Level[A_Index] := VMRUtils.EnsureBetween(level, -999, 999)
        }
    }

    /**
     * Retrieves a bus (output) device by its name/driver.
     * @param {String} p_name - The name of the device.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, {@link VMRConsts.DEFAULT_DEVICE_DRIVER|`VMRConsts.DEFAULT_DEVICE_DRIVER`} will be used.
     * @see {@link VMRConsts.DEVICE_DRIVERS|`VMRConsts.DEVICE_DRIVERS`} for a list of valid drivers.
     * __________
     * @returns {VMRDevice} - A device object, or an empty string `""` if the device was not found.
     */
    static GetDevice(p_name, p_driver?) => VMRAudioIO._GetDevice(VMRBus.Devices, p_name, p_driver ?? unset)
}
