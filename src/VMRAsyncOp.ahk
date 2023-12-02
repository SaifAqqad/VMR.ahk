#Requires AutoHotkey >=2.0
#Include VMRError.ahk

/**
 * A basic wrapper for an async operation.
 */
class VMRAsyncOp {

    /**
     * Creates a new async operation.
     * 
     * @param {() => Any} p_supplier - (Optional) Supplies the result of the async operation.
     * @param {Number} p_autoResolveTimeout - (Optional) Automatically resolves the async operation after the specified number of milliseconds.
     */
    __New(p_supplier?, p_autoResolveTimeout?) {
        if (IsSet(p_supplier)) {
            if !(p_supplier is Func)
                throw VMRError("p_supplier must be a function.", this.__New.Name, p_supplier)

            this._supplier := p_supplier
        }

        this._value := ""
        this._listeners := []

        this.IsEmpty := false
        this.Resolved := false

        if (IsSet(p_autoResolveTimeout) && IsNumber(p_autoResolveTimeout)) {
            if (p_autoResolveTimeout = 0)
                this._Resolve()
            else
                SetTimer(this._Resolve.Bind(this), -Abs(p_autoResolveTimeout))
        }
    }

    /**
     * Creates an empty async operation that's already been resolved.
     */
    static Empty {
        get {
            local empty := VMRAsyncOp()
            empty.IsEmpty := true
            empty._Resolve()
            return empty
        }
    }

    /**
     * Adds a listener to the async operation.
     * 
     * @param {(Any) => Any} p_listener - A function that will be called when the async operation is resolved.
     * __________
     * @returns {VMRAsyncOp} - a new async operation that will be resolved when the current operation is resolved and the listener is called.
     * @throws {VMRError} - if `p_listener` is not a function or has an invalid number of parameters.
     */
    Then(p_listener) {
        if !(p_listener is Func)
            throw VMRError("p_listener must be a function.", this.Then.Name, p_listener)

        if (p_listener.MinParams > 1)
            throw VMRError("p_listener must require 0 or 1 parameters.", this.Then.Name, p_listener)

        if (this.Resolved) {
            local result := this._SafeCall(p_listener)
            return VMRAsyncOp(() => result, 0)
        }
        else {
            local innerOp := VMRAsyncOp(p_listener)
            this._listeners.push(innerOp._Resolve.Bind(innerOp))
            return innerOp
        }
    }

    /**
     * Waits for the async operation to be resolved.
     * 
     * @param {Number} p_timeoutMs - (Optional) The maximum number of milliseconds to wait before throwing an error.
     * __________
     * @returns {Any} - The result of the async operation.
     */
    Await(p_timeoutMs := 0) {
        if (this.Resolved)
            return this._value

        currentMs := A_TickCount

        while (!this.Resolved) {
            if (p_timeoutMs > 0 && A_TickCount - currentMs > p_timeoutMs)
                throw VMRError("The async operation timed out", this.Await.Name, p_timeoutMs)
            Sleep(50)
        }

        return this._value
    }

    /**
     * Resolves the async operation.
     */
    _Resolve() {
        if (this.Resolved)
            throw VMRError("This async operation has already been resolved.", this._Resolve.Name)

        if (this._supplier is Func)
            this._value := this._supplier.Call()

        ; If the supplier returned another async operation, resolve to the actual value.
        if (this._value is VMRAsyncOp)
            this._value := this._value.Await()

        this.Resolved := true
        for (listener in this._listeners) {
            this._SafeCall(listener)
        }
    }

    /**
     * Calls the listener with the appropriate number of parameters and catches any thrown errors.
     * 
     * @param {Func} p_listener - A function that will be called when the async operation is resolved.
     * __________
     * @returns {Any} - The result of the listener call.
     */
    _SafeCall(p_listener) {
        try {
            if (p_listener.MaxParams = 0) {
                return p_listener.Call()
            }
            else if (p_listener.MinParams < 2) {
                return p_listener.Call(this._value)
            }
        }
    }
}
