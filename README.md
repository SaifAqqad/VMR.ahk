<h1 align="center">
VMR.ahk
</h1>
<p align="center">
  AutoHotkey wrapper class for Voicemeeter Remote API.
</p>

## Getting Started
To use `VMR.ahk` in your script, follow these steps:
1.  Include it using `#Include VMR.ahk` or copy it to a [library folder](https://www.autohotkey.com/docs/Functions.htm#lib) and use `#Include <VMR>`

2.  create an object of the VMR class and login like so:
    ```ahk
        voicemeeter:= new VMR().login()
    ```
3. The `VMR` object will have two arrays (`bus` and`strip`), as well as other objects, that will allow you to control voicemeeter in AHK.
    ```ahk
        voicemeeter.bus[1].mute:= true
        voicemeeter.strip[4].gain++
    ```

##### For more info, check out the [documentation](https://saifaqqad.github.io/VMR.ahk/)
