<h1 align="center">
VMR.ahk
</h1>
<p align="center">
  AutoHotkey wrapper class for Voicemeeter Remote API.
</p>

## Getting Started
1.  To use `VMR` in your script, include it using `#Include VMR.ahk` or copy it to a [library folder](https://www.autohotkey.com/docs/Functions.htm#lib) and use `#Include <VMR>`

2.  create an object of the VMR class:
     ```ahk
        voicemeeter := new VMR() 
        ; you can optionally pass the path for voicemeeter's folder -> new VMR("C:\path\to\voicemeeter")
     ```
3.  call the `login()` method:
    ```ahk
        voicemeeter.login()
    ```
4. The `VMR` object will have two arrays, `bus` and `strip`, The length of each array is determined by your Voicemeeter version (VM, VM Banana or VM Potato).
    
    You can control Voicemeeter's bus/strip parameters through these arrays:
    ```ahk
        voicemeeter.bus[1].mute:= true
    ```

##### For more info, check out the [documentation](https://saifaqqad.github.io/VMR.ahk/)