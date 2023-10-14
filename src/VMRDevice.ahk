#Requires AutoHotkey >=2.0
#Include VBVMR.ahk
#Include VMRError.ahk

class VMRDevice {
    static STR_PARAMETERS := ["Device", "FadeTo", "Label", "FadeBy", "AppGain", "AppMute"]
    static DEVICE_DRIVERS := ["wdm", "mme", "asio", "ks"]
    static IS_CLASS_INIT := false

    __New(p_index, p_deviceType) {
        this.index := p_index
        this.gain_limit := 12
        this.is_physical := false
        this.id := p_deviceType "[" p_index "]"
    }

    /**
     * #### Implements a default property getter.
     * this is invoked when using the object access syntax (bus.gain)
     * 
     * @param {String} p_key - The name of the parameter.
     * 
     * ----
     * @returns {Number | String} The value of the parameter.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    __Get(p_key) {
        if (!VMRDevice.IS_CLASS_INIT)
            return
        return this.GetParameter(p_key)
    }

    /**
     * #### Implements a default property setter.
     * this is invoked when using the object access syntax `bus.gain := 0.5`
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Number | String} p_value - The value of the parameter, or the extra parameters passed to the accessed property.
     * @param {Number | String} [p_extra] - An extra parameter which is set to the actual value when passing params to the accessed property. `bus.device["wdm"] := "Headset"`
     * 
     * ----
     * @returns {Number} - `0` Parameter set successfully
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    __Set(p_key, p_value, p_extra) {
        if (!VMRDevice.IS_CLASS_INIT)
            return
        return this.SetParameter(p_key, p_value, p_extra)
    }

    /**
     * #### Implements a default indexer.
     * this is invoked when using the array access syntax `bus["gain"]` or `bus["gain"] := 0.5`
     * 
     * @param {String} p_key - The name of the parameter.
     * 
     * ----
     * @returns {Number | String} The value of the parameter.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    __Item[p_key] {
        get {
            if (!VMRDevice.IS_CLASS_INIT)
                return
            return this.GetParameter(p_key)
        }
        set {
            if (!VMRDevice.IS_CLASS_INIT)
                return
            return this.SetParameter(p_key, value)
        }
    }

    /**
     * #### Returns `true` if the device is a physical (hardware) device.
     * 
     * @returns {1 | 0} 
     * @throws {VMRError} - If an internal error occurs.
     */
    IsPhysical() => this.is_physical

    /**
     * #### Sets the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * @param {Number | String} p_value - The value of the parameter.
     * @param {Number | String} [p_extra] - (optional) An extra value which is used when setting some parameters like `device`
     * 
     * _____
     * @returns {Number} - `0` Parameter set successfully
     * 
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    SetParameter(p_name, p_value, p_extra?) {
        if (!VMRDevice.IS_CLASS_INIT)
            return -1

        local vmrFunc := this._IsStringParam(p_name) ? VBVMR.SetParameterString : VBVMR.SetParameterFloat

        switch p_name, false {
            case "gain":
                p_value := this._EnsureBetween(p_value, -60, this.gain_limit)
            case "limit":
                p_value := this._EnsureBetween(p_value, -60, 12.0)
            case "device":
                local deviceDriver := IsSet(p_extra) ? p_value : "wdm"
                local deviceName := IsSet(p_extra) ? p_extra : p_value

                ; Allows setting the device using a device object (e.g. bus.device := {name: "Headset", driver: "wdm"})
                ; Device objects can be retrieved using VMRBus/VMRStrip GetDevice() method
                if (IsObject(deviceName)) {
                    deviceDriver := deviceName.driver
                    deviceName := deviceName.name
                }

                if (!this._IsValidDriver(deviceDriver))
                    throw VMRError(deviceDriver " is not a valid device driver", this.SetParameter.Name)

                p_name := "device." deviceDriver
                p_value := deviceName
            case "mute":
                p_value := p_value == -1 ? !this.GetParameter("mute") : p_value
        }

        return vmrFunc.Call(this.id, p_name, p_value)
    }

    /**
     * #### Returns the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * 
     * _____
     * @returns {String | Number} - The value of the parameter.
     * 
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    GetParameter(p_name) {
        if (!VMRDevice.IS_CLASS_INIT)
            return -1

        local vmrFunc := this._IsStringParam(p_name) ? VBVMR.GetParameterString : VBVMR.GetParameterFloat

        switch p_name {
            case "gain", "limit":
                return Format("{:.1f}", vmrFunc.Call(this.id, p_name))
            case "device":
                return vmrFunc.Call(this.id, "device.name")
        }

        return this.getParameter(p_name)
    }

    /**
     * #### Returns the gain as a percentage
     * 
     * _____
     * @returns {Number} - The gain as a percentage (`0.40` = 40%)
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    GetGainPercentage() {
        return this._DbToPercentage(this.GetParameter("gain"))
    }

    /**
     * #### Sets the gain as a percentage
     * 
     * @param {Number} p_percentage - The gain as a percentage (`0.40` = 40%)
     * 
     * _____
     * @returns {Number} - `0` Parameter set successfully
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    SetGainPercentage(p_percentage) {
        return this.SetParameter("gain", this._PercentageToDb(p_percentage))
    }

    _DbToPercentage(p_dB) {
        min_s := 10 ** (-60 / 20), max_s := 10 ** (0 / 20)
        return Format("{:.2f}", ((10 ** (p_dB / 20)) - min_s) / (max_s - min_s) * 100)
    }

    _PercentageToDb(p_percentage) {
        min_s := 10 ** (-60 / 20), max_s := 10 ** (0 / 20)
        return Format("{:.1f}", 20 * Log(min_s + p_percentage / 100 * (max_s - min_s)))
    }

    _EnsureBetween(p_value, p_min, p_max) => Max(p_min, Min(p_max, p_value))

    _IsValidDriver(p_driver) {
        for driver in VMRDevice.DEVICE_DRIVERS {
            if (driver = p_driver)
                return true
        }
        return false
    }

    _IsStringParam(p_param) {
        for param in VMRDevice.STR_PARAMETERS {
            if (param = p_param)
                return true
        }
        return false
    }

    static _GetDevice(p_devicesArr, p_name, p_driver?) {
        for index, device in p_devicesArr {
            if (IsSet(p_driver) && device.driver = p_driver && InStr(device.name, p_name))
                return device.Clone()

            if (device.name = p_name)
                return device.Clone()
        }

        return ""
    }
}