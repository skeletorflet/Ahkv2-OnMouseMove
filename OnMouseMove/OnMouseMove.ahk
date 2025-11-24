#Requires AutoHotkey v2.0
Persistent

global __mouseHook := 0
global __mouseProc := 0
global __lastX := 0
global __lastY := 0
global __callback := 0

OnExit(__UnhookMouse)

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

obtenerUltimoXY() {
    global __lastX, __lastY
    return [__lastX, __lastY]
}

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
    ToolTip()
}