import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    implicitWidth: clockRow.implicitWidth + GlobalConfig.widgetPadding * 2
    implicitHeight: GlobalConfig.barHeight

    property bool hovered: false
    property date currentDate: new Date()

    Timer {
        interval: GlobalConfig.clockInterval
        running: true
        repeat: true
        onTriggered: currentDate = new Date()
    }

    CalendarPopup {
        id: calendarPopup
    }

    function toggleCalendar() {
        if (calendarPopup.visible) {
            calendarPopup.hide()
        } else {
            calendarPopup.show(root)
        }
    }

    // Hover detection area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }

    // Row anchored to the right, so it expands leftward
    Row {
        id: clockRow
        anchors.right: parent.right
        anchors.rightMargin: GlobalConfig.widgetPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        layoutDirection: Qt.RightToLeft  // Layout from right to left

        // Time (rightmost, stays in place)
        Item {
            width: timeText.implicitWidth
            height: timeText.implicitHeight

            Text {
                id: timeText
                text: Qt.formatDateTime(currentDate, "HH:mm:ss")
                color: GlobalConfig.foregroundColor
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontSize
                font.weight: GlobalConfig.fontWeight
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.toggleCalendar()
            }
        }

        // Date - slides in on hover (expands to the left)
        Text {
            id: dateText
            text: Qt.formatDateTime(currentDate, "ddd, dd.MMM")
            color: GlobalConfig.foregroundColor
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontSize
            font.weight: GlobalConfig.fontWeight
            verticalAlignment: Text.AlignVCenter

            // Slide in/out animation
            width: hovered ? implicitWidth : 0
            clip: true

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
