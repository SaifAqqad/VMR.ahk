#Requires AutoHotkey >=2.0

class VMRConsts {
    /**
     * Events fired by the {@link VMR|`VMR`} object.  
     * Use {@link @VMR.On|`VMR.On`} to register event listeners.
     * 
     * @event `ParametersChanged` - Called when bus/strip parameters change
     * @event `LevelsUpdated` - Called when the {@link @VMRAudioIO.Level|`Level`} arrays for bus/strips are updated
     * @event `DevicesUpdated` - Called when the list of available devices is updated
     * @event `MacroButtonsChanged` - Called when macro-buttons's states change
     * @event `MidiMessage` - Called when a midi message is received  
     * - The `MidiMessage` callback will be passed an array with the hex-formatted bytes of the message
     */
    static Events := {
        ParametersChanged: "ParametersChanged",
        LevelsUpdated: "LevelsUpdated",
        DevicesUpdated: "DevicesUpdated",
        MacroButtonsChanged: "MacroButtonsChanged",
        MidiMessage: "MidiMessage"
    }

    /**
     * Known Voicemeeter types
     * @type {Array} - Array of voiceemeeter type descriptors
     * __________
     * @typedef {{id, name, executable, busCount, stripCount, vbanCount}} VoicemeeterType
     */
    static VOICEMEETER_TYPES := [{
        id: 1,
        name: "Voicemeeter",
        executable: "Voicemeeter.exe",
        busCount: 2,
        vbanCount: 4,
        stripCount: 3
    }, {
        id: 2,
        name: "Voicemeeter Banana",
        executable: "voicemeeterpro.exe",
        busCount: 5,
        vbanCount: 8,
        stripCount: 5
    }, {
        id: 3,
        name: "Voicemeeter Potato",
        executable: Format("voicemeeter8{}.exe", A_Is64bitOS ? "x64" : ""),
        busCount: 8,
        vbanCount: 8,
        stripCount: 8
    }]

    /**
     * Default names for Voicemeeter buses
     * @type {Array}
     */
    static BUS_NAMES := [
        ; Voicemeeter
        ["A", "B"],
        ; Voicemeeter Banana
        ["A1", "A2", "A3", "B1", "B2"],
        ; Voicemeeter Potato
        ["A1", "A2", "A3", "A4", "A5", "B1", "B2", "B3"]
    ]

    static STRIP_NAMES := [
        ; Voicemeeter
        ["Input #1", "Input #2", "Virtual Input #1"],
        ; Voicemeeter Banana
        ["Input #1", "Input #2", "Input #3", "Virtual Input #1", "Virtual Input #2"],
        ; Voicemeeter Potato
        ["Input #1", "Input #2", "Input #3", "Input #4", "Input #5", "Virtual Input #1", "Virtual Input #2", "Virtual Input #3"]
    ]

    /**
     * Known string parameters for {@link VMRAudioIO|`VMRAudioIO`} 
     * @type {Array}
     */
    static IO_STRING_PARAMETERS := [
        "Device",
        "Device.name",
        "Device.wdm",
        "Device.mme",
        "Device.ks",
        "Device.asio",
        "Label",
        "FadeTo",
        "FadeBy",
        "AppGain",
        "AppMute"
    ]

    /**
     * Known device drivers
     * @type {Array}
     */
    static DEVICE_DRIVERS := ["wdm", "mme", "asio", "ks"]

    /**
     * Default device driver, used when setting a device without specifying a driver
     * @type {String}
     */
    static DEFAULT_DEVICE_DRIVER := "wdm"

    static REGISTRY_KEY := Format("HKLM\Software{}\Microsoft\Windows\CurrentVersion\Uninstall\VB:Voicemeeter {17359A74-1236-5467}", A_Is64bitOS ? "\WOW6432Node" : "")

    static DLL_FILE := A_PtrSize == 8 ? "VoicemeeterRemote64.dll" : "VoicemeeterRemote.dll"

    static WM_DEVICE_CHANGE := 0x0219, WM_DEVICE_CHANGE_PARAM := 0x0007

    static SYNC_TIMER_INTERVAL := 10, LEVELS_TIMER_INTERVAL := 30
}
