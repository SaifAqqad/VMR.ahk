<h1 align="center">
VMR.ahk
</h1>
<p align="center">
  AutoHotkey wrapper class for Voicemeeter Remote API.
</p>

## Getting Started

To use `VMR.ahk` in your script, follow one of the following methods:

### A - ahkpm installation

1. Install and set up [ahkpm](https://github.com/joshuacc/ahkpm), then run `ahkpm install gh:SaifAqqad/VMR.ahk`
2. Run `ahkpm include gh:SaifAqqad/VMR.ahk -f my-script.ahk` to add an include directive in your script
   ###### Replace *my-script.ahk* with your script's path

### B - Manual Installation

1. Download the latest pre-built version from the [`dist` folder](https://raw.githubusercontent.com/SaifAqqad/VMR.ahk/master/dist/VMR.ahk) or follow the build instructions below
2. Include it using `#Include VMR.ahk` or copy it to a [library folder](https://www.autohotkey.com/docs/v2/Scripts.htm#lib) and use `#Include <VMR>`

**Note: The current version of VMR only works with AHK v2, The AHK v1 version is available on the [v1 branch](https://github.com/SaifAqqad/VMR.ahk/tree/v1)**

## Usage

- Create an instance of the VMR class and log in to the API:
  ```ahk
  voicemeeter := VMR().login()
  ```
- The `VMR` object will have two arrays (`Bus` and `Strip`), as well as other objects, that will allow you to control voicemeeter in AHK.
  ```ahk
  voicemeeter.Bus[1].mute := true
  voicemeeter.Strip[4].gain++
  ```

  ##### For more info, check out the [documentation](https://saifaqqad.github.io/VMR.ahk/)

## Build instructions

To build `VMR.ahk`, either run the vscode task `Build VMR` or run the build script manually:

```powershell
Autohotkey.exe ".\Build.ahk" ".\VMR.ahk" "..\dist\VMR.ahk" "<version number>"
```
