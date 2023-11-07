#Requires AutoHotkey >=2.0

class VMRUtils {
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
        local min_s := 10 ** (-60 / 20), max_s := 10 ** (0 / 20)
        local percentage := ((10 ** (p_dB / 20)) - min_s) / (max_s - min_s)
        return percentage < 0 ? 0 : percentage
    }

    static PercentageToDb(p_percentage) {
        if (p_percentage < 0)
            p_percentage := 0
        local min_s := 10 ** (-60 / 20), max_s := 10 ** (0 / 20)
        return 20 * Log(min_s + p_percentage / (max_s - min_s))
    }

    static EnsureBetween(p_value, p_min, p_max) => Max(p_min, Min(p_max, p_value))
}
