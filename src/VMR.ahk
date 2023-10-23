#Requires AutoHotkey >=2.0
#Include VMRUtils.ahk
#Include VMRError.ahk
#Include VMRConsts.ahk
#Include VBVMR.ahk
#Include VMRDevice.ahk
#Include VMRBus.ahk
#Include VMRStrip.ahk

/**
 * #### A wrapper class for Voicemeeter Remote that abstracts away the low-level API to simplify usage.
 * 
 * Must be initialized by calling `Login()` after creating the VMR instance.
 */
class VMR {
    type := ""

    /**
     * #### Initializes the internal VBVMR wrapper class.
     * 
     * @param {String} p_path - (Optional) The path to the Voicemeeter Remote DLL. If not specified, it will try to find it in the registry.
     * 
     * _____
     * @throws {VMRError} - If the DLL is not found in the specified path or if voicemeeter is not installed.
     */
    __New(p_path := "") {
        VBVMR.Init(p_path)

        this._eventListeners := Map()
        this._eventListeners.CaseSense := "Off"
        for (event in VMRConsts.Events.OwnProps())
            this._eventListeners[event] := []
    }

    /**
     * #### Initializes the VMR instance and opens the communication pipe with Voicemeeter.
     * 
     * @param {Boolean} p_launchVoicemeeter - (Optional) Whether to launch Voicemeeter if it's not already running. Defaults to `true`.
     * 
     * _____
     * @returns {VMR} The VMR instance.
     * 
     * @throws {VMRError} - If an internal error occurs.
     */
    Login(p_launchVoicemeeter := true) {
        local loginStatus := VBVMR.Login()

        ; Check if we should launch the Voicemeeter UI
        if (loginStatus != 0 && p_launchVoicemeeter) {
            local vmPID := this.RunVoicemeeter()
            WinWait("ahk_pid " . vmPID)
            Sleep(2000)
        }

        this.type := VMRConsts.VOICEMEETER_TYPES[VBVMR.GetVoicemeeterType()]
        if (!this.type)
            throw VMRError("Unsupported Voicemeeter type: " . VBVMR.GetVoicemeeterType(), this.Login.Name)

        OnExit(this.__Delete)
        ; TODO: setup sync timer, init obj/arr

        this.Sync()
        return this
    }

    /**
     * #### Attempts to run Voicemeeter.
     * 
     * Passing a `p_type` will attempt to run the specified Voicemeeter type, otherwise it will try to run the highest available type.
     * 
     * @param {Number} p_type - (Optional) The type of Voicemeeter to run. If omitted, the highest available type will be used.
     * 
     * _____
     * @returns {Number} The PID of the launched Voicemeeter process.
     * 
     * @throws {VMRError} If the specified Voicemeeter type is invalid, or if no Voicemeeter type could be launched.
     */
    RunVoicemeeter(p_type?) {
        local vmPID := ""
        if (IsSet(p_type)) {
            local vmInfo := VMRConsts.VOICEMEETER_TYPES[p_type]
            if (!vmInfo)
                throw VMRError("Invalid Voicemeeter type: " . p_type, this.RunVoicemeeter.Name)

            local vmPath := VBVMR.DLL_PATH . "\" . vmInfo.executable
            Run(vmPath, VBVMR.DLL_PATH, "Hide", &vmPID)

            return vmPID
        }

        local vmTypeCount := VMRConsts.VOICEMEETER_TYPES.Length
        loop vmTypeCount {
            try {
                vmPID := this.RunVoicemeeter((vmTypeCount + 1) - A_Index)
                return vmPID
            }
        }

        throw VMRError("Failed to launch Voicemeeter", this.RunVoicemeeter.Name)
    }

    ; TODO: Login, obj/arr init, auto update devices, sync timers

    /**
     * #### Retrieves a strip device (input device) by its name/driver.
     * 
     * @param {String} p_name - The name of the device, or any substring of it.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, `p_name` must be the full name of the device.
     * 
     * _____
     * @returns {{name, driver}} The device object, or an empty string if no device was found.
     */
    GetStripDevice(p_name, p_driver?) => VMRDevice._GetDevice(VMRStrip.DEVICES, p_name, p_driver)

    /**
     * #### Retrieves all strip devices (input devices).
     * 
     * _____
     * @returns {Array} An array of device objects `{name, driver}`.
     */
    GetStripDevices() => VMRStrip.DEVICES

    /**
     * #### Retrieves a bus device (output device) by its name/driver.
     * 
     * @param {String} p_name - The name of the device, or any substring of it.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, `p_name` must be the full name of the device.
     * 
     * _____
     * @returns {{name, driver}} The device object, or an empty string if no device was found.
     */
    GetBusDevice(p_name, p_driver?) => VMRDevice._GetDevice(VMRBus.DEVICES, p_name, p_driver)

    /**
     * #### Retrieves all bus devices (output devices).
     * 
     * _____
     * @returns {Array} An array of device objects `{name, driver}`.
     */
    GetBusDevices() => VMRBus.DEVICES

    /**
     * #### Registers a callback function to be called when the specified event is fired.
     * 
     * @param {String} p_event - The name of the event to listen for. See `VMRConsts.Events` for a list of available events.
     * @param {Func} p_listener - The function to call when the event is fired.
     * 
     * _____
     * @throws {VMRError} If the specified event is invalid, or if the listener is not a valid `Func` object.
     */
    On(p_event, p_listener) {
        if (!this._eventListeners.Has(p_event))
            throw VMRError("Invalid event: " p_event, this.On.Name)

        if !(p_listener is Func)
            throw VMRError("Invalid listener: " String(p_listener), this.On.Name)

        local eventListeners := this._eventListeners[p_event]

        if (VMRUtils.IndexOf(eventListeners, p_listener) == -1)
            eventListeners.Push(p_listener)
    }

    /**
     * #### Removes a callback function from the specified event.
     * 
     * @param {String} p_event - The name of the event.
     * @param {Func} p_listener - The function to remove.
     * 
     * _____
     * @returns {Boolean} Whether the listener was removed.
     * 
     * @throws {VMRError} If the specified event is invalid, or if the listener is not a valid `Func` object.
     */
    Off(p_event, p_listener) {
        if (!this._eventListeners.Has(p_event))
            throw VMRError("Invalid event: " p_event, this.Off.Name)

        if !(p_listener is Func)
            throw VMRError("Invalid listener: " String(p_listener), this.Off.Name)

        local eventListeners := this._eventListeners[p_event]
        local listenerIndex := VMRUtils.IndexOf(eventListeners, p_listener)

        if (listenerIndex == -1)
            return false

        eventListeners.RemoveAt(listenerIndex)
        return true
    }

    /**
     * #### Syncronizes the VMR instance with Voicemeeter.
     * 
     * Normally this is called automatically on a timer, and doesn't need to be manually called/checked.
     * 
     * _____
     * @returns {Boolean} - Whether voicemeeter state has changed since the last sync.
     */
    Sync() {
        static ignoreMsg := false
        try {
            ; TODO: call VBVMR.*IsDirty funcs + invoke event listeners
        } catch Error as err {
            if (ignoreMsg)
                return false

            result := MsgBox(
                Format("An error occurred during VMR sync: {}`nDetails:{}`nAttempt to restart Voicemeeter?", err.Message, err.Extra),
                "VMR",
                "YesNo Icon! T10"
            )
            switch (result) {
                case "Yes":
                    this.runVoicemeeter(this.type.id)
                case "No", "Timeout":
                    ignore_msg := true
            }

            sleep 1000
            return false
        }
    }

    __Delete() {
        if (!this.type)
            return

        this.type := ""
        while (this.Sync()) {
        }

        Sleep(100) ; Make sure all commands finish executing before logging out
        VBVMR.Logout()
    }
}