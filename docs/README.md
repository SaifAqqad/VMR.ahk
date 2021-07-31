
##  Getting started <!-- {docsify-ignore} -->
To use `VMR.ahk` in your script, follow these steps:
1.  Include it using `#Include VMR.ahk` or copy it to a [library folder](https://www.autohotkey.com/docs/Functions.htm#lib) and use `#Include <VMR>`

2.  create an instance of the VMR class and log in to the API:
    ```autohotkey
        voicemeeter := new VMR().login()
    ```
    you can optionally pass the path to voicemeeter's folder:
    ```autohotkey
        voicemeeter := new VMR("C:\path\to\voicemeeter\").login()
    ```
3. The `VMR` object will have two arrays, `bus` and`strip`, as well as other objects, that will allow you to control voicemeeter in AHK.
    ```autohotkey
        voicemeeter.bus[1].mute := true
        voicemeeter.strip[4].gain++
    ```
<sub>This documentation is for VMR.ahk, If you need help with the Voicemeeter API check out [their documentation](http://download.vb-audio.com/Download_CABLE/VoicemeeterRemoteAPI.pdf)</sub>
