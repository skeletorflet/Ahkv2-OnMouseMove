/*
OnMouseMove Library (AutoHotkey v2)

Summary
    Provides a simple API to subscribe a callback to global mouse move events
    using the Windows low-level mouse hook (WH_MOUSE_LL).

Usage
    #Include OnMouseMove\OnMouseMove.ahk
    OnMouseMove((x, y, prevX, prevY) => MsgBox(Format("Moved to {1},{2} from {3},{4}", x, y, prevX, prevY)))

API
    OnMouseMove(callback)
        Registers the callback and installs the hook if not already installed.
        The callback is invoked on every mouse move with (x, y, prevX, prevY).

    obtenerUltimoXY()
        Returns an array [x, y] with the last observed coordinates.

Lifecycle
    The hook is created on first OnMouseMove call and is automatically released
    when the script exits. Callbacks should be lightweight; avoid heavy work in
    the hook thread.
*/

#Requires AutoHotkey v2.0
Persistent

global __mouseHook := 0
global __mouseProc := 0
global __lastX := 0
global __lastY := 0
global __callback := 0

OnExit(__UnhookMouse)

/*
Starts the global mouse move hook and registers the user callback.
Parameters
    callback: A callable receiving (x, y, prevX, prevY). Required.
Returns
    None
Notes
    Subsequent calls update the callback. The hook is installed once.
*/
OnMouseMove(callback) {
    global __mouseHook, __mouseProc, __callback, __lastX, __lastY
    __callback := callback
    if (!__mouseProc) {
        __mouseProc := CallbackCreate(__MouseLLProc, "int, UPtr, Ptr")
    }
    if (!__mouseHook) {
        __mouseHook := DllCall("user32\SetWindowsHookEx", "int", 14, "ptr", __mouseProc, "ptr", 0, "uint", 0, "ptr")
    }
    MouseGetPos &__lastX, &__lastY
}

/*
Internal low-level mouse hook procedure.
Invokes the user callback on WM_MOUSEMOVE with current and previous coords.
*/
__MouseLLProc(nCode, wParam, lParam) {
    global __lastX, __lastY, __callback
    if (nCode >= 0 && wParam == 0x0200) {
        x := NumGet(lParam, 0, "int")
        y := NumGet(lParam, 4, "int")
        prevX := __lastX
        prevY := __lastY
        __lastX := x
        __lastY := y
        if (__callback) {
            try {
                __callback(x, y, prevX, prevY)
            }
        }
    }
    return DllCall("user32\CallNextHookEx", "ptr", 0, "int", nCode, "UPtr", wParam, "ptr", lParam, "ptr")
}

/*
Returns the last observed mouse coordinates.
*/
obtenerUltimoXY() {
    global __lastX, __lastY
    return [__lastX, __lastY]
}

/*
Uninstalls the mouse hook and frees the callback on script exit.
*/
__UnhookMouse(*) {
    global __mouseHook, __mouseProc
    if (__mouseHook) {
        DllCall("user32\UnhookWindowsHookEx", "ptr", __mouseHook)
        __mouseHook := 0
    }
    if (__mouseProc) {
        CallbackFree(__mouseProc)
        __mouseProc := 0
    }
}