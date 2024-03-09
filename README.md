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
2. Run `ahkpm include -f my-script.ahk gh:SaifAqqad/VMR.ahk` to add an include directive in your script 
    ###### Replace *my-script.ahk* with your script's path

### B - Manual Installation
1.  Download the latest pre-built version from the [`dist` folder](https://raw.githubusercontent.com/SaifAqqad/VMR.ahk/v1/dist/VMR.ahk) or follow the build instructions below

2.  Include it using `#Include VMR.ahk` or copy it to a [library folder](https://www.autohotkey.com/docs/Functions.htm#lib) and use `#Include <VMR>`

3.  Create an instance of the VMR class and log in to the API:
    ```ahk
        voicemeeter:= new VMR().login()
    ```
4. The `VMR` object will have two arrays (`bus` and`strip`), as well as other objects, that will allow you to control voicemeeter in AHK.
    ```ahk
        voicemeeter.bus[1].mute:= true
        voicemeeter.strip[4].gain++
    ```

## Build instructions
To build `VMR.ahk` yourself, run the build script:
```powershell
.\Build.ahk <version number>
```
##### For more info, check out the [documentation](https://vmr-v1.vercel.app/)
