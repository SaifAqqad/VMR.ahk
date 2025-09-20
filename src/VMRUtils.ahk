#Requires AutoHotkey >=2.0

class VMRUtils {
    static _MIN_PERCENTAGE := 0.001
    static _MAX_PERCENTAGE := 1.0

    /**
     * Converts a dB value to a percentage value.
     * 
     * @param {Number} p_dB The dB value to convert.
     * __________
     * @returns {Number} The percentage value.
     */
    static DbToPercentage(p_dB) {
        local value := ((10 ** (p_dB / 20)) - VMRUtils._MIN_PERCENTAGE) / (VMRUtils._MAX_PERCENTAGE - VMRUtils._MIN_PERCENTAGE)
        return value < 0 ? 0 : Round(value * 100)
    }

    /**
     * Converts a percentage value to a dB value.
     * 
     * @param {Number} p_percentage The percentage value to convert.
     * __________
     * @returns {Number} The dB value.
     */
    static PercentageToDb(p_percentage) {
        if (p_percentage < 0)
            p_percentage := 0
        local value := 20 * Log(VMRUtils._MIN_PERCENTAGE + p_percentage / 100 * (VMRUtils._MAX_PERCENTAGE - VMRUtils._MIN_PERCENTAGE))
        return Round(value, 2)
    }

    /**
     * Applies an upper and a lower bound on a passed value.
     * 
     * @param {Number} p_value The value to apply the bounds on.
     * @param {Number} p_min The lower bound.
     * @param {Number} p_max The upper bound.
     * __________
     * @returns {Number} The value with the bounds applied.
     */
    static EnsureBetween(p_value, p_min, p_max) => Round(Max(p_min, Min(p_max, p_value)), 2) + 0

    /**
     * Returns the index of the first occurrence of a value in an array, or -1 if it's not found.
     * 
     * @param {Array} p_array The array to search in.
     * @param {Any} p_value The value to search for.
     * __________
     * @returns {Number} The index of the first occurrence of the value in the array, or -1 if it's not found.
     */
    static IndexOf(p_array, p_value) {
        local i, value

        if !(p_array is Array)
            throw Error("p_array: Expected an Array, got " Type(p_array))

        for (i, value in p_array) {
            if (value = p_value)
                return i
        }

        return -1
    }

    /**
     * Returns a string with the passed parameters joined using the passed seperator.
     * 
     * @param {Array} p_params - The parameters to join.
     * @param {String} p_seperator - The seperator to use.
     * @param {Number} p_maxLength - The maximum length of each parameter.
     * __________
     * @returns {String} The joined string.
     */
    static Join(p_params, p_seperator, p_maxLength := 30) {
        local str := ""
        for (param in p_params) {
            str .= SubStr(VMRUtils.ToString(param), 1, p_maxLength) . p_seperator
        }
        return SubStr(str, 1, -StrLen(p_seperator))
    }

    /**
     * Converts a value to a string.
     * 
     * @param {Any} p_value The value to convert to a string.
     * _________
     * @returns {String} The string representation of the passed value
     */
    static ToString(p_value) {
        if (p_value is String)
            return p_value
        else if (p_value is Array)
            return "[" . VMRUtils.Join(p_value, ", ") . "]"
        else if (IsObject(p_value))
            return p_value.ToString ? p_value.ToString() : Type(p_value)
        else
            return String(p_value)
    }
}
