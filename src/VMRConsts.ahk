class VMRConsts {
    static REGISTRY_KEY := Format("HKLM\Software{}\Microsoft\Windows\CurrentVersion\Uninstall\VB:Voicemeeter {17359A74-1236-5467}", A_Is64bitOS ? "\WOW6432Node" : "")

    static VOICEMEETER_TYPES := [{
        id: 1,
        name: "Voicemeeter",
        executable: "Voicemeeter.exe"
    }, {
        id: 2,
        name: "Voicemeeter Banana",
        executable: "voicemeeterpro.exe"
    }, {
        id: 3,
        name: "Voicemeeter Potato",
        executable: Format("voicemeeter8{}.exe", A_Is64bitOS ? "x64" : "")
    }]

    static BUS_NAMES := [
        ["A", "B"],
        ["A1", "A2", "A3", "B1", "B2"],
        ["A1", "A2", "A3", "A4", "A5", "B1", "B2", "B3"]
    ]

    static STRIP_NAMES := [
        ["Input #1", "Input #2", "Virtual Input #1"],
        ["Input #1", "Input #2", "Input #3", "Virtual Input #1", "Virtual Input #2"],
        ["Input #1", "Input #2", "Input #3", "Input #4", "Input #5", "Virtual Input #1", "Virtual Input #2", "Virtual Input #3"]
    ]
    
    /**
     * #### Events fired by the VMR object
     * 
     * Use `VMR.On()` to register event listeners.
     * 
     * - `ParametersChanged` - Called when bus/strip parameters change
     * - `LevelsUpdated` - Called when the `level` arrays for buses/strips are updated
     * - `MacroButtonsChanged` - Called when macro-buttons's states change
     * - `MidiMessage` - Called when a midi message is received
     */
    static Events := {
        ParametersChanged: "ParametersChanged",
        LevelsUpdated: "LevelsUpdated",
        MacroButtonsChanged: "MacroButtonsChanged",
        MidiMessage: "MidiMessage"
    }
}