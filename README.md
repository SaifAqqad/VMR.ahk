<h1 align="center">
VMR.ahk
</h1>
<p align="center">
  AutoHotkey wrapper class for Voicemeeter Remote API.
</p>

## Getting Started

To use `VMR.ahk` in your script, follow one of the following methods:

### A. ahkpm installation

1. Install and set up [ahkpm](https://github.com/joshuacc/ahkpm)
2. Run `ahkpm install gh:SaifAqqad/VMR.ahk`
3. Include VMR in your script by running `ahkpm include gh:SaifAqqad/VMR.ahk -f myScript.ahk`
    ###### Replace *myScript.ahk* with your script's path

### B. Manual Installation

1. Download the latest pre-built version from the [`dist` folder](https://raw.githubusercontent.com/SaifAqqad/VMR.ahk/master/dist/VMR.ahk) / [latest release](https://github.com/SaifAqqad/VMR.ahk/releases) or follow the build instructions below
2. Include it using `#Include VMR.ahk` or copy it to a [library folder](https://www.autohotkey.com/docs/v2/Scripts.htm#lib) and use `#Include <VMR>`

> [!IMPORTANT]
> The current version of VMR ***only*** supports AHK v2, The AHK v1 version is still available on the [v1 branch](https://github.com/SaifAqqad/VMR.ahk/tree/v1) but will (probably) not receive any updates.

## Basic usage
- Create an instance of the `VMR` class and log in to the API:
  ```ahk
  voicemeeter := VMR().Login()
  ```
- The `VMR` instance will have two arrays (`Bus` and `Strip`), as well as other properties/methods that will allow you to control voicemeeter in AHK
  ```ahk
  voicemeeter.Bus[1].mute := true
  voicemeeter.Strip[4].gain++
  ```
  ##### For more info, check out the [documentation](https://saifaqqad.github.io/VMR.ahk/) and the [examples](./examples/)

## Build instructions

To build `VMR.ahk`, either run the vscode task `Build VMR` or run the build script using ahkpm or manually:

```powershell
# ahkpm
ahkpm run build
# Manually
Autohotkey.exe ".\Build.ahk" ".\VMR.ahk" "..\dist\VMR.ahk" "<version number>"
```
