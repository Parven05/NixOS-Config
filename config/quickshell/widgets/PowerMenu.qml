import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root
    implicitWidth: powerIcon.implicitWidth + GlobalConfig.widgetPadding * 2
    implicitHeight: GlobalConfig.barHeight

    PowerMenuPopup {
        id: menuPopup
    }

    function toggleMenu() {
        if (menuPopup.visible) {
            menuPopup.hide()
        } else {
            menuPopup.show(root)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Text {
            id: powerIcon
            anchors.centerIn: parent
            text: "⏼"
            color: GlobalConfig.foregroundColor
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontSizeLarge
            font.weight: GlobalConfig.fontWeight
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.toggleMenu()
        }
    }
}
