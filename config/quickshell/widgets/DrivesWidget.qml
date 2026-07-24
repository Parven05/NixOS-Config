import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

Item {
    id: root
    implicitWidth: driveRow.implicitWidth + GlobalConfig.widgetPadding * 2
    implicitHeight: GlobalConfig.barHeight

    property var driveData: []
    property bool hovered: false

    Timer {
        interval: GlobalConfig.driveUpdateInterval
        running: true
        repeat: true
        onTriggered: updateDrives()
    }

    Component.onCompleted: updateDrives()

    function updateDrives() {
        const mounts = GlobalConfig.driveMountPoints.slice(0, 5)
        if (mounts.length === 0) return

        const mountPaths = mounts.map(m => m.mountpoint).join(" ")
        driveProcess.command = ["sh", "-c", "df -B1 " + mountPaths + " 2>/dev/null | tail -n +2"]
        driveProcess.running = true
    }

    function getColorForPercent(percent) {
        if (percent <= GlobalConfig.driveGoodThreshold) {
            return GlobalConfig.goodColor
        } else if (percent <= GlobalConfig.driveDegradedThreshold) {
            return GlobalConfig.degradedColor
        } else {
            return GlobalConfig.badColor
        }
    }

    function formatSize(bytes) {
        const gb = bytes / (1024 * 1024 * 1024)
        if (gb >= 1000) {
            return (gb / 1024).toFixed(1) + "T"
        } else if (gb >= 100) {
            return gb.toFixed(0) + "G"
        } else if (gb >= 10) {
            return gb.toFixed(1) + "G"
        } else {
            return gb.toFixed(2) + "G"
        }
    }

    property string dfOutput: ""

    Process {
        id: driveProcess
        stdout: SplitParser {
            onRead: data => {
                root.dfOutput += data + "\n"
            }
        }
        onExited: (code) => {
            if (code === 0) {
                parseDfOutput()
            }
            root.dfOutput = ""
        }
    }

    function parseDfOutput() {
        const lines = dfOutput.trim().split("\n")
        const mounts = GlobalConfig.driveMountPoints.slice(0, 5)
        const newData = []

        for (let i = 0; i < mounts.length; i++) {
            const mount = mounts[i]
            const line = lines.find(l => {
                const parts = l.trim().split(/\s+/)
                return parts.length >= 6 && parts[5] === mount.mountpoint
            })

            if (line) {
                const parts = line.trim().split(/\s+/)
                if (parts.length >= 6) {
                    const total = parseInt(parts[1]) || 0
                    const used = parseInt(parts[2]) || 0
                    const available = parseInt(parts[3]) || 0
                    const percentStr = parts[4].replace('%', '')
                    const percent = parseInt(percentStr) || 0

                    newData.push({
                        name: mount.name,
                        mountpoint: mount.mountpoint,
                        used: used,
                        total: total,
                        available: available,
                        percent: percent
                    })
                }
            } else {
                newData.push({
                    name: mount.name,
                    mountpoint: mount.mountpoint,
                    used: 0,
                    total: 0,
                    available: 0,
                    percent: 0,
                    error: true
                })
            }
        }

        root.driveData = newData
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: {
            if (drivePopup.visible) {
                drivePopup.hide()
            } else {
                drivePopup.show(root)
            }
        }
    }

    Row {
        id: driveRow
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: root.driveData

            Item {
                id: driveItem
                implicitWidth: driveContent.implicitWidth
                implicitHeight: GlobalConfig.barHeight

                Row {
                    id: driveContent
                    spacing: 0
                    anchors.verticalCenter: parent.verticalCenter

                    // Separator pipe (except for first)
                    Text {
                        visible: index > 0
                        text: " " + GlobalConfig.separator + " "
                        color: GlobalConfig.dimmedColor
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize
                        font.weight: GlobalConfig.fontWeight
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Drive name - always visible
                    Text {
                        text: modelData.name + ":"
                        color: GlobalConfig.foregroundColor
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize
                        font.weight: Font.Bold
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Label - cross-fade between avail and used
                    Text {
                        id: labelText
                        text: root.hovered ? " used: " : " avail: "
                        color: GlobalConfig.dimmedColor
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize
                        font.weight: GlobalConfig.fontWeight
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Value - cross-fade between available and used
                    Text {
                        id: valueText
                        text: {
                            if (modelData.error) return "N/A"
                            return root.hovered ? formatSize(modelData.used) : formatSize(modelData.available)
                        }
                        color: modelData.error ? GlobalConfig.dimmedColor : getColorForPercent(modelData.percent)
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize
                        font.weight: GlobalConfig.fontWeight
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Additional info - slides in on hover (/total)
                    Item {
                        width: root.hovered ? totalText.implicitWidth : 0
                        height: totalText.implicitHeight
                        clip: true

                        Behavior on width {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutQuad
                            }
                        }

                        Text {
                            id: totalText
                            text: "/" + (modelData.error ? "N/A" : formatSize(modelData.total))
                            color: modelData.error ? GlobalConfig.dimmedColor : getColorForPercent(modelData.percent)
                            font.family: GlobalConfig.fontFamily
                            font.pixelSize: GlobalConfig.fontSize
                            font.weight: GlobalConfig.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    // Popup window for detailed drive info
    PopupWindow {
        id: drivePopup
        visible: false
        color: "transparent"

        property var anchorItem: null
        property bool showContent: false

        readonly property int popupWidth: 300
        readonly property int popupPadding: 12
        readonly property int popupHeight: popupContent.implicitHeight + popupPadding * 2

        implicitWidth: popupWidth
        implicitHeight: popupHeight

        // Anchor to the widget, position above it
        anchor.item: anchorItem
        anchor.rect.x: anchorItem ? -(popupWidth - anchorItem.width) : 0
        anchor.rect.y: -popupHeight - GlobalConfig.popupGap

        onVisibleChanged: {
            if (visible) {
                PopupManager.registerPopup(drivePopup)
            } else {
                PopupManager.unregisterPopup(drivePopup)
                showContent = false  // Reset state when hidden
            }
        }

        Timer {
            id: hideTimer
            interval: GlobalConfig.popupAnimationDuration
            onTriggered: drivePopup.visible = false
        }

        function show(item) {
            hideTimer.stop()  // Stop any pending hide
            anchorItem = item
            visible = true
            Qt.callLater(() => {
                drivePopup.anchor.updateAnchor()
                showContent = true
            })
        }

        function hide() {
            showContent = false
            hideTimer.start()
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: drivePopup.hide()
        }

        PopupBackground {
            anchors.fill: parent
            showPopup: drivePopup.showContent

            MouseArea {
                anchors.fill: parent
                onClicked: drivePopup.hide()
            }

            Column {
                id: popupContent
                anchors.fill: parent
                anchors.margins: drivePopup.popupPadding
                spacing: 12

                Text {
                    text: "DRIVE USAGE"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize - 1
                    font.weight: Font.Bold
                }

                Repeater {
                    model: root.driveData

                    Column {
                        spacing: 4
                        width: parent.width

                        RowLayout {
                            width: parent.width

                            Text {
                                text: modelData.name
                                color: GlobalConfig.foregroundColor
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontSize
                                font.weight: Font.Bold
                            }

                            Text {
                                text: modelData.mountpoint
                                color: GlobalConfig.dimmedColor
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontSize - 1
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        RowLayout {
                            width: parent.width

                            Text {
                                text: modelData.error ? "Not mounted" :
                                      formatSize(modelData.used) + " / " + formatSize(modelData.total)
                                color: modelData.error ? GlobalConfig.dimmedColor : GlobalConfig.foregroundColor
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontSize
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                visible: !modelData.error
                                text: formatSize(modelData.available) + " free"
                                color: getColorForPercent(modelData.percent)
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontSize
                            }

                            Text {
                                visible: !modelData.error
                                text: "(" + modelData.percent + "%)"
                                color: getColorForPercent(modelData.percent)
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontSize
                                font.weight: Font.Bold
                            }
                        }

                        // Progress bar
                        Rectangle {
                            visible: !modelData.error
                            width: parent.width
                            height: 6
                            color: GlobalConfig.borderColor
                            radius: 3

                            Rectangle {
                                width: parent.width * (modelData.percent / 100)
                                height: parent.height
                                color: getColorForPercent(modelData.percent)
                                radius: 3
                            }
                        }
                    }
                }
            }
        }
    }
}
