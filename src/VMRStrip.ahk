#Requires AutoHotkey >=2.0
#Include VBVMR.ahk
#Include VMRError.ahk
#Include VMRDevice.ahk

/**
 * A wrapper around a voicemeeter strip.
 */
class VMRStrip extends VMRDevice {
    static LEVELS_COUNT := 0
    static DEVICES := Array()
    static STRIP_NAMES := [
        ["Input #1", "Input #2", "Virtual Input #1"],
        ["Input #1", "Input #2", "Input #3", "Virtual Input #1", "Virtual Input #2"],
        ["Input #1", "Input #2", "Input #3", "Input #4", "Input #5", "Virtual Input #1", "Virtual Input #2", "Virtual Input #3"]
    ]

    /**
     * #### Creates a new VMRStrip object.
     * 
     * @param {Number} p_index - The zero-based index of the strip.
     * @param {Number} p_vmrType - The type of the running voicemeeter.
     */
    __New(p_index, p_vmrType) {
        super.__New(p_index, "Strip")
        this.name := VMRStrip.STRIP_NAMES[p_vmrType][p_index + 1]

        switch p_vmrType {
            case 1:
                super.is_physical := this.index < 2
            case 2:
                super.is_physical := this.index < 3
            case 3:
                super.is_physical := this.index < 5
        }

        ; physical strips have 2 channels, virtual strips have 8
        this.channel_count := this.IsPhysical() ? 2 : 8

        ; Setup the strip's levels array
        this.level := Array()
        this.level.Length := this.channel_count

        ; A strip's level indices start at the current total count
        this.level_index := VMRStrip.LEVELS_COUNT
        VMRStrip.LEVELS_COUNT += this.channel_count
    }

    /**
     * #### The strip's upper gain limit
     * Setting the gain above the limit will reset it to this value.
     * @type {Number}
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