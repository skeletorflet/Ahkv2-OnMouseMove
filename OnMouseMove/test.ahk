#Include  OnMouseMove.ahk

OnMouseMove((x, y, prevX, prevY) => ToolTip(prevX "," prevY " -> " x "," y, x + 16, y + 16))