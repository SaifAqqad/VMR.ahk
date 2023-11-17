#Requires AutoHotkey >=2.0

class VMRUtils {
    static _MIN_PERCENTAGE := 0.001
    static _MAX_PERCENTAGE := 1.0

    static IndexOf(p_array, p_value) {
        if !(p_array is Array)
            throw Error("p_array is not a valid array")

        for (i, value in p_array) {
            if (value = p_value)
                return i
        }

        return -1
    }

    static DbToPercentage(p_dB) {
        local value := ((10 ** (p_dB / 20)) - VMRUtils._MIN_PERCENTAGE) / (VMRUtils._MAX_PERCENTAGE - VMRUtils._MIN_PERCENTAGE)
        return value < 0 ? 0 : Round(value * 100)
    }

    static PercentageToDb(p_percentage) {
        if (p_percentage < 0)
            p_percentage := 0
        local value := 20 * Log(VMRUtils._MIN_PERCENTAGE + p_percentage / 100 * (VMRUtils._MAX_PERCENTAGE - VMRUtils._MIN_PERCENTAGE))
        return Round(value, 2) + 0
    }

    static EnsureBetween(p_value, p_min, p_max) => Max(p_min, Min(p_max, p_value))
}
