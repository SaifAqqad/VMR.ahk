#Requires AutoHotkey v2.0

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
}