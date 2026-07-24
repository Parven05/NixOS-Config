import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import ".."

Item {
    id: root
    implicitWidth: trayRow.implicitWidth + GlobalConfig.widgetPadding * 2
    implicitHeight: GlobalConfig.barHeight

    property var trayMenu: null  // Passed from Bar

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: GlobalConfig.trayIconSpacing

        Repeater {
            model: SystemTray.items ? SystemTray.items.values : []

            Item {
                id: trayItemContainer
                required property var modelData
                required property int index

                width: GlobalConfig.trayIconSize + 4
                height: GlobalConfig.trayIconSize + 4

                Image {
                    id: trayIcon
                    anchors.centerIn: parent
                    width: GlobalConfig.trayIconSize
                    height: GlobalConfig.trayIconSize
                    source: modelData?.icon ?? ""
                    smooth: true
                    visible: status === Image.Ready

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                        onClicked: function(mouse) {
                            if (!modelData) return

                            if (mouse.button === Qt.LeftButton) {
                                // Left click - activate
                                if (modelData.activate) {
                                    modelData.activate()
                                }
                            } else if (mouse.button === Qt.MiddleButton) {
                                // Middle click - secondary activate
                                if (modelData.secondaryActivate) {
                                    modelData.secondaryActivate()
                                }
                            } else if (mouse.button === Qt.RightButton) {
                                // Right click - show context menu
                                showContextMenu()
                            }
                        }

                        function showContextMenu() {
                            if (!root.trayMenu) {
                                console.log("SystemTray: No trayMenu available")
                                return
                            }

                            // Toggle if already showing this item's menu
                            if (root.trayMenu.visible && root.trayMenu.trayItem === modelData) {
                                root.trayMenu.hideMenu()
                                return
                            }

                            // Check if this tray item has a menu
                            if (!modelData.hasMenu || !modelData.menu) {
                                console.log("SystemTray: Item has no menu:", modelData.id || "unknown")
                                return
                            }

                            // Close any existing menu immediately, then open new one after a frame
                            if (root.trayMenu.visible) {
                                root.trayMenu.closeImmediately()
                                // Delay opening to let the opener reset
                                Qt.callLater(function() {
                                    root.trayMenu.trayItem = modelData
                                    root.trayMenu.showAt(trayItemContainer)
                                })
                            } else {
                                // No menu open, show directly
                                root.trayMenu.trayItem = modelData
                                root.trayMenu.showAt(trayItemContainer)
                            }
                        }
                    }
                }

                // Fallback text if no icon
                Text {
                    anchors.centerIn: parent
                    text: "?"
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize - 2
                    visible: trayIcon.status !== Image.Ready
                }
            }
        }
    }
}
