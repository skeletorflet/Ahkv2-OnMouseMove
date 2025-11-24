/*
OnMouseMove Class (AutoHotkey v2)

Summary
    Encapsulates a global mouse move hook (WH_MOUSE_LL) in a single class.
    Provides a clean API to start/stop the hook and to receive coordinates.

Usage
    #Include src\OnMouseMove.ahk
    OnMouseMove.Start((x, y, prevX, prevY) => MsgBox(Format("Moved to {1},{2} from {3},{4}", x, y, prevX, prevY)))

API
    OnMouseMove.Start(callback)
        Installs the hook (once) and registers/updates the callback.
        The callback is invoked on every mouse move with (x, y, prevX, prevY).

    OnMouseMove.GetLastXY()
        Returns an array [x, y] with the last observed coordinates.

    OnMouseMove.Off()
        Uninstalls the hook and frees resources. Safe to call multiple times.

Lifecycle
    The script is kept alive by the Persistent directive contained in this
    library file. Off() releases hook resources cleanly.
*/

#Requires AutoHotkey v2.0
Persistent

class OnMouseMove {
    static mouseHook := 0
    static mouseProc := 0
    static lastX := 0
    static lastY := 0
    static callbacks := []

    /*
    Starts the global mouse move hook and registers the user callback.
    Parameters
        callback: A callable receiving (x, y, prevX, prevY). Required.
    Returns
        None
    Notes
        Subsequent calls update the callback. The hook is installed once.
    */
    static Start(callback := 0) {
        if (callback)
            OnMouseMove.callbacks.Push(callback)
        if (!OnMouseMove.mouseProc) {
            OnMouseMove.mouseProc := CallbackCreate((nCode, wParam, lParam) => OnMouseMove.__MouseLLProc(nCode, wParam, lParam), "int, UPtr, Ptr")
        }
        if (!OnMouseMove.mouseHook) {
            OnMouseMove.mouseHook := DllCall("user32\SetWindowsHookEx", "int", 14, "ptr", OnMouseMove.mouseProc, "ptr", 0, "uint", 0, "ptr")
            OnExit((*) => OnMouseMove.Off())
        }
        MouseGetPos(&x, &y)
        OnMouseMove.lastX := x
        OnMouseMove.lastY := y
    }

    /*
    Internal low-level mouse hook procedure.
    Invokes the user callback on WM_MOUSEMOVE with current and previous coords.
    */
    static __MouseLLProc(nCode, wParam, lParam) {
        if (nCode >= 0 && wParam == 0x0200) {
            x := NumGet(lParam, 0, "int")
            y := NumGet(lParam, 4, "int")
            prevX := OnMouseMove.lastX
            prevY := OnMouseMove.lastY
            OnMouseMove.lastX := x
            OnMouseMove.lastY := y
            for cb in OnMouseMove.callbacks {
                try cb(x, y, prevX, prevY)
            }
        }
        return DllCall("user32\CallNextHookEx", "ptr", 0, "int", nCode, "UPtr", wParam, "ptr", lParam, "ptr")
    }

    /*
    Returns the last observed mouse coordinates.
    */
    static GetLastXY() {
        return [OnMouseMove.lastX, OnMouseMove.lastY]
    }

    /*
    Removes a previously registered callback.
    */
    static Remove(callback) {
        for i, cb in OnMouseMove.callbacks {
            if (cb = callback) {
                OnMouseMove.callbacks.RemoveAt(i)
                break
            }
        }
    }

    /*
    Uninstalls the mouse hook and frees the callback/resources.
    */
    static Off(*) {
        if (OnMouseMove.mouseHook) {
            DllCall("user32\UnhookWindowsHookEx", "ptr", OnMouseMove.mouseHook)
            OnMouseMove.mouseHook := 0
        }
        if (OnMouseMove.mouseProc) {
            CallbackFree(OnMouseMove.mouseProc)
            OnMouseMove.mouseProc := 0
        }
    }
}
