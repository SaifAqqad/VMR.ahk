#Requires AutoHotkey >=2.0

class VMRDevice {
    __New(name, driver) {
        this.name := name

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
        this.driver := driver
    }
}