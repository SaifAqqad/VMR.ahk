#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\dist\VMR.ahk

voicemeeter := VMR().Login()

ui := Gui("-Resize", "Voicemeeter Remote UI")
ui.OnEvent("Close", (*) => ExitApp())
ui.SetFont(, "Segoe UI")

title := ui.Add("Text", "w500 r2", voicemeeter.Type.Name " v" voicemeeter.version)
title.SetFont("s16 bold Q5")
title.GetPos(, &initialYPos)

; Add strip UI controls
xPos := 10
initialYPos += 50
for i, strip in voicemeeter.Strip {
    AddControls(strip, xPos, initialYPos)
    xPos += 150
}

; Add bus UI controls
xPos := 10
initialYPos += 350
for i, bus in voicemeeter.Bus {
    AddControls(bus, xPos, initialYPos)
    xPos += 150
}

ui.Show("AutoSize")

/**
 * Adds the controls for a given VMRAudioIO object
 * 
 * @param {VMRAudioIO} vmObj
 * @param {Number} xPos
 * @param {Number} yPos
 */
AddControls(vmObj, xPos, yPos) {
    ; Title
    objTitle := ui.Add("Text", "x" xPos " y" yPos " w100", vmObj.Id "`n" vmObj.Name)

    ; Level Indicator
    yPos += 30
    objLevel := ui.Add("Progress", "x" xPos " y" yPos " w20 h200 Range-72-20 c0x70C399 Background0x2C3D4D vertical")
    voicemeeter.On("levelsUpdated", (*) => objLevel.Value := Max(vmObj.Level*))

    ; Gain Controls
    yPos += 220
    objGain := ui.Add("Edit", "x" xPos " y" yPos " w50 ReadOnly")
    objUpDn := ui.Add("UpDown", "x" xPos " y" yPos " Range-60-12")
    objGain.OnEvent("Change", (*) => vmObj.Gain := Number(objGain.Value))
    objGain.Value := vmObj.Gain

    ; Mute Controls
    yPos += 30
    objMute := ui.Add("CheckBox", "x" xPos " y" yPos, "Mute")
    objMute.Value := vmObj.Mute
    objMute.OnEvent("Click", (*) => vmObj.Mute := objMute.Value)

    ; Bind voicemeeter changes to the UI
    onChanges(*) {
        objGain.Value := vmObj.Gain
        objMute.Value := vmObj.Mute
    }
    voicemeeter.On("parametersChanged", onChanges)

    ; Device selector (only for physical strips and buses)
    if (vmObj.IsPhysical()) {
        yPos += 30
        deviceDdl := ui.AddDropDownList("x" xPos " y" yPos " w130", [])
        deviceDdl.OnEvent("Change", (*) => vmObj.Device := GetDeviceByDisplayName(deviceDdl.Text))

        ; Bind voicemeeter changes to the UI
        voicemeeter.On(VMRConsts.Events.DevicesUpdated, (*) => RefreshDevices(deviceDdl, vmObj))
        voicemeeter.On(VMRConsts.Events.ParametersChanged, (*) => SetTimer(() => deviceDdl.Choose(GetDeviceDisplayName(vmObj.Device)), -1000))

        RefreshDevices(deviceDdl, vmObj)
    }
}

/**
 * Refreshes the devices in the dropdown list
 * @param {Gui.DDL} ddl
 * @param {VMRAudioIO} ioObj
 */
RefreshDevices(ddl, ioObj) {
    global voicemeeter
    local i, device,
        devicesArr := ioObj is VMRStrip ? VMRStrip.Devices : VMRBus.Devices,
        deviceNames := [""] ; Add an empty item to remove the selected device

    for i, device in devicesArr {
        deviceNames.Push(GetDeviceDisplayName(device))
    }

    ddl.Delete()
    ddl.Add(deviceNames)
    local dd := ioObj.Device
    local currentDevice := GetDeviceDisplayName(dd)
    ddl.Choose(currentDevice)
}

/**
 * @param {VMRDevice} device
 * @returns {String} - The display name for the given device
 */
GetDeviceDisplayName(device) {
    if (!device)
        return ""
    return Format("{} - {}", StrUpper(device.driver), device.name)
}

/**
 * @param {String} displayName
 * @returns {VMRDevice} - The device that matches the given display name
 */
GetDeviceByDisplayName(displayName) {
    if (!displayName)
        return ""
    RegExMatch(displayName, "i)(\w+) - (.+)", &match)
    return VMRBus.GetDevice(match[2], match[1]) || VMRStrip.GetDevice(match[2], match[1])
}
