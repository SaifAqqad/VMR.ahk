/**
 * VMR.ahk <buildVersion>
 * - Build timestamp <buildTimestamp>
 * - Repository: {@link https://github.com/SaifAqqad/VMR.ahk GitHub}
 * - Documentation: {@link https://saifaqqad.github.io/VMR.ahk VMR Docs}
 */

#Requires AutoHotkey >=2.0

#Include VMRUtils.ahk
#Include VMRError.ahk
#Include VMRConsts.ahk
#Include VBVMR.ahk
#Include VMRAudioIO.ahk
#Include VMRBus.ahk
#Include VMRStrip.ahk

/**
 * A wrapper class for Voicemeeter Remote that abstracts away the low-level API to simplify usage.  
 * Must be initialized by calling {@link @VMR.Login|`Login()`} after creating the VMR instance.
 */
class VMR {
    /**
     * The type of Voicemeeter that is currently running.
     * @type {Object} - An object containing information about the current Voicemeeter type.
     * @see {@link VMRConsts.VOICEMEETER_TYPES|`VMRConsts.VOICEMEETER_TYPES`} for a list of available types.
     */
    Type := ""

    /**
     * An array of voicemeeter buses
     * @type {Array} - An array of {@link VMRBus|`VMRBus`} objects.
     */
    Bus := Array()

    /**
     * An array of voicemeeter strips
     * @type {Array} - An array of {@link VMRStrip|`VMRStrip`} objects.
     */
    Strip := Array()

    /**
     * Creates a new VMR instance and initializes the {@link VBVMR|`VBVMR`} class.
     * @param {String} p_path - (Optional) The path to the Voicemeeter Remote DLL. If not specified, VBVMR will attempt to find it in the registry.
     * __________
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
     * Initializes the VMR instance and opens the communication pipe with Voicemeeter.
     * @param {Boolean} p_launchVoicemeeter - (Optional) Whether to launch Voicemeeter if it's not already running. Defaults to `true`.
     * __________
     * @returns {VMR} The {@link VMR|`VMR`} instance.
     * @throws {VMRError} - If an internal error occurs.
     */
    Login(p_launchVoicemeeter := true) {
        local loginStatus := VBVMR.Login()

        ; Check if we should launch the Voicemeeter UI
        if (loginStatus != 0 && p_launchVoicemeeter) {
            local vmPID := this.RunVoicemeeter()
            WinWait("ahk_class VBCABLE0Voicemeeter0MainWindow0 ahk_pid" vmPID)
            Sleep(2000)
        }

        this.Type := VMRConsts.VOICEMEETER_TYPES[VBVMR.GetVoicemeeterType()].Clone()
        if (!this.Type)
            throw VMRError("Unsupported Voicemeeter type: " . VBVMR.GetVoicemeeterType(), this.Login.Name)

        OnExit(this.__Delete.Bind(this))

        ; Initialize VMR components (bus/strip arrays, macro buttons, etc)
        this._InitializeComponents()

        ; Setup timers
        this._syncTimer := this.Sync.Bind(this)
        this._levelsTimer := this._UpdateLevels.Bind(this)
        SetTimer(this._syncTimer, VMRConsts.SYNC_TIMER_INTERVAL)
        SetTimer(this._levelsTimer, VMRConsts.LEVELS_TIMER_INTERVAL)

        ; Listen for device changes to update the device arrays
        this._updateDevicesCallback := this.UpdateDevices.Bind(this)
        OnMessage(VMRConsts.WM_DEVICE_CHANGE, this._updateDevicesCallback)

        this.Sync()
        return this
    }

    /**
     * Attempts to run Voicemeeter.
     * When passing a `p_type`, it will only attempt to run the specified Voicemeeter type,
     * otherwise it will attempt to run every voicemeeter type descendingly until one is successfully launched.
     * 
     * @param {Number} p_type - (Optional) The type of Voicemeeter to run.
     * __________
     * @returns {Number} The PID of the launched Voicemeeter process.
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

    /**
     * Retrieves a strip (input) device by its name/driver.
     * @param {String} p_name - The name of the device, or any substring of it.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, {@link VMRConsts.DEFAULT_DEVICE_DRIVER|`VMRConsts.DEFAULT_DEVICE_DRIVER`} will be used.
     * __________
     * @returns {VMRDevice} The device object `{name, driver}`, or an empty string `""` if no device was found.
     */
    GetStripDevice(p_name, p_driver?) => VMRAudioIO._GetDevice(VMRStrip.Devices, p_name, p_driver?)

    /**
     * Retrieves all strip devices (input devices).
     * __________
     * @returns {Array} An array of {@link VMRDevice|`VMRDevice`} objects.
     */
    GetStripDevices() => VMRStrip.Devices

    /**
     * Retrieves a bus (output) device by its name/driver.
     * @param {String} p_name - The name of the device, or any substring of it.
     * @param {String} p_driver - (Optional) The driver of the device, If omitted, {@link VMRConsts.DEFAULT_DEVICE_DRIVER|`VMRConsts.DEFAULT_DEVICE_DRIVER`} will be used.
     * __________
     * @returns {VMRDevice} The device object `{name, driver}`, or an empty string `""` if no device was found.
     */
    GetBusDevice(p_name, p_driver?) => VMRAudioIO._GetDevice(VMRBus.Devices, p_name, p_driver?)

    /**
     * Retrieves all bus devices (output devices).
     * __________
     * @returns {Array} An array of {@link VMRDevice|`VMRDevice`} objects.
     */
    GetBusDevices() => VMRBus.Devices

    /**
     * Registers a callback function to be called when the specified event is fired.
     * @param {String} p_event - The name of the event to listen for.
     * @param {Func} p_listener - The function to call when the event is fired.
     * __________
     * @example vm.On(VMRConsts.Events.ParametersChanged, () => MsgBox("Parameters changed!"))
     * @see {@link VMRConsts.Events|`VMRConsts.Events`} for a list of available events.
     * __________
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
     * Removes a callback function from the specified event.
     * @param {String} p_event - The name of the event.
     * @param {Func} p_listener - (Optional) The function to remove, if omitted, all listeners for the specified event will be removed.
     * __________
     * @example vm.Off("parametersChanged", myListener)
     * @see {@link VMRConsts.Events|`VMRConsts.Events`} for a list of available events.
     * __________
     * @returns {Boolean} Whether the listener was removed.
     * @throws {VMRError} If the specified event is invalid, or if the listener is not a valid `Func` object.
     */
    Off(p_event, p_listener?) {
        if (!this._eventListeners.Has(p_event))
            throw VMRError("Invalid event: " p_event, this.Off.Name)

        if (!IsSet(p_listener)) {
            this._eventListeners[p_event] := Array()
            return true
        }

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
     * Synchronizes the VMR instance with Voicemeeter.
     * __________
     * @returns {Boolean} - Whether voicemeeter state has changed since the last sync.
     */
    Sync() {
        static ignoreMsg := false
        try {
            ; Prevent multiple syncs from running at the same time
            Critical("On")

            local dirtyParameters := VBVMR.IsParametersDirty()
                , dirtyMacroButtons := VBVMR.MacroButton_IsDirty()

            ; Api calls were successful -> reset ignoreMsg flag
            ignoreMsg := false

            if (dirtyParameters > 0)
                this._DispatchEvent(VMRConsts.Events.ParametersChanged)

            if (dirtyMacroButtons > 0)
                this._DispatchEvent(VMRConsts.Events.MacroButtonsChanged)

            ; Check if there are any listeners for midi messages
            local midiListeners := this._eventListeners[VMRConsts.Events.MidiMessage]
            if (midiListeners.Length > 0) {
                ; Get new midi messages and dispatch event if there's any
                local midiMessages := VBVMR.GetMidiMessage()
                if (midiMessages && midiMessages.Length > 0)
                    this._DispatchEvent(VMRConsts.Events.MidiMessage, midiMessages)
            }

            Critical("Off")
            return dirtyParameters || dirtyMacroButtons
        }
        catch Error as err {
            Critical("Off")

            if (ignoreMsg)
                return false

            result := MsgBox(
                Format("An error occurred during VMR sync:`n{}`nDetails: {}`nAttempt to restart Voicemeeter?", err.Message, err.Extra),
                "VMR",
                "YesNo Icon! T10"
            )

            switch (result) {
                case "Yes":
                    this.runVoicemeeter(this.Type.id)
                case "No", "Timeout":
                    ignoreMsg := true
            }

            Sleep(1000)
            return false
        }
    }

    /**
     * Executes a Voicemeeter script (**not** an AutoHotkey script).
     * - Scripts can contain one or more parameter changes
     * - Changes can be seperated by a new line, `;` or `,`.
     * - Indices in the script are zero-based.
     * 
     * @param {String} p_script - The script to execute.
     * __________
     * @throws {VMRError} If an error occurs while executing the script.
     */
    Exec(p_script) {
        local result := VBVMR.SetParameters(p_script)

        if (result > 0)
            throw VMRError("An error occurred while executing the script at line: " . result, this.Exec.Name)
    }

    /**
     * Updates the list of strip/bus devices.
     * @param {Number} p_wParam - (Optional) If passed, must be equal to {@link VMRConsts.WM_DEVICE_CHANGE_PARAM|`VMRConsts.WM_DEVICE_CHANGE_PARAM`} to update the device arrays.
     * __________
     * @throws {VMRError} If an internal error occurs.
     */
    UpdateDevices(p_wParam?, *) {
        if (IsSet(p_wParam) && p_wParam != VMRConsts.WM_DEVICE_CHANGE_PARAM)
            return

        VMRStrip.Devices := Array()
        loop VBVMR.Input_GetDeviceNumber()
            VMRStrip.Devices.Push(VBVMR.Input_GetDeviceDesc(A_Index - 1))

        VMRBus.Devices := Array()
        loop VBVMR.Output_GetDeviceNumber()
            VMRBus.Devices.Push(VBVMR.Output_GetDeviceDesc(A_Index - 1))

        SetTimer(() => this._DispatchEvent(VMRConsts.Events.DevicesUpdated), -20)
    }

    ToString() {
        local value := "VMR:`n"

        if (this.Type) {
            value .= "Logged into " . this.Type.name . " in (" . VBVMR.DLL_PATH . ")"
        }
        else {
            value .= "Not logged in"
        }

        return value
    }

    /**
     * @private - Internal method
     * @description Dispatches an event to all listeners.
     * 
     * @param {String} p_event - The name of the event to dispatch.
     * @param {Array} p_args - (Optional) An array of arguments to pass to the listeners.
     */
    _DispatchEvent(p_event, p_args*) {
        local eventListeners := this._eventListeners[p_event]
        if (eventListeners.Length == 0)
            return

        _eventDispatcher() {
            for (listener in eventListeners) {
                if (p_args.Length == 0 || listener.MaxParams < p_args.Length)
                    listener()
                else
                    listener(p_args*)
            }
        }

        SetTimer(_eventDispatcher, -1)
    }

    /**
     * @private - Internal method
     * @description Initializes VMR's components (bus/strip arrays, macroButton obj, etc).
     */
    _InitializeComponents() {
        this.Bus := Array()
        loop this.Type.busCount {
            this.Bus.Push(VMRBus(A_Index - 1, this.Type.id))
        }

        this.Strip := Array()
        loop this.Type.stripCount {
            this.Strip.Push(VMRStrip(A_Index - 1, this.Type.id))
        }

        ; TODO: Initialize macro buttons, recorder, vban, command, fx, option, patch

        this.UpdateDevices()
        VMRAudioIO.IS_CLASS_INIT := true
    }

    /**
     * @private - Internal method
     * @description Updates the levels of all buses/strips.
     */
    _UpdateLevels() {
        local bus, strip
        for (bus in this.Bus) {
            bus._UpdateLevels()
        }

        for (strip in this.Strip) {
            strip._UpdateLevels()
        }

        this._DispatchEvent(VMRConsts.Events.LevelsUpdated)
    }

    /**
     * @private - Internal method
     * @description Prepares the VMR instance for deletion (turns off timers, etc..) and logs out of Voicemeeter.
     */
    __Delete(*) {
        if (!this.Type)
            return
        this.Type := ""
        this.Bus := ""
        this.Strip := ""

        if (this._syncTimer)
            SetTimer(this._syncTimer, 0)

        if (this._levelsTimer)
            SetTimer(this._levelsTimer, 0)

        if (this._updateDevicesCallback)
            OnMessage(VMRConsts.WM_DEVICE_CHANGE, this._updateDevicesCallback)

        while (this.Sync()) {
        }

        ; Make sure all commands finish executing before logging out
        Sleep(100)
        VBVMR.Logout()
    }
}
