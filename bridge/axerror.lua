return {
  [0] = 'kAXErrorSuccess',-- /*! No error occurred. */
  [-25200] = 'kAXErrorFailure',-- /*! A system error occurred,  such as the failure to allocate an object. */
  [-25201] = 'kAXErrorIllegalArgument', --  /*! An illegal argument was passed to the function. */
  [-25202] = 'kAXErrorInvalidUIElement', -- /*! The AXUIElementRef passed to the function is invalid. */
  [-25203] = 'kAXErrorInvalidUIElementObserver', -- /*! The AXObserverRef passed to the function is not a valid observer.   */
  [-25204] = 'kAXErrorCannotComplete', --   /*! The function cannot complete because messaging failed in some way or because the application with which the function is communicating is busy or unresponsive.   */
  [-25205] = 'kAXErrorAttributeUnsupported',--   /*! The attribute is not supported by the AXUIElementRef. */
  [-25206] = 'kAXErrorActionUnsupported',--   /*! The action is not supported by the AXUIElementRef. */
  [-25207] = 'kAXErrorNotificationUnsupported',--   /*! The notification is not supported by the AXUIElementRef.   */
  [-25208] = 'kAXErrorNotImplemented', --   /*! Indicates that the function or method is not implemented (this can be returned if a process does not support the accessibility API ).   */
  [-25209] = 'kAXErrorNotificationAlreadyRegistered',--  /*! This notification has already been registered for. */
  [-25210] = 'kAXErrorNotificationNotRegistered', --   /*! Indicates that a notification is not registered yet. */
  [-25211] = 'kAXErrorAPIDisabled', --   /*! The accessibility API is disabled (as when,   for example,   the user deselects "Enable access for assistive devices" in Universal Access Preferences ).   */
  [-25212] = 'kAXErrorNoValue', --  /*! The requested value or AXUIElementRef does not exist. */
  [-25213] = 'kAXErrorParameterizedAttributeUnsupported', --   /*! The parameterized attribute is not supported by the AXUIElementRef.   */
  [-25214] = 'kAXErrorNotEnoughPrecision',--   /*! Not enough precision. */
}
