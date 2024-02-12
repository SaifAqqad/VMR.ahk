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
    levelIndicator := ui.Add("Progress", "x" xPos " y" yPos " w20 h200 Range-72-20 c0x70C399 Background0x2C3D4D vertical")
    ; Bind voicemeeter changes to the UI
    voicemeeter.On("levelsUpdated", (*) => levelIndicator.Value := Max(vmObj.Level*))

    ; Gain Controls
    yPos += 220
    gainControl := ui.Add("Edit", "x" xPos " y" yPos " w50 ReadOnly")
    gainUpDn := ui.Add("UpDown", "x" xPos " y" yPos " Range-60-12")
    ; Initial state
    gainUpDn.Value := vmObj.Gain
    ; Bind UI changes to voicemeeter
    gainUpDn.OnEvent("Change", (*) => vmObj.Gain := Number(gainUpDn.Value))
    ; Bind voicemeeter changes to the UI
    voicemeeter.On("ParametersChanged", (*) => gainUpDn.Value := vmObj.Gain)

    ; Mute Controls
    yPos += 30
    objMute := ui.Add("CheckBox", "x" xPos " y" yPos, "Mute")
    ; Initial state
    objMute.Value := vmObj.Mute
    ; Bind UI changes to voicemeeter
    objMute.OnEvent("Click", (*) => vmObj.Mute := objMute.Value)
    ; Bind voicemeeter changes to the UI
    voicemeeter.On("ParametersChanged", (*) => objMute.Value := vmObj.Mute)

    ; Device selector (only for physical strips and buses)
    if (vmObj.IsPhysical()) {
        yPos += 30
        deviceDdl := ui.Add("DropDownList", "x" xPos " y" yPos " w130", [])
        ; Initial state
        RefreshDevices(deviceDdl, vmObj)
        ; Bind UI changes to voicemeeter
        deviceDdl.OnEvent("Change", (*) => vmObj.Device := GetDeviceByDisplayName(deviceDdl.Text))
        ; Bind voicemeeter changes to the UI
        voicemeeter.On("DevicesUpdated", (*) => RefreshDevices(deviceDdl, vmObj))
        ; Delay setting the ddl value to avoid getting the wrong device name
        voicemeeter.On("ParametersChanged", (*) => SetTimer(() => deviceDdl.Choose(GetDeviceDisplayName(vmObj.Device)), -1000))
    }
}

/**
 * Refreshes the devices in the dropdown list
 * @param {Gui.DDL} ddl
 * @param {VMRAudioIO} ioObj
 */
RefreshDevices(ddl, ioObj) {
    local device,
        ; Get the devices array based on the object type
        devicesArr := ioObj is VMRStrip ? VMRStrip.Devices : VMRBus.Devices,
        deviceNames := [""] ; Add an empty item to allow removing the selected device

    ; Get the display name of every device
    for device in devicesArr {
        deviceNames.Push(GetDeviceDisplayName(device))
    }

    ; Replace the items in the dropdown list
    ddl.Delete()
    ddl.Add(deviceNames)

    ; Choose the current selected device
    ddl.Choose(GetDeviceDisplayName(ioObj.Device))
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
