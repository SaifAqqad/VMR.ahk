#Include, VMR.ahk

voicemeeter := new VMR()
voicemeeter.login()

loop % voicemeeter.bus.Length() {
    voicemeeter.bus[A_Index].setGain(0) ; set gain to 0 for all busses at startup
}

Volume_Up::voicemeeter.bus[1].incGain() ;bind volume up key to increase bus[1] gain
Volume_Down::voicemeeter.bus[1].decGain()

^M::voicemeeter.bus[1].toggleMute() ; bind ctrl+M to toggle mute bus[1]

^Volume_Up::voicemeeter.strip[5].incGain()
^Volume_Down::voicemeeter.strip[5].decGain()

F6::voicemeeter.bus[1].setDevice("LG") ; set bus[1] to the first device with "LG" in its name
F7::voicemeeter.strip[2].setDevice("amazonbasics", "mme")

^G::
MsgBox, % "bus[1] gain:" . voicemeeter.bus[1].getGain() . " dB"
MsgBox, % "bus[1] gain percentage:" . voicemeeter.bus[1].getGainPercentage() . "%"
MsgBox, % "bus[1] " . (voicemeeter.bus[1].getMute() ? "Muted" : "Unmuted")
return

^Y::voicemeeter.command.show()

^K::voicemeeter.bus[1].setParameter("FadeTo", "(6.0, 2000)") ;set specific parameter for a bus/strip

^T::MsgBox, % voicemeeter.bus[1].level[1]

!r::
voicemeeter.recorder.armStrips(1,5,3)
voicemeeter.recorder.record(1)
return

!s::
voicemeeter.recorder.stop(1)
voicemeeter.command.eject(1)
return
