import QtQuick
import QtQuick.Layouts
import Quickshell
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

    property date currentDate: new Date()
    property int displayMonth: currentDate.getMonth()
    property int displayYear: currentDate.getFullYear()

    // Selected day tracking (cleared when popup hides)
    property int selectedDay: -1
    property int selectedMonth: -1
    property int selectedYear: -1

    readonly property int popupWidth: 280
    readonly property int popupHeight: 320

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
            // Clear selection when popup closes
            selectedDay = -1
            selectedMonth = -1
            selectedYear = -1
        }
    }

    function show(item) {
        hideTimer.stop()  // Stop any pending hide
        anchorItem = item
        displayMonth = currentDate.getMonth()
        displayYear = currentDate.getFullYear()
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

    function getDaysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate()
    }

    function getFirstDayOfMonth(month, year) {
        const day = new Date(year, month, 1).getDay()
        return day === 0 ? 6 : day - 1  // Monday = 0
    }

    function getMonthName(month) {
        const months = ["January", "February", "March", "April", "May", "June",
                       "July", "August", "September", "October", "November", "December"]
        return months[month]
    }

    function previousMonth() {
        if (displayMonth === 0) {
            displayMonth = 11
            displayYear--
        } else {
            displayMonth--
        }
    }

    function nextMonth() {
        if (displayMonth === 11) {
            displayMonth = 0
            displayYear++
        } else {
            displayMonth++
        }
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.hide()
    }

    PopupBackground {
        anchors.fill: parent
        showPopup: root.showContent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            // Header with month navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 30
                    height: 30
                    radius: GlobalConfig.popupRadius > 0 ? GlobalConfig.popupRadius / 2 : 0
                    color: prevMouseArea.containsMouse ? GlobalConfig.activeColor : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "<"
                        color: prevMouseArea.containsMouse ? GlobalConfig.backgroundColor : GlobalConfig.foregroundColor
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize
                        font.weight: GlobalConfig.fontWeight
                    }

                    MouseArea {
                        id: prevMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.previousMonth()
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: getMonthName(displayMonth) + " " + displayYear
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSizeLarge
                    font.weight: GlobalConfig.fontWeight
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: GlobalConfig.popupRadius > 0 ? GlobalConfig.popupRadius / 2 : 0
                    color: nextMouseArea.containsMouse ? GlobalConfig.activeColor : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ">"
                        color: nextMouseArea.containsMouse ? GlobalConfig.backgroundColor : GlobalConfig.foregroundColor
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize
                        font.weight: GlobalConfig.fontWeight
                    }

                    MouseArea {
                        id: nextMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.nextMonth()
                    }
                }
            }

            // Weekday headers
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 5
                columnSpacing: 5

                Repeater {
                    model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                    Text {
                        Layout.preferredWidth: 30
                        text: modelData
                        color: GlobalConfig.dimmedColor
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize - 2
                        font.weight: GlobalConfig.fontWeight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Calendar grid
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rowSpacing: 5
                columnSpacing: 5

                Repeater {
                    model: 42  // 6 weeks max

                    Rectangle {
                        id: dayCell
                        required property int index
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30

                        property int firstDayOffset: getFirstDayOfMonth(displayMonth, displayYear)
                        property int daysInCurrentMonth: getDaysInMonth(displayMonth, displayYear)
                        property int daysInPrevMonth: getDaysInMonth(displayMonth === 0 ? 11 : displayMonth - 1, displayMonth === 0 ? displayYear - 1 : displayYear)

                        // Calculate which day to show
                        property int dayOffset: index - firstDayOffset
                        property bool isPrevMonth: dayOffset < 0
                        property bool isNextMonth: dayOffset >= daysInCurrentMonth
                        property bool isCurrentMonth: !isPrevMonth && !isNextMonth

                        property int displayDay: {
                            if (isPrevMonth) {
                                return daysInPrevMonth + dayOffset + 1
                            } else if (isNextMonth) {
                                return dayOffset - daysInCurrentMonth + 1
                            } else {
                                return dayOffset + 1
                            }
                        }

                        // Calculate the actual month/year for this cell
                        property int cellMonth: {
                            if (isPrevMonth) {
                                return displayMonth === 0 ? 11 : displayMonth - 1
                            } else if (isNextMonth) {
                                return displayMonth === 11 ? 0 : displayMonth + 1
                            } else {
                                return displayMonth
                            }
                        }

                        property int cellYear: {
                            if (isPrevMonth && displayMonth === 0) {
                                return displayYear - 1
                            } else if (isNextMonth && displayMonth === 11) {
                                return displayYear + 1
                            } else {
                                return displayYear
                            }
                        }

                        property bool isToday: isCurrentMonth &&
                                              displayDay === currentDate.getDate() &&
                                              displayMonth === currentDate.getMonth() &&
                                              displayYear === currentDate.getFullYear()

                        property bool isSelected: selectedDay === displayDay &&
                                                  selectedMonth === cellMonth &&
                                                  selectedYear === cellYear

                        property bool isHovered: dayMouseArea.containsMouse

                        radius: GlobalConfig.popupRadius > 0 ? GlobalConfig.popupRadius / 2 : 0

                        // Background color: today filled, hovered subtle, selected has border
                        color: {
                            if (isToday) return GlobalConfig.activeColor
                            if (isHovered && isCurrentMonth) return Qt.rgba(GlobalConfig.activeColor.r, GlobalConfig.activeColor.g, GlobalConfig.activeColor.b, 0.2)
                            return "transparent"
                        }

                        // Selection border
                        border.width: isSelected && !isToday ? 2 : 0
                        border.color: GlobalConfig.activeColor

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }

                        Behavior on border.width {
                            NumberAnimation { duration: 100 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.displayDay
                            color: {
                                if (dayCell.isToday) return GlobalConfig.backgroundColor
                                if (dayCell.isHovered && dayCell.isCurrentMonth) return GlobalConfig.foregroundColor
                                if (dayCell.isSelected) return GlobalConfig.activeColor
                                if (dayCell.isCurrentMonth) return GlobalConfig.dimmedColor
                                return "#444444"  // Extra muted for prev/next month days
                            }
                            font.family: GlobalConfig.fontFamily
                            font.pixelSize: GlobalConfig.fontSize
                            font.weight: (dayCell.isToday || dayCell.isSelected) ? Font.Bold : GlobalConfig.fontWeight

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                        }

                        MouseArea {
                            id: dayMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: dayCell.isCurrentMonth ? Qt.PointingHandCursor : Qt.ArrowCursor

                            onClicked: {
                                if (dayCell.isCurrentMonth) {
                                    // Toggle selection
                                    if (dayCell.isSelected) {
                                        selectedDay = -1
                                        selectedMonth = -1
                                        selectedYear = -1
                                    } else {
                                        selectedDay = dayCell.displayDay
                                        selectedMonth = dayCell.cellMonth
                                        selectedYear = dayCell.cellYear
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
