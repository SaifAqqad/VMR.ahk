#Requires AutoHotkey >=2.0

#Include VMRError.ahk

/**
 * A basic wrapper for an async operation.
 * 
 * This is needed because the VMR API is asynchronous which means that operations like `SetFloatParameter` do not take effect immediately,
 * and so if the same parameter was fetched right after it was set, the old value would be returned (or sometimes it would return a completely invalid value).
 * 
 * And unfortunately, the VMR API does not provide any meaningful way to wait for a particular operation to complete (callbacks, synchronous api), and so this class uses a normal timer to wait for the operation to complete.
 */
class VMRAsyncOp {
    static DEFAULT_DELAY := 50

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
     * @param {Number} p_innerOpDelay - (Optional) If passed, the returned async operation will be delayed by the specified number of milliseconds.
     * __________
     * @returns {VMRAsyncOp} - a new async operation that will be resolved when the current operation is resolved and the listener is called.
     * @throws {VMRError} - if `p_listener` is not a function or has an invalid number of parameters.
     */
    Then(p_listener, p_innerOpDelay := 0) {
        if !(p_listener is Func)
            throw VMRError("p_listener must be a function.", this.Then.Name, p_listener)

        if (p_listener.MinParams > 1)
            throw VMRError("p_listener must require 0 or 1 parameters.", this.Then.Name, p_listener)

        if (this.Resolved) {
            local result := this._SafeCall(p_listener)
            return VMRAsyncOp(() => result, p_innerOpDelay)
        }
        else {
            local innerOp := VMRAsyncOp()
            this._listeners.push({ func: p_listener, op: innerOp, delay: Abs(p_innerOpDelay) })
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

        local currentMs := A_TickCount

        while (!this.Resolved) {
            if (p_timeoutMs > 0 && A_TickCount - currentMs > p_timeoutMs)
                throw VMRError("The async operation timed out", this.Await.Name, p_timeoutMs)
            Sleep(VMRAsyncOp.DEFAULT_DELAY)
        }

        return this._value
    }

    /**
     * Resolves the async operation.
     * 
     * @param {Any} p_value - (Optional) A value to resolve the async operation with, this will take precedence over the supplier.
     */
    _Resolve(p_value?) {
        if (this.Resolved)
            throw VMRError("This async operation has already been resolved.", this._Resolve.Name)

        if (IsSet(p_value))
            this._value := p_value
        else if (this._supplier is Func)
            this._value := this._supplier.Call()

        ; If the supplier returned another async operation, resolve to the actual value.
        if (this._value is VMRAsyncOp)
            this._value := this._value.Await()

        this.Resolved := true
        for (listener in this._listeners) {
            local value := this._SafeCall(listener.func)
                , delay := listener.delay > 0 ? listener.delay : VMRAsyncOp.DEFAULT_DELAY
            SetTimer(listener.op._Resolve.Bind(listener.op, value), -delay)
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
