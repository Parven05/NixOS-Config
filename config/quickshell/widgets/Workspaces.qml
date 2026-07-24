import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root
    implicitWidth: workspacesRow.implicitWidth
    implicitHeight: GlobalConfig.barHeight

    // Screen this workspace widget belongs to (for per-monitor workspace filtering)
    property var screen: null
    // Get the output name from the screen (used to filter workspaces in niri)
    readonly property string outputName: screen?.name ?? ""

    readonly property int workspaceSize: GlobalConfig.barHeight - 4  // 4px margin (2px top + 2px bottom)
    property var workspacesList: []
    property int activeWorkspace: 1
    property string compositor: ""
    property string workspacesBuffer: ""
    property string activeWorkspaceBuffer: ""

    Component.onCompleted: {
        detectCompositor()
    }

    function detectCompositor() {
        compositorDetectProcess.running = true
    }

    Process {
        id: compositorDetectProcess
        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        stdout: SplitParser {
            onRead: data => {
                const desktop = data.trim().toLowerCase()
                if (desktop.includes("hyprland")) {
                    root.compositor = "hyprland"
                    loadHyprlandWorkspaces()
                } else if (desktop.includes("niri")) {
                    root.compositor = "niri"
                    loadNiriWorkspaces()
                } else {
                    root.compositor = "generic"
                }
            }
        }
    }

    Timer {
        interval: 69
        running: compositor !== ""
        repeat: true
        onTriggered: {
            if (compositor === "hyprland") {
                loadHyprlandWorkspaces()
            } else if (compositor === "niri") {
                loadNiriWorkspaces()
            }
        }
    }

    function loadHyprlandWorkspaces() {
        workspacesBuffer = ""
        hyprWorkspacesProcess.running = true
    }

    Process {
        id: hyprWorkspacesProcess
        command: ["hyprctl", "workspaces", "-j"]
        stdout: SplitParser {
            onRead: data => {
                root.workspacesBuffer += data
            }
        }
        onExited: (code) => {
            if (workspacesBuffer) {
                try {
                    const workspaces = JSON.parse(workspacesBuffer)
                    root.workspacesList = workspaces
                        .map(ws => ({id: ws.id, name: ws.name || String(ws.id)}))
                        .sort((a, b) => a.id - b.id)

                    // Get active workspace
                    activeWorkspaceBuffer = ""
                    hyprActiveProcess.running = true
                } catch (e) {
                    // Silently fail - will retry
                }
            }
        }
    }

    Process {
        id: hyprActiveProcess
        command: ["hyprctl", "activeworkspace", "-j"]
        stdout: SplitParser {
            onRead: data => {
                root.activeWorkspaceBuffer += data
            }
        }
        onExited: (code) => {
            if (activeWorkspaceBuffer) {
                try {
                    const active = JSON.parse(activeWorkspaceBuffer)
                    root.activeWorkspace = active.id
                } catch (e) {
                    // Silently fail
                }
            }
        }
    }

    function loadNiriWorkspaces() {
        workspacesBuffer = ""
        niriWorkspacesProcess.running = true
    }

    Process {
        id: niriWorkspacesProcess
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: SplitParser {
            onRead: data => {
                root.workspacesBuffer += data
            }
        }
        onExited: (code) => {
            if (workspacesBuffer) {
                try {
                    const workspaces = JSON.parse(workspacesBuffer)

                    // Filter workspaces by output (for per-monitor workspaces in niri)
                    // If outputName is empty, show all workspaces (fallback)
                    const outputWorkspaces = root.outputName
                        ? workspaces.filter(ws => ws.output === root.outputName)
                        : workspaces

                    // Only show workspaces that are:
                    // - Active (user is currently on this workspace), OR
                    // - Have windows (active_window_id is not null)
                    const filteredWorkspaces = outputWorkspaces.filter(ws =>
                        ws.is_active || ws.active_window_id !== null
                    )

                    root.workspacesList = filteredWorkspaces
                        .map(ws => ({
                            id: ws.id || ws.idx,
                            name: ws.name || String(ws.idx || ws.id),
                            isActive: ws.is_active || ws.is_focused,
                            idx: ws.idx  // Keep idx for display (niri uses idx for workspace number)
                        }))
                        .sort((a, b) => {
                            // Sort by idx first (niri workspace index)
                            if (a.idx !== undefined && b.idx !== undefined) {
                                return a.idx - b.idx
                            }

                            const aName = a.name
                            const bName = b.name
                            const aIsNumeric = /^\d+$/.test(aName)
                            const bIsNumeric = /^\d+$/.test(bName)

                            // Numeric workspaces come first
                            if (aIsNumeric && !bIsNumeric) return -1
                            if (!aIsNumeric && bIsNumeric) return 1

                            // Both numeric: sort by number
                            if (aIsNumeric && bIsNumeric) {
                                return parseInt(aName) - parseInt(bName)
                            }

                            // Both non-numeric: sort alphabetically (a-z)
                            return aName.toLowerCase().localeCompare(bName.toLowerCase())
                        })

                    // Find the active workspace for THIS output
                    const active = filteredWorkspaces.find(ws => ws.is_active || ws.is_focused)
                    if (active) {
                        root.activeWorkspace = active.id || active.idx
                    }
                } catch (e) {
                    // Silently fail
                }
            }
        }
    }

    Process {
        id: workspaceSwitchProcess
    }

    function switchWorkspace(id) {
        if (compositor === "hyprland") {
            workspaceSwitchProcess.command = ["hyprctl", "dispatch", "workspace", String(id)]
            workspaceSwitchProcess.running = true
        } else if (compositor === "niri") {
            workspaceSwitchProcess.command = ["niri", "msg", "action", "focus-workspace", String(id)]
            workspaceSwitchProcess.running = true
        }
    }

    function getWorkspaceIndex(id) {
        for (let i = 0; i < workspacesList.length; i++) {
            if (workspacesList[i].id === id) {
                return i
            }
        }
        return 0
    }

    function getWorkspaceDisplayName(workspace) {
        // For niri: prefer idx (workspace index) for display
        if (workspace.idx !== undefined) {
            // If workspace has a custom name that's not just the index, show first letter
            if (workspace.name && !/^\d+$/.test(workspace.name)) {
                return workspace.name.charAt(0).toUpperCase()
            }
            return String(workspace.idx)
        }

        // Get the name from the workspace object
        let name = workspace.name || workspace.id || workspace
        if (!name) return "?"

        let nameStr = String(name).trim()
        if (!nameStr) return "?"

        // Handle Hyprland special workspaces (e.g., "special:magic" -> "magic")
        if (nameStr.startsWith("special:")) {
            nameStr = nameStr.substring(8)  // Remove "special:" prefix
        }

        // Check if it's a pure number (or negative number for special workspaces)
        if (/^-?\d+$/.test(nameStr)) {
            return nameStr  // Return the number as-is
        }

        // For named workspaces, return the first letter (uppercase)
        const firstChar = nameStr.charAt(0).toUpperCase()
        return firstChar
    }

    // Active workspace background indicator - positioned behind the row
    Rectangle {
        id: activeIndicator
        width: workspaceSize
        height: workspaceSize
        color: GlobalConfig.activeColor
        border.color: GlobalConfig.borderColor
        border.width: 0
        z: 0
        visible: workspacesList.length > 0
        anchors.verticalCenter: parent.verticalCenter

        x: {
            const index = getWorkspaceIndex(activeWorkspace)
            return index * (workspaceSize)
        }

        Behavior on x {
            NumberAnimation {
                duration: 50
                easing.type: Easing.Linear
            }
        }
    }

    Row {
        id: workspacesRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Repeater {
            model: workspacesList

            Rectangle {
                required property var modelData
                required property int index

                width: root.workspaceSize
                height: root.workspaceSize
                color: "transparent"
                border.color: GlobalConfig.borderColor
                border.width: 1
                z: 1

                Text {
                    id: wsText
                    anchors.centerIn: parent
                    text: getWorkspaceDisplayName(modelData)
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: GlobalConfig.fontWeight
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.switchWorkspace(modelData.id)
                }
            }
        }
    }
}
