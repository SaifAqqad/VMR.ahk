#Requires AutoHotkey >=2.0
#Include VMRUtils.ahk

class VMRDevice {
    __New(name, driver, hwid) {
        this.Name := name
        this.Hwid := hwid

        if (IsNumber(driver)) {
            switch driver {
                case 3:
                    driver := "wdm"
                case 4:
                    driver := "ks"
                case 5:
                    driver := "asio"
                default:
                    driver := "mme"
            }
        }
        this.Driver := driver
    }

    ToString() {
        return this.name
    }
}