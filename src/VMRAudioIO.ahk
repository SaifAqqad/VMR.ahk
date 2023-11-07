#Requires AutoHotkey >=2.0
#Include VBVMR.ahk
#Include VMRError.ahk
#Include VMRUtils.ahk
#Include VMRConsts.ahk
#Include VMRDevice.ahk

/**
 * A base class for `VMRBus` and `VMRStrip`
 */
class VMRAudioIO {
    static IS_CLASS_INIT := false

    /**
     * The object's upper gain limit
     * @type {Number}
     * 
     * Setting the gain above the limit will reset it to this value.
     */
    GainLimit := 12

    /**
     * An array of the object's channel levels
     * @type {Array}
     * 
     * Physical (hardware) strips have 2 channels (left, right), Buses and virtual strips have 8 channels
     * __________
     * @example <caption>Get the current peak level of a bus</caption>
     * local peakLevel := Max(vm.Bus[1].Level*)
     */
    Level := Array()

    /**
     * Creates a new `VMRAudioIO` object.
     * @param {Number} p_index - The zero-based index of the bus/strip.
     * @param {String} p_ioType - The type of the object. (`Bus` or `Strip`)
     */
    __New(p_index, p_ioType) {
        this._index := p_index
        this._isPhysical := false
        this.Id := p_ioType "[" p_index "]"
    }

    /**
     * @private - Internal method
     * @description Implements a default property getter, this is invoked when using the object access syntax.
     * @example
     * local sampleRate := bus.device["sr"]
     * MsgBox("Gain is " bus.gain)
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Array} p_params - An extra param passed when using bracket syntax with a normal prop access (`bus.device["sr"]`).
     * __________
     * @returns {Any} The value of the parameter.
     * @throws {VMRError} - If an internal error occurs.
     */
    _Get(p_key, p_params) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return ""

        if (p_params.Length > 0) {
            local param := p_params[1]
            p_key .= IsNumber(param) ? "[" param "]" : "." param
        }

        return this.GetParameter(p_key)
    }

    /**
     * @private - Internal method
     * @description Implements a default property setter, this is invoked when using the object access syntax.
     * @example
     * bus.gain := 0.5
     * bus.device["mme"] := "Headset"
     * 
     * @param {String} p_key - The name of the parameter.
     * @param {Array} p_params - An extra param passed when using bracket syntax with a normal prop access. `bus.device["wdm"] := "Headset"`
     * @param {Any} p_value - The value of the parameter.
     * __________
     * @returns {Any} - If the parameter was set successfully it returns `p_value`, otherwise it returns `""`.
     * @throws {VMRError} - If an internal error occurs.
     */
    _Set(p_key, p_params, p_value) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return ""

        if (p_params.Length > 0) {
            local param := p_params[1]
            p_key .= IsNumber(param) ? "[" param "]" : "." param
        }

        return this.SetParameter(p_key, p_value) ? p_value : ""
    }

    /**
     * Implements a default indexer.
     * this is invoked when using the bracket access syntax.
     * @example
     * MsgBox(strip["mute"])
     * bus["gain"] := 0.5
     * 
     * @param {String} p_key - The name of the parameter.
     * __________
     * @returns {Any} The value of the parameter.
     * @throws {VMRError} - If an internal error occurs.
     */
    __Item[p_key] {
        get {
            if (!VMRAudioIO.IS_CLASS_INIT)
                return ""
            return this.GetParameter(p_key)
        }
        set {
            if (!VMRAudioIO.IS_CLASS_INIT)
                return ""
            return this.SetParameter(p_key, Value) ? Value : ""
        }
    }

    /**
     * Returns `true` if the bus/strip is a physical (hardware) one.
     * __________
     * @returns {Boolean}
     */
    IsPhysical() => this._isPhysical

    /**
     * Sets the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * @param {Any} p_value - The value of the parameter.
     * __________
     * @returns {Boolean} - `true` if the parameter was set successfully.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    SetParameter(p_name, p_value) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return false

        local vmrFunc := VMRAudioIO._IsStringParam(p_name) ? VBVMR.SetParameterString.Bind(VBVMR) : VBVMR.SetParameterFloat.Bind(VBVMR)

        if (p_name = "gain") {
            p_value := VMRUtils.EnsureBetween(p_value, -60, this.GainLimit)
        }
        else if (p_name = "limit") {
            p_value := VMRUtils.EnsureBetween(p_value, -60, 12.0)
        }
        else if (p_name = "mute") {
            p_value := p_value < 0 ? !this.GetParameter("mute") : p_value
        }
        else if (InStr(p_name, "device")) {
            local deviceParts := StrSplit(p_name, ".")

            local deviceDriver := deviceParts.Length > 1 ? deviceParts[2] : "wdm"
            local deviceName := p_value

            ; Allow setting the device using a device object (e.g. bus.device := { name: "Headset", driver: "wdm" })
            ; Device objects can be retrieved using VMR's GetBusDevice/GetStripDevice methods
            if (IsObject(deviceName)) {
                deviceDriver := deviceName.driver
                deviceName := deviceName.name
            }

            if (!VMRAudioIO._IsValidDriver(deviceDriver))
                throw VMRError(deviceDriver " is not a valid device driver", this.SetParameter.Name)

            p_name := "device." deviceDriver
            p_value := deviceName
        }

        return vmrFunc.Call(this.Id, p_name, p_value) == 0
    }

    /**
     * Returns the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * __________
     * @returns {Any} - The value of the parameter.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    GetParameter(p_name) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return -1

        local vmrFunc := VMRAudioIO._IsStringParam(p_name) ? VBVMR.GetParameterString.Bind(VBVMR) : VBVMR.GetParameterFloat.Bind(VBVMR)

        switch p_name {
            case "gain", "limit":
                return Format("{:.1f}", vmrFunc.Call(this.Id, p_name))
            case "device":
                p_name := "device.name"
        }

        return vmrFunc.Call(this.Id, p_name)
    }

    /**
     * Returns the gain as a percentage
     * __________
     * @returns {Number} - The gain as a percentage (`0.40` = 40%)
     * @throws {VMRError} - If an internal error occurs.
     */
    GetGainPercentage() {
        return VMRUtils.DbToPercentage(this.GetParameter("gain"))
    }

    /**
     * Sets the gain as a percentage
     * @example local gain := vm.Bus[1].SetGainPercentage(0.75) ; sets the gain to 75%
     * 
     * @param {Number} p_percentage - The gain as a percentage (float between 0 and 1)
     * __________
     * @returns {Boolean} - `true` if the gain was set successfully.
     * @throws {VMRError} - If an internal error occurs.
     */
    SetGainPercentage(p_percentage) {
        return this.SetParameter("gain", VMRUtils.PercentageToDb(p_percentage))
    }

    static _IsValidDriver(p_driver) => VMRUtils.IndexOf(VMRConsts.DEVICE_DRIVERS, p_driver) > 0

    static _IsStringParam(p_param) => VMRUtils.IndexOf(VMRConsts.STRING_PARAMETERS, p_param) > 0

    /**
     * @private - Internal method
     * @description Returns a device object.
     * 
     * @param {Array} p_devicesArr - An array of {@link VMRDevice|`VMRDevice`} objects.
     * @param {String} p_name - The name of the device.
     * @param {String} p_driver - The driver of the device.
     * @see {@link VMRConsts.DEVICE_DRIVERS|`VMRConsts.DEVICE_DRIVERS`} for a list of valid drivers.
     * __________
     * @returns {VMRDevice} - A device object, or an empty string `""` if the device was not found.
     */
    static _GetDevice(p_devicesArr, p_name, p_driver?) {
        if (!IsSet(p_driver))
            p_driver := VMRConsts.DEFAULT_DEVICE_DRIVER

        for (index, device in p_devicesArr) {
            if (device.driver = p_driver && InStr(device.name, p_name))
                return device.Clone()
        }

        return ""
    }
}
