#Requires AutoHotkey >=2.0

class VMRUtils {
    static IndexOf(p_array, p_value) {
        if !(p_array is Array)
            throw Error("p_array is not a valid array")

        for (i, value in p_array) {
            if (value == p_value)
                return i
        }

        return -1
    }

    static DbToPercentage(p_dB) {
        min_s := 10 ** (-60 / 20), max_s := 10 ** (0 / 20)
        return Format("{:.2f}", ((10 ** (p_dB / 20)) - min_s) / (max_s - min_s) * 100)
    }

    static PercentageToDb(p_percentage) {
        min_s := 10 ** (-60 / 20), max_s := 10 ** (0 / 20)
        return Format("{:.1f}", 20 * Log(min_s + p_percentage / 100 * (max_s - min_s)))
    }

    static EnsureBetween(p_value, p_min, p_max) => Max(p_min, Min(p_max, p_value))
}