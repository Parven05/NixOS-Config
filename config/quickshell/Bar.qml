import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "widgets"

PanelWindow {
    id: barWindow

    property var trayMenu: null  // Will be set from shell.qml

    anchors {
        top: GlobalConfig.barPlacement === "top"
        bottom: GlobalConfig.barPlacement === "bottom"
        left: true
        right: true
    }

    implicitHeight: GlobalConfig.barHeight
    color: GlobalConfig.backgroundColor

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left side: Workspaces + Window Title
        RowLayout {
            Layout.alignment: Qt.AlignLeft
            spacing: 0

            Workspaces {
                Layout.alignment: Qt.AlignVCenter
                screen: barWindow.screen
            }

            Separator {}

            WindowTitle {
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        // Right side: System widgets
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 0

            SystemTray {
                Layout.alignment: Qt.AlignVCenter
                trayMenu: barWindow.trayMenu
            }

            NetworkWidget {
                Layout.alignment: Qt.AlignVCenter
            }

            Separator {}

            MemoryWidget {
                Layout.alignment: Qt.AlignVCenter
            }

            Separator {}

            CpuWidget {
                Layout.alignment: Qt.AlignVCenter
            }

            Separator {}

            VolumeWidget {
                Layout.alignment: Qt.AlignVCenter
            }

            Separator {}

            Clock {
                Layout.alignment: Qt.AlignVCenter
            }


        }
    }
}
