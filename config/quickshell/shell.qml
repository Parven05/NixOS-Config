import Quickshell
import QtQuick
import "widgets"

ShellRoot {
    // Dismiss overlay (one per screen)
    Variants {
        model: Quickshell.screens

        DismissOverlay {
            required property var modelData
            screen: modelData
        }
    }

    // Global tray menu
    TrayMenu {
        id: globalTrayMenu
    }

    // Bars (one per screen)
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
            trayMenu: globalTrayMenu
        }
    }

    // Notifications
    Notifications {}

    // Volume OSD
    VolumeOSD {}
}
