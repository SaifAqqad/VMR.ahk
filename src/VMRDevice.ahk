#Requires AutoHotkey >=2.0
#Include VBVMR.ahk
#Include VMRError.ahk
#Include VMRUtils.ahk
#Include VMRConsts.ahk

/**
 * #### A base class for `VMRBus` and `VMRStrip`
 */
class VMRDevice {
    static IS_CLASS_INIT := false

    /**
     * #### Creates a new `VMRDevice` object.
     * 
     * @param {Number} p_index - The zero-based index of the device.
     * @param {String} p_deviceType - The type of the device. (`Bus` or `Strip`)
     */
    __New(p_index, p_deviceType) {
        this._index := p_index
        this._isPhysical := false
        this.GainLimit := 12
        this.Id := p_deviceType "[" p_index "]"
    }

    /**
     * #### Implements a default property getter.
     * this is invoked when using the object access syntax. (example: `bus.gain`)
     * 
     * @param {String} p_key - The name of the parameter.
     * 
     * ----
     * @returns {Number | String} The value of the parameter.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    _Get(p_key) {
        if (!VMRDevice.IS_CLASS_INIT)
            return
        return this.GetParameter(p_key)
    }

    /**
     * #### Implements a default property setter.
     * this is invoked when using the object access syntax. (example: `bus.gain := 0.5`)
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Number | String} p_value - The value of the parameter, or the extra parameters passed to the accessed property.
     * @param {Number | String} p_extra - An extra parameter which is set to the actual value when passing params to the accessed property. `bus.device["wdm"] := "Headset"`
     * 
     * ----
     * @returns {Number} - `0` Parameter set successfully
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    _Set(p_key, p_params, p_value) {
        if (!VMRDevice.IS_CLASS_INIT)
            return
        return this.SetParameter(p_key, p_value, p_params.Length > 0 ? p_params[1] : unset)
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
     * _____
     * @returns {Boolean}
     * @throws {VMRError} - If an internal error occurs.
     */
    IsPhysical() => this._isPhysical

    /**
     * #### Sets the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * @param {Number | String} p_value - The value of the parameter.
     * @param {Number | String} p_extra - (optional) An extra value which is used when setting some parameters like `device`
     * 
     * _____
     * @returns {Boolean} - `true` if the parameter was set successfully.
     * 
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    SetParameter(p_name, p_value, p_extra?) {
        if (!VMRDevice.IS_CLASS_INIT)
            return -1

        local vmrFunc := this._IsStringParam(p_name) ? VBVMR.SetParameterString : VBVMR.SetParameterFloat

        switch p_name, false {
            case "gain":
                p_value := VMRUtils.EnsureBetween(p_value, -60, this.GainLimit)
            case "limit":
                p_value := VMRUtils.EnsureBetween(p_value, -60, 12.0)
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

        return vmrFunc.Call(this.Id, p_name, p_value) == 0
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
                return Format("{:.1f}", vmrFunc.Call(this.Id, p_name))
            case "device":
                return vmrFunc.Call(this.Id, "device.name")
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
        return VMRUtils.DbToPercentage(this.GetParameter("gain"))
    }

    /**
     * #### Sets the gain as a percentage
     * 
     * @param {Number} p_percentage - The gain as a percentage (`0.40` = 40%)
     * 
     * _____
     * @returns {Boolean} - `true` if the gain was set successfully.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    SetGainPercentage(p_percentage) {
        return this.SetParameter("gain", VMRUtils.PercentageToDb(p_percentage))
    }

    _IsValidDriver(p_driver) => VMRUtils.IndexOf(VMRConsts.DEVICE_DRIVERS, p_driver) > 0

    _IsStringParam(p_param) => VMRUtils.IndexOf(VMRConsts.STRING_PARAMETERS, p_param) > 0

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