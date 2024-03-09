# `VMRAsyncOp`  <!-- {docsify-ignore-all} -->

  A basic wrapper for an async operation.
  
  This is needed because the VMR API is asynchronous which means that operations like `SetFloatParameter` do not take effect immediately,
  and so if the same parameter was fetched right after it was set, the old value would be returned (or sometimes it would return a completely invalid value).
  
  And unfortunately, the VMR API does not provide any meaningful way to wait for a particular operation to complete (callbacks, synchronous api), and so this class uses a normal timer to wait for the operation to complete.
## Constructor `__New(p_supplier := unset, p_autoResolveTimeout := unset)` :id=constructor
  Creates a new async operation.

  **Parameters**:
  - **Optional** `p_supplier` : `() => Any` - Supplies the result of the async operation.

  - **Optional** `p_autoResolveTimeout` : `Number` - Automatically resolves the async operation after the specified number of milliseconds.


## Properties
* #### **Static** `Empty` : `VMRAsyncOp` :id=static-empty
  Returns an empty async operation that's already been resolved.
* #### **Static** `DEFAULT_DELAY` : `Number` :id=static-default_delay
  The default delay that's used when awaiting the async operation.
* #### `IsEmpty` : `Boolean` :id=isempty
  Whether the operation is an empty operation returned by `VMRAsyncOp.Empty`.
* #### `Resolved` : `Boolean` :id=resolved
  Whether the operation has already been resolved.

## Methods
* ### `Then(p_listener, p_innerOpDelay := 0)` :id=then
  Adds a listener to the async operation.

  **Parameters**:
  - `p_listener` : `(Any) => Any` - A function that will be called when the async operation is resolved.

  - **Optional** `p_innerOpDelay` : `Number` - If passed, the returned async operation will be delayed by the specified number of milliseconds.

  **Throws**:
  - [`VMRError`](/classes/vmrerror) - if `p_listener` is not a function or has an invalid number of parameters.

  **Returns**: [`VMRAsyncOp`](/classes/vmrasyncop) - a new async operation that will be resolved when the current operation is resolved and the listener is called.


______
* ### `Await(p_timeoutMs := 0)` :id=await
  Waits for the async operation to be resolved.

  **Parameters**:
  - **Optional** `p_timeoutMs` : `Number` - The maximum number of milliseconds to wait before throwing an error.

  **Returns**: `Any` - The result of the async operation.