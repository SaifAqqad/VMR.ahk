## `macroButton` <!-- {docsify-ignore-all} -->

Use this object to access/modify macro buttons status.

### Methods
* #### `setStatus(buttonIndex, newStatus [, bitmode])`
  Set the status of a macro button. 

  `buttonIndex` is zero-based.

  `bitmode` defines what kind of value will be set, it's optional and `0` by default, possible values are:

  - `0` : Actual button's state
  - `2` : Displayed (visual) State only
  - `3` : Trigger state
  ```autohotkey
    ; set macrobutton 0 to on.
    voicemeeter.macroButton.setStatus(0,1)

    ; sets macro button 2 to have trigger on
    voicemeeter.macroButton.setStatus(2,1,3)
  ```

* #### `getStatus(buttonIndex [, bitmode])`
  Retrieve the status of a macro button
  ```autohotkey
    buttonStatus := voicemeeter.macroButton.getStatus(1)
  ```


<sub> See [VBVMR docs](http://download.vb-audio.com/Download_CABLE/VoicemeeterRemoteAPI.pdf#page=8) for more info</sub>