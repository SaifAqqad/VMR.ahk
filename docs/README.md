
##  Quick start

To use `VMR.ahk` in your script, follow one of the following methods:

### ahkpm installation

1. Install and set up [ahkpm](https://github.com/joshuacc/ahkpm)
2. Run `ahkpm install gh:SaifAqqad/VMR.ahk`
3. Include VMR in your script by running `ahkpm include gh:SaifAqqad/VMR.ahk -f myScript.ahk`

### Manual Installation

1. Download the latest pre-built version from the [`dist` folder](https://raw.githubusercontent.com/SaifAqqad/VMR.ahk/master/dist/VMR.ahk ':target=_blank') / [latest release](https://github.com/SaifAqqad/VMR.ahk/releases ':target=_blank') or follow the build instructions below
2. Include it using `#Include VMR.ahk` or copy it to a [library folder](https://www.autohotkey.com/docs/v2/Scripts.htm#lib ':target=_blank') and use `#Include <VMR>`

!> The current version of VMR ***only*** supports AHK v2, the AHK v1 version is still available on the [v1 branch](https://github.com/SaifAqqad/VMR.ahk/tree/v1 ':target=_blank'), see [v1 docs](https://vmr-v1.vercel.app/ ':target=_blank').

## Basic usage
- Create an instance of the [`VMR`](./classes/vmr) class and log in to the API:
  ```autohotkey
  voicemeeter := VMR().Login()
  ```
- The [`VMR`](./classes/vmr) instance will have two arrays (`Bus` and `Strip`), as well as other properties/methods that will allow you to control voicemeeter in AHK
  ```autohotkey
  voicemeeter.Bus[1].mute := true
  voicemeeter.Strip[4].gain++
  ```

## Build instructions

To build `VMR.ahk`, either run the vscode task `Build VMR` or run the build script using ahkpm or manually:

```powershell
# ahkpm
ahkpm run build
# Manually
Autohotkey.exe ".\Build.ahk" ".\VMR.ahk" "..\dist\VMR.ahk" "<version number>"
```

<sub>This documentation is for VMR.ahk, If you need help with the Voicemeeter API check out [their documentation](http://download.vb-audio.com/Download_CABLE/VoicemeeterRemoteAPI.pdf ':target=_blank')</sub>
