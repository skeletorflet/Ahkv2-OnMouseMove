#Include  OnMouseMove.ahk
Persistent

global panel := 0
global panelText := 0
global panelVisible := false
global lastTick := 0

createPanel() {
    global panel, panelText
    if (!panel) {
        panel := Gui("-Caption +AlwaysOnTop +ToolWindow +Border")
        panel.SetFont("s10", "Segoe UI")
        panelText := panel.AddText("w220", "Trigger Activado!")
    }
}

showPanel(x, y, text) {
    global panel, panelText, panelVisible
    createPanel()
    panelText.Value := text
    panel.Show("x" (x + 16) " y" (y + 16))
    panelVisible := true
}

movePanel(x, y, text) {
    global panel, panelText
    panelText.Value := text
    panel.Move(x + 16, y + 16)
}

hidePanel(*) {
    global panel, panelVisible
    if (panel && panelVisible) {
        panel.Hide()
        panelVisible := false
    }
}

onMove(x, y, prevX, prevY) {
    global lastTick, panelVisible
    if (A_TickCount - lastTick < 150)
        return
    lastTick := A_TickCount
    text := Format("Trigger Activado!`nX: {1} Y: {2}", x, y)
    if (!panelVisible) {
        showPanel(x, y, text)
    } else {
        movePanel(x, y, text)
    }
    SetTimer(hidePanel, -1200)
}

OnMouseMove(onMove)