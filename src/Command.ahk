; These are read-only commands
class Command {

    restart(){
        return VBVMR.SetParameterFloat("Command","Restart",1)
    }

    shutdown(){
        return VBVMR.SetParameterFloat("Command","Shutdown",1)
    }

    show(open := 1){
        return VBVMR.SetParameterFloat("Command","Show",open)
    }

    lock(state := 1){
        return VBVMR.SetParameterFloat("Command","Lock",state)
    }

    eject(){
        return VBVMR.SetParameterFloat("Command","Eject",1)
    }

    reset(){
        return VBVMR.SetParameterFloat("Command","Reset",1)
    }

    save(filePath){
        return VBVMR.SetParameterString("Command","Save",filePath)
    }

    load(filePath){
        return VBVMR.SetParameterString("Command","Load",filePath)
    }

    showVBANChat(show := 1) {
        return VBVMR.SetParameterFloat("Command","dialogshow.VBANCHAT",show)
    }

    state(buttonNum, newState) {
        return VBVMR.SetParameterFloat("Command.Button[" . buttonNum . "]", "State", newState)
    }

    stateOnly(buttonNum, newState) {
        return VBVMR.SetParameterFloat("Command.Button[" . buttonNum . "]", "stateOnly", newState)
    }

    trigger(buttonNum, newState) {
        return VBVMR.SetParameterFloat("Command.Button[" . buttonNum . "]", "trigger", newState)
    }

    saveBusEQ(busIndex, filePath) {
        return VBVMR.SetParameterFloat("Command","SaveBUSEQ[" busIndex "]", filePath)
    }

    loadBusEQ(busIndex, filePath) {
        return VBVMR.SetParameterFloat("Command","LoadBUSEQ[" busIndex "]", filePath)
    }
}