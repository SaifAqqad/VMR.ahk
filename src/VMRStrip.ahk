#Requires AutoHotkey >=2.0

#Include VBVMR.ahk
#Include VMRAudioIO.ahk
#Include VMRConsts.ahk
#Include VMRUtils.ahk

/**
 * A wrapper class for voicemeeter strips.
 * @extends {VMRAudioIO}
 */
class VMRStrip extends VMRAudioIO {
    static LEVELS_COUNT := 0
    static Devices := Array()

    /**
     * The strip's name (as shown in voicemeeter's UI)
     * 
     * @example
     * local stripName := VMRBus.Strip[1].Name ; "Input #1"
     * 
     * @readonly
     * @type {String}
     */
    Name := ""

    /**
     * Sets an application's gain on the strip.
     * 
     * @param {String|Number} p_app - The name of the application, or its one-based index.
     * @type {Number} - The application's gain (`0.0` to `1.0`).
     * __________
     * @throws {VMRError} - If the strip is a physical (hardware) strip or if an internal error occurs.
     */
    AppGain[p_app] {
        set {
            if (this.IsPhysical())
                throw VMRError("Cannot set application gain on physical strips", "AppGain", p_app)

            if (IsNumber(p_app))
                this.SetParameter("App[" p_app - 1 "].Gain", Value)
            else
                this.SetParameter("AppGain", "(" p_app ", " Value ")")
        }
    }

    /**
     * Sets an application's mute state on the strip.
     * 
     * @param {String|Number} p_app - The name of the application, or its one-based index.
     * @type {Boolean} - The application's mute state.
     * __________
     * @throws {VMRError} - If the strip is a physical (hardware) strip or if an internal error occurs.
     */
    AppMute[p_app] {
        set {
            if (this.IsPhysical())
                throw VMRError("Cannot set application mute on physical strips", "AppGain", p_app)

            if (IsNumber(p_app))
                this.SetParameter("App[" p_app - 1 "].Mute", Value)
            else
                this.SetParameter("AppMute", "(" p_app ", " Value ")")
        }
    }

    /**
     * Creates a new VMRStrip object.
     * @param {Number} p_index - The zero-based index of the strip.
     * @param {Number} p_vmrType - The type of the running voicemeeter.
     */
    __New(p_index, p_vmrType) {
        super.__New(p_index, "Strip")
        this.Name := VMRConsts.STRIP_NAMES[p_vmrType][p_index + 1]

        switch p_vmrType {
            case 1:
                super._isPhysical := this._index < 2
            case 2:
                super._isPhysical := this._index < 3
            case 3:
                super._isPhysical := this._index < 5
        }

        ; physical strips have 2 channels, virtual strips have 8
        this._channelCount := this.IsPhysical() ? 2 : 8

        ; Setup the strip's levels array
        this.Level.Length := this._channelCount

        ; A strip's level index starts at the current total count
        this._levelIndex := VMRStrip.LEVELS_COUNT
        VMRStrip.LEVELS_COUNT += this._channelCount

        this.DefineProp("__Get", { Call: super._Get })
        this.DefineProp("__Set", { Call: super._Set })
    }

    _UpdateLevels() {
        loop this._channelCount {
            local vmrIndex := this._levelIndex + A_Index - 1
            local level := Round(20 * Log(VBVMR.GetLevel(1, vmrIndex)))
            this.Level[A_Index] := VMRUtils.EnsureBetween(level, -999, 999)
        }
    }
}
