import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import ".."

PopupWindow {
    id: root
    color: "transparent"
    visible: false

    // Ensure cleanup on destruction
    Component.onDestruction: {
        if (!isSubMenu) {
            PopupManager.unregisterPopup(root)
        }
    }

    // Properties
    property var trayItem: null
    property var anchorItem: null
    property bool isSubMenu: false
    property var menuOverride: null

    // Animation state
    property bool showContent: false

    onVisibleChanged: {
        if (!isSubMenu) {
            if (visible) {
                PopupManager.registerPopup(root)
            } else {
                PopupManager.unregisterPopup(root)
                showContent = false  // Reset state when hidden
            }
        } else if (!visible) {
            showContent = false  // Reset state when hidden (submenu)
        }
    }

    // The actual menu handle
    readonly property var menuHandle: {
        if (isSubMenu && menuOverride) {
            return menuOverride
        }
        return trayItem?.menu ?? null
    }

    // Dimensions
    readonly property int menuWidth: 220
    readonly property int itemHeight: 26
    readonly property int separatorHeight: 9
    readonly property int menuPadding: 8
    readonly property int contentHeight: contentLayout.implicitHeight + menuPadding * 2

    implicitWidth: menuWidth
    implicitHeight: contentHeight

    // Anchor: position above the tray icon for bottom bar
    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? -(menuWidth / 2) + (anchorItem.width / 2) : 0
    anchor.rect.y: -contentHeight - GlobalConfig.popupGap

    // QsMenuOpener
    QsMenuOpener {
        id: opener
        menu: root.menuHandle
    }

    onMenuHandleChanged: {
        retryCount = 0
    }

    property int retryCount: 0
    readonly property int maxRetries: 20

    Timer {
        id: hideTimer
        interval: GlobalConfig.popupAnimationDuration
        onTriggered: {
            root.visible = false
            // Clean up submenus
            for (var i = 0; i < contentLayout.children.length; i++) {
                var child = contentLayout.children[i]
                if (child?.subMenu) {
                    child.subMenu.closeImmediately()
                    child.subMenu.destroy()
                    child.subMenu = null
                }
            }
        }
    }

    // Immediate close without animation (for switching menus)
    function closeImmediately() {
        hideTimer.stop()
        showContent = false
        visible = false
        retryCount = 0
        // Clean up submenus
        for (var i = 0; i < contentLayout.children.length; i++) {
            var child = contentLayout.children[i]
            if (child?.subMenu) {
                child.subMenu.closeImmediately()
                child.subMenu.destroy()
                child.subMenu = null
            }
        }
    }

    function showAt(item) {
        if (!item) return

        // Stop any pending hide
        hideTimer.stop()

        anchorItem = item

        // Make visible to allow QsMenuOpener to work
        if (!visible) {
            showContent = false
            visible = true
        }

        // Check if children are ready
        var childCount = opener.children?.values?.length ?? 0

        if (childCount === 0 && retryCount < maxRetries) {
            retryCount++
            Qt.callLater(function() { showAt(item) })
            return
        }

        retryCount = 0

        if (childCount === 0) {
            visible = false
            return
        }

        // Trigger animation
        Qt.callLater(function() {
            root.anchor.updateAnchor()
            showContent = true
        })
    }

    function hideMenu() {
        showContent = false
        hideTimer.start()
    }

    // Escape key
    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.hideMenu()
    }

    PopupBackground {
        anchors.fill: parent
        showPopup: root.showContent

        // Animated content container
        Item {
            id: contentContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: root.menuPadding

            // Animate height from 0 to full
            height: showContent ? contentLayout.implicitHeight : 0
            opacity: showContent ? 1 : 0
            clip: true

            Behavior on height {
                NumberAnimation {
                    duration: GlobalConfig.popupAnimationDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: GlobalConfig.popupAnimationDuration * 0.7
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                id: contentLayout
                width: parent.width
                anchors.bottom: parent.bottom
                spacing: 0

                Repeater {
                    model: opener.children?.values ? [...opener.children.values] : []

                    delegate: Rectangle {
                        id: menuEntry
                        required property var modelData
                        required property int index

                        property var subMenu: null

                        Layout.fillWidth: true
                        Layout.preferredHeight: modelData?.isSeparator ? root.separatorHeight : root.itemHeight

                        radius: GlobalConfig.popupRadius > 0 ? GlobalConfig.popupRadius / 3 : 0
                        color: entryMouse.containsMouse && !(modelData?.isSeparator)
                               ? GlobalConfig.activeColor : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }

                        // Separator
                        Rectangle {
                            visible: modelData?.isSeparator ?? false
                            anchors.centerIn: parent
                            width: parent.width - 16
                            height: 1
                            color: GlobalConfig.borderColor
                        }

                        // Menu item
                        Item {
                            anchors.fill: parent
                            visible: !(modelData?.isSeparator ?? false)

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.right: arrow.left
                                anchors.rightMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                text: (modelData?.text ?? "").replace(/[\n\r]+/g, ' ') || "..."
                                color: (modelData?.enabled ?? true)
                                       ? (entryMouse.containsMouse ? GlobalConfig.backgroundColor : GlobalConfig.foregroundColor)
                                       : GlobalConfig.dimmedColor
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontSize
                                elide: Text.ElideRight
                            }

                            Text {
                                id: arrow
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: ">"
                                visible: modelData?.hasChildren ?? false
                                color: entryMouse.containsMouse ? GlobalConfig.backgroundColor : GlobalConfig.foregroundColor
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontSize
                            }

                            MouseArea {
                                id: entryMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false)

                                onClicked: {
                                    if (!modelData || modelData.isSeparator) return

                                    if (modelData.hasChildren) {
                                        if (menuEntry.subMenu) {
                                            menuEntry.subMenu.hideMenu()
                                            menuEntry.subMenu.destroy()
                                            menuEntry.subMenu = null
                                        } else {
                                            // Close siblings
                                            for (var i = 0; i < contentLayout.children.length; i++) {
                                                var sibling = contentLayout.children[i]
                                                if (sibling !== menuEntry && sibling.subMenu) {
                                                    sibling.subMenu.closeImmediately()
                                                    sibling.subMenu.destroy()
                                                    sibling.subMenu = null
                                                }
                                            }

                                            var comp = Qt.createComponent("TrayMenu.qml")
                                            if (comp.status === Component.Ready) {
                                                menuEntry.subMenu = comp.createObject(root, {
                                                    "menuOverride": modelData,
                                                    "isSubMenu": true
                                                })
                                                if (menuEntry.subMenu) {
                                                    menuEntry.subMenu.anchorItem = menuEntry
                                                    menuEntry.subMenu.anchor.rect.x = menuEntry.width - 5
                                                    menuEntry.subMenu.anchor.rect.y = 0
                                                    menuEntry.subMenu.visible = true
                                                    menuEntry.subMenu.showContent = true
                                                }
                                            }
                                        }
                                    } else {
                                        if (modelData.triggered) {
                                            modelData.triggered()
                                        }
                                        root.hideMenu()
                                    }
                                }
                            }
                        }

                        Component.onDestruction: {
                            if (subMenu) {
                                subMenu.destroy()
                                subMenu = null
                            }
                        }
                    }
                }
            }
        }
    }
}
