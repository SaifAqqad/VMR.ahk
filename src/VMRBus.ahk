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
     * Set/Get the bus's EQ parameters.
     * 
     * @param {Number} p_channel - The one-based index of the channel.
     * @param {Number} p_cell - The one-based index of the cell.
     * @param {String} p_type - The EQ parameter to get/set.
     * 
     * @example
     * vm.Bus[1].EQ[1, 1, "gain"] := -6
     * vm.Bus[1].EQ[1, 1, "q"] := 90
     * __________
     * @returns {Number} - The EQ parameter's value.
     */
    EQ[p_channel, p_cell, p_param] {
        get => this.GetParameter("EQ.channel[" p_channel - 1 "].cell[" p_cell - 1 "]." p_param)
        set => this.SetParameter("EQ.channel[" p_channel - 1 "].cell[" p_cell - 1 "]." p_param, Value)
    }

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
}
