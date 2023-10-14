#Requires AutoHotkey >=2.0
#Include VBVMR.ahk
#Include VMRError.ahk
#Include VMRDevice.ahk

/**
 * A wrapper around a voicemeeter bus.
 */
class VMRBus extends VMRDevice {
    static LEVELS_COUNT := 0
    static DEVICES := Array()
    static BUS_NAMES := [
        ["A", "B"],
        ["A1", "A2", "A3", "B1", "B2"],
        ["A1", "A2", "A3", "A4", "A5", "B1", "B2", "B3"]
    ]

    /**
     * #### Retrieves a device object by its name/driver.
     * 
     * @param {String} p_name - The name of the device, or any substring of it.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, `p_name` must be the full name of the device.
     * 
     * _____
     * @returns {{name, driver}} The device object, or an empty string if no device was found.
     */
    static GetDevice(p_name, p_driver?) => VMRDevice._GetDevice(VMRBus.DEVICES, p_name, p_driver)

    /**
     * #### Creates a new VMRBus object.
     * 
     * @param {Number} p_index - The zero-based index of the bus.
     * @param {Number} p_vmrType - The type of the running voicemeeter.
     */
    __New(p_index, p_vmrType) {
        super.__New(p_index, "Bus")
        this.channel_count := 8
        this.name := VMRBus.BUS_NAMES[p_vmrType][p_index + 1]

        switch p_vmrType {
            case 1:
                super.is_physical := true
            case 2:
                super.is_physical := this.index < 3
            case 3:
                super.is_physical := this.index < 5
        }

        ; Setup the bus's levels array
        this.level := Array()
        this.level.Length := this.channel_count

        ; A bus's level indices start at the current total count
        this.level_index := VMRBus.LEVELS_COUNT
        VMRBus.LEVELS_COUNT += this.channel_count
    }

    /**
     * #### Set/Get the bus's upper gain limit. setting the gain above the limit will reset it to this value.
     */
    GainLimit {
        get {
            return super.gain_limit
        }
        set {
            return super.gain_limit := Value
        }
    }

    _UpdateLevels() {
        loop this.channel_count {
            vmrIndex := this.level_index + A_Index - 1
            local levelValue := Number(VBVMR.GetLevel(3, vmrIndex))
            this.level[A_Index] := levelValue
        }
    }
}