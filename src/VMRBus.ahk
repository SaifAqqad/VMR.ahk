#Requires AutoHotkey >=2.0
#Include VBVMR.ahk
#Include VMRError.ahk

/**
 * A wrapper around a voicemeeter bus.
 */
class VMRBus {
    static LEVELS_COUNT := 0
    static DEVICES := Array()
    static IS_CLASS_INIT := false
    static BUS_NAMES := [
        ["A", "B"],
        ["A1", "A2", "A3", "B1", "B2"],
        ["A1", "A2", "A3", "A4", "A5", "B1", "B2", "B3"]
    ]

    /**
     * #### Creates a new VMRBus object.
     * 
     * @param {Number} p_index - The zero-based index of the bus.
     * @param {Number} p_vmrType - The type of the running voicemeeter.
     */
    __New(p_index, p_vmrType) {
        this.channel_count := 8
        this.gain_limit := 12.0
        this.index := p_index
        this.id := "Bus[" . p_index . "]"
        this.name := VMRBus.BUS_NAMES[p_vmrType][p_index + 1]

        switch p_vmrType {
            case 1:
                this.is_physical := true
            case 2:
                this.is_physical := this.index < 3
            case 3:
                this.is_physical := this.index < 5
        }

        ; Setup the bus's levels array
        this.level := Array()
        this.level.Length := this.channel_count

        ; A bus's level indices start at the current total count
        this.level_index := VMRBus.LEVELS_COUNT
        VMRBus.LEVELS_COUNT += this.channel_count
    }

    ; TODO: Implement __Get __Set methods, and __Item property
}