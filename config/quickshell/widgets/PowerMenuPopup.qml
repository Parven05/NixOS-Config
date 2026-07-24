import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

PopupWindow {
    id: root
    color: "transparent"
    visible: false

    // Ensure cleanup on destruction
    Component.onDestruction: {
        PopupManager.unregisterPopup(root)
    }

    property var anchorItem: null
    property bool showContent: false

    readonly property int popupWidth: 180
    readonly property int itemHeight: 30
    readonly property int itemCount: 5
    readonly property int popupPadding: 10
    readonly property int popupHeight: itemCount * itemHeight + (itemCount - 1) * 5 + popupPadding * 2

    implicitWidth: popupWidth
    implicitHeight: popupHeight

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? -(popupWidth - anchorItem.width) : 0
    anchor.rect.y: -popupHeight - GlobalConfig.popupGap

    onVisibleChanged: {
        if (visible) {
            PopupManager.registerPopup(root)
        } else {
            PopupManager.unregisterPopup(root)
            showContent = false  // Reset state when hidden
        }
    }

    function show(item) {
        hideTimer.stop()  // Stop any pending hide
        anchorItem = item
        visible = true
        Qt.callLater(() => {
            root.anchor.updateAnchor()
            showContent = true
        })
    }

    function hide() {
        showContent = false
        hideTimer.start()
    }

    Timer {
        id: hideTimer
        interval: GlobalConfig.popupAnimationDuration
        onTriggered: root.visible = false
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.hide()
    }

    // Process instances for power commands
    Process {
        id: lockProcess
        command: ["sh", "-c", GlobalConfig.lockCommand]
    }

    Process {
        id: logoutProcess
        command: ["sh", "-c", GlobalConfig.logoutCommand]
    }

    Process {
        id: suspendProcess
        command: ["sh", "-c", GlobalConfig.suspendCommand]
    }

    Process {
        id: rebootProcess
        command: ["sh", "-c", GlobalConfig.rebootCommand]
    }

    Process {
        id: poweroffProcess
        command: ["sh", "-c", GlobalConfig.poweroffCommand]
    }

    PopupBackground {
        anchors.fill: parent
        showPopup: root.showContent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.popupPadding
            spacing: 5

            PowerMenuButton {
                Layout.fillWidth: true
                text: "Lock"
                onClicked: {
                    lockProcess.running = true
                    root.hide()
                }
            }

            PowerMenuButton {
                Layout.fillWidth: true
                text: "Logout"
                onClicked: {
                    logoutProcess.running = true
                    root.hide()
                }
            }

            PowerMenuButton {
                Layout.fillWidth: true
                text: "Suspend"
                onClicked: {
                    suspendProcess.running = true
                    root.hide()
                }
            }

            PowerMenuButton {
                Layout.fillWidth: true
                text: "Reboot"
                onClicked: {
                    rebootProcess.running = true
                    root.hide()
                }
            }

            PowerMenuButton {
                Layout.fillWidth: true
                text: "Shutdown"
                onClicked: {
                    poweroffProcess.running = true
                    root.hide()
                }
            }
        }
    }

    component PowerMenuButton: Rectangle {
        property string text: ""
        signal clicked()

        height: root.itemHeight
        radius: GlobalConfig.popupRadius > 0 ? GlobalConfig.popupRadius / 2 : 0
        color: buttonMouseArea.containsMouse ? GlobalConfig.activeColor : "transparent"

        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: buttonMouseArea.containsMouse ? GlobalConfig.backgroundColor : GlobalConfig.foregroundColor
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontSize
            font.weight: GlobalConfig.fontWeight
        }

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
