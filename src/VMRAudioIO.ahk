#Requires AutoHotkey >=2.0

#Include VBVMR.ahk
#Include VMRError.ahk
#Include VMRUtils.ahk
#Include VMRConsts.ahk
#Include VMRDevice.ahk
#Include VMRAsyncOp.ahk

/**
 * A base class for {@link VMRBus|`VMRBus`} and {@link VMRStrip|`VMRStrip`}
 */
class VMRAudioIO {
    static IS_CLASS_INIT := false

    /**
     * The object's upper gain limit
     * @type {Number}
     * 
     * Setting the gain above the limit will reset it to this value.
     */
    GainLimit := VMRConsts.AUDIO_IO_GAIN_MAX

    /**
     * Gets/Sets the gain as a percentage
     * @type {Number} - The gain as a percentage (e.g. `44` = 44%)
     * 
     * @example
     * local gain := vm.Bus[1].GainPercentage ; get the gain as a percentage
     * vm.Bus[1].GainPercentage++ ; increases the gain by 1%
     */
    GainPercentage {
        get => VMRUtils.DbToPercentage(this.GetParameter("gain"))
        set => this.SetParameter("gain", VMRUtils.PercentageToDb(Value))
    }

    /**
     * Set/Get the object's EQ parameters.
     * 
     * @param {Array} p_params - An array containing the EQ parameter name and the channel/cell numbers.
     * 
     * - Bus EQ parameters `EQ[param] := value`
     * - EQ channel/cells parameters `EQ[param, channel, cell] := value`
     * 
     * @example
     * vm.Bus[1].EQ["gain", 1, 1] := -6
     * vm.Bus[1].EQ["q", 1, 1] := 90
     * vm.Bus[1].EQ["AB"] := true
     * __________
     * @returns {Number} - The EQ parameter's value.
     */
    EQ[p_params*] {
        get {
            if (p_params.Length == 3)
                this.GetParameter("EQ.channel[" p_params[2] - 1 "].cell[" p_params[3] - 1 "]." p_params[1])
            else
                this.GetParameter("EQ." p_params[1])

        }
        set {
            if (p_params.Length == 3)
                this.SetParameter("EQ.channel[" p_params[2] - 1 "].cell[" p_params[3] - 1 "]." p_params[1], Value)
            else
                this.SetParameter("EQ." p_params[1], Value)
        }
    }

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
     * The object's identifier that's used when calling VMR's functions.    
     * Like `Bus[0]` or `Strip[3]`
     * 
     * @type {String}
     */
    Id := ""

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
            for param in p_params {
                p_key .= IsNumber(param) ? "[" param "]" : "." param
            }
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
     * @returns {Boolean} - `true` if the parameter was set successfully.
     * @throws {VMRError} - If an internal error occurs.
     */
    _Set(p_key, p_params, p_value) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return false

        if (p_params.Length > 0) {
            for param in p_params {
                p_key .= IsNumber(param) ? "[" param "]" : "." param
            }
        }

        return !this.SetParameter(p_key, p_value).IsEmpty
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
     * @type {Any} - The value of the parameter.
     * @throws {VMRError} - If an internal error occurs.
     */
    __Item[p_key] {
        get => this.GetParameter(p_key)
        set => this.SetParameter(p_key, Value)
    }

    /**
     * Sets the value of a parameter.
     * 
     * @param {String} p_name - The name of the parameter.
     * @param {Any} p_value - The value of the parameter.
     * __________
     * @returns {VMRAsyncOp} - An async operation that resolves to `true` if the parameter was set successfully.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    SetParameter(p_name, p_value) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return VMRAsyncOp.Empty

        local vmrFunc := VMRAudioIO._IsStringParam(p_name) ? VBVMR.SetParameterString.Bind(VBVMR) : VBVMR.SetParameterFloat.Bind(VBVMR)

        if (p_name = "gain") {
            p_value := VMRUtils.EnsureBetween(p_value, VMRConsts.AUDIO_IO_GAIN_MIN, this.GainLimit)
        }
        else if (p_name = "limit") {
            p_value := VMRUtils.EnsureBetween(p_value, VMRConsts.AUDIO_IO_LIMIT_MIN, VMRConsts.AUDIO_IO_LIMIT_MAX)
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
                throw VMRError(deviceDriver " is not a valid device driver", this.SetParameter.Name, p_name, p_value)

            p_name := "device." deviceDriver
            p_value := deviceName
        }

        local result := vmrFunc.Call(this.Id, p_name, p_value)
        return VMRAsyncOp(() => result == 0, 50)
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
                return Format("{:.2f}", vmrFunc.Call(this.Id, p_name))
            case "device":
                p_name := "device.name"
        }

        return vmrFunc.Call(this.Id, p_name)
    }

    /**
     * Increments a parameter by a specific amount.  
     * - It's recommended to use this method instead of incrementing the parameter directly (`++vm.Bus[1].Gain`).
     * - Since this method doesn't fetch the current value of the parameter to update it, {@link @VMRAudioIO.GainLimit|`GainLimit`} cannot be applied here.
     * 
     * @param {String} p_param - The name of the parameter, must be a numeric parameter (see {@link VMRConsts.IO_STRING_PARAMETERS|`VMRConsts.IO_STRING_PARAMETERS`}).
     * @param {Number} p_amount - The amount to increment the parameter by, can be set to a negative value to decrement instead.
     * __________
     * @returns {VMRAsyncOp} - An async operation that resolves with the incremented value.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     * __________
     * @example <caption>usage with callbacks</caption>
     * vm.Bus[1].Increment("gain", 1).Then(val => Tooltip(val)) ; increases the gain by 1dB
     * vm.Bus[1].Increment("gain", -5).Then(val => Tooltip(val)) ; decreases the gain by 5dB
     * 
     * @example <caption>"synchronous" usage</caption>
     * ; increases the gain by 1dB and waits for the operation to complete
     * ; this is equivalent to `vm.Bus[1].Gain++` followed by `Sleep(50)`
     * gainValue := vm.Bus[1].Increment("gain", 1).Await()
     * 
     */
    Increment(p_param, p_amount) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return VMRAsyncOp.Empty

        if (!IsNumber(p_amount))
            throw VMRError("p_amount must be a number", this.Increment.Name, p_param, p_amount)

        if (VMRAudioIO._IsStringParam(p_param))
            throw VMRError("p_param must be a numeric parameter", this.Increment.Name, p_param, p_amount)

        local script := Format("{}.{} {} {}", this.Id, p_param, p_amount < 0 ? "-=" : "+=", Abs(p_amount))
        VBVMR.SetParameters(script)

        return VMRAsyncOp(() => this.GetParameter(p_param), 50)
    }

    /**
     * Sets the gain to a specific value with a progressive fade.
     * 
     * @param {Number} p_db - The gain value in dBs.
     * @param {Number} p_duration - The duration of the fade in milliseconds.
     * __________
     * @returns {VMRAsyncOp} - An async operation that resolves with the final gain value.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    FadeTo(p_db, p_duration) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return VMRAsyncOp.Empty

        if (!IsNumber(p_db))
            throw VMRError("p_db must be a number", this.FadeTo.Name, p_db, p_duration)

        if (!IsNumber(p_duration))
            throw VMRError("p_duration must be a number", this.FadeTo.Name, p_db, p_duration)

        if (this.SetParameter("FadeTo", "(" p_db ", " p_duration ")").IsEmpty)
            return VMRAsyncOp.Empty

        return VMRAsyncOp(() => this.GetParameter("gain"), p_duration + 50)
    }

    /**
     * Fades the gain by a specific amount.
     * 
     * @param {Number} p_dbAmount - The amount to fade the gain by in dBs.
     * @param {Number} p_duration - The duration of the fade in milliseconds.
     * _________
     * @returns {VMRAsyncOp} - An async operation that resolves with the final gain value.
     * @throws {VMRError} - If invalid parameters are passed or if an internal error occurs.
     */
    FadeBy(p_dbAmount, p_duration) {
        if (!VMRAudioIO.IS_CLASS_INIT)
            return VMRAsyncOp.Empty

        if (!IsNumber(p_dbAmount))
            throw VMRError("p_dbAmount must be a number", this.FadeBy.Name, p_dbAmount, p_duration)

        if (!IsNumber(p_duration))
            throw VMRError("p_duration must be a number", this.FadeBy.Name, p_dbAmount, p_duration)

        if (!this.SetParameter("FadeBy", "(" p_dbAmount ", " p_duration ")"))
            return VMRAsyncOp.Empty

        return VMRAsyncOp(() => this.GetParameter("gain"), p_duration + 50)
    }

    /**
     * Returns `true` if the bus/strip is a physical (hardware) one.
     * __________
     * @returns {Boolean}
     */
    IsPhysical() => this._isPhysical

    static _IsValidDriver(p_driver) => VMRUtils.IndexOf(VMRConsts.DEVICE_DRIVERS, p_driver) > 0

    static _IsStringParam(p_param) => VMRUtils.IndexOf(VMRConsts.IO_STRING_PARAMETERS, p_param) > 0

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
        local device, index

        if (!IsSet(p_driver))
            p_driver := VMRConsts.DEFAULT_DEVICE_DRIVER

        for (index, device in p_devicesArr) {
            if (device.driver = p_driver && InStr(device.name, p_name))
                return device.Clone()
        }

        return ""
    }
}
