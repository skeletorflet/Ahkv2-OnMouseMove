# OnMouseMove (AutoHotkey v2) 🖱️

Lightweight global mouse-move hook for AutoHotkey v2. Subscribe one or more callbacks and react to every `WM_MOUSEMOVE` event with current and previous coordinates.

## Features ✨
- Simple API: `Start`, `Remove`, `Off`, `GetLastXY`
- Multiple handlers supported (subscribe as many callbacks as you want)
- Pure hook implementation — no timers, no UI
- Works with screen coordinates; you control `CoordMode`

## Installation 🚀
1. Copy `src/OnMouseMove.ahk` into your project.
2. Include the file in your script:

```ahk
#Include src\OnMouseMove.ahk
```

Requirements:
- AutoHotkey v2 (`#Requires AutoHotkey v2.0` is inside the library)
- The library file is `#Persistent` to keep the script alive while the hook is active

## Quick Start 🔌
Show a tooltip near the cursor on every move:

```ahk
#Include src\OnMouseMove.ahk
#SingleInstance Force

CoordMode("ToolTip", "Screen")
CoordMode("Mouse", "Screen")

tooltipCb := (x, y, prevX, prevY) => ToolTip(Format("Moved to {1},{2} from {3},{4}", x, y, prevX, prevY), x + 16, y + 16)
OnMouseMove.Start(tooltipCb)
```

## Multiple Handlers 🧰
Add another callback that triggers when the cursor enters a region (0,0–50,50) and disable the tooltip at that moment:

```ahk
RegionHandler(x, y, prevX, prevY) {
    if (x >= 0 && x <= 50 && y >= 0 && y <= 50) {
        OnMouseMove.Remove(tooltipCb) ; stop tooltip handler
        ToolTip() ; hide current tooltip
        MsgBox("Entered region")
    }
}

OnMouseMove.Start(RegionHandler)
```

## API Reference 📚
- `OnMouseMove.Start(callback)`
  - Registers `callback` and installs the global mouse hook if not already installed.
  - `callback` receives `(x, y, prevX, prevY)` on every `WM_MOUSEMOVE`.

- `OnMouseMove.Remove(callback)`
  - Unsubscribes a previously registered `callback` by reference.

- `OnMouseMove.GetLastXY()` → `[x, y]`
  - Returns the last observed coordinates.

- `OnMouseMove.Off()`
  - Uninstalls the hook and frees resources. Safe to call multiple times.

## Notes & Troubleshooting 🛠️
- Coordinates: Use `CoordMode("Mouse", "Screen")` for screen-based regions; `CoordMode("ToolTip", "Screen")` keeps the tooltip aligned with screen coordinates.
- Permissions: If you interact with elevated apps, run your script as administrator to ensure hooks work across windows.
- Modals: `MsgBox` is modal; while visible, UI won’t update (tooltips pause). Prefer non-blocking `Gui` for live overlays.

## License ✅
MIT — free to use, modify, and distribute.

