import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import ".."

Variants {
    id: root

    model: GlobalConfig.notificationsEnabled ? Quickshell.screens : []

    delegate: Loader {
        id: loader

        required property var modelData

        property ListModel notificationModel: ListModel {}

        // Metadata stored separately - maps ID to {timestamp, duration, paused, pauseTime}
        property var notificationMeta: ({})

        active: notificationModel.count > 0 || delayTimer.running

        Timer {
            id: delayTimer
            interval: 400
            repeat: false
        }

        Connections {
            target: notificationModel
            function onCountChanged() {
                if (notificationModel.count === 0 && loader.active) {
                    delayTimer.restart()
                }
            }
        }

        NotificationServer {
            id: notificationServer
            keepOnReload: false
            actionsSupported: true
            imageSupported: true

            onNotification: notification => {
                const id = notification.id
                const now = Date.now()
                const duration = notification.urgency === 2 ? -1 : GlobalConfig.notificationTimeout

                const data = {
                    id: id,
                    summary: notification.summary || "",
                    body: (notification.body || "").replace(/<[^>]*>?/gm, ''),
                    appName: notification.appName || "Unknown",
                    urgency: notification.urgency,
                    progress: 1.0,
                    notification: notification,
                    actions: notification.actions || []
                }

                // Store metadata separately
                notificationMeta[id] = {
                    timestamp: now,
                    duration: duration,
                    paused: false,
                    pauseTime: 0
                }

                notification.tracked = true
                notification.closed.connect(() => removeNotification(id))

                notificationModel.insert(0, data)

                while (notificationModel.count > GlobalConfig.notificationMaxVisible) {
                    const last = notificationModel.get(notificationModel.count - 1)
                    if (last.notification) last.notification.dismiss()
                    delete notificationMeta[last.id]
                    notificationModel.remove(notificationModel.count - 1)
                }
            }
        }

        function removeNotification(id) {
            for (let i = 0; i < notificationModel.count; i++) {
                if (notificationModel.get(i).id === id) {
                    notificationModel.remove(i)
                    break
                }
            }
            delete notificationMeta[id]
        }

        function dismissNotification(id) {
            for (let i = 0; i < notificationModel.count; i++) {
                const item = notificationModel.get(i)
                if (item.id === id) {
                    if (item.notification) item.notification.dismiss()
                    notificationModel.remove(i)
                    break
                }
            }
            delete notificationMeta[id]
        }

        function pauseTimeout(id) {
            const meta = notificationMeta[id]
            if (meta && !meta.paused) {
                meta.paused = true
                meta.pauseTime = Date.now()
            }
        }

        function resumeTimeout(id) {
            const meta = notificationMeta[id]
            if (meta && meta.paused) {
                // Adjust timestamp to account for pause duration
                meta.timestamp += Date.now() - meta.pauseTime
                meta.paused = false
            }
        }

        // Single central timer for ALL progress updates
        Timer {
            id: progressTimer
            interval: 50
            repeat: true
            running: notificationModel.count > 0

            onTriggered: {
                const now = Date.now()
                let toRemove = null

                for (let i = 0; i < notificationModel.count; i++) {
                    const notif = notificationModel.get(i)
                    const meta = notificationMeta[notif.id]
                    if (!meta) continue

                    // Skip if never expires or paused
                    if (meta.duration === -1 || meta.paused) continue

                    const elapsed = now - meta.timestamp
                    const progress = Math.max(1.0 - (elapsed / meta.duration), 0.0)

                    if (progress <= 0) {
                        if (!toRemove) toRemove = notif.id
                    } else if (Math.abs(notif.progress - progress) > 0.005) {
                        notificationModel.setProperty(i, "progress", progress)
                    }
                }

                // Signal removal for first expired notification
                if (toRemove) {
                    animateAndRemove(toRemove)
                }
            }
        }

        // Signal to trigger animation before removal
        signal animateAndRemove(string notificationId)

        sourceComponent: PanelWindow {
            id: notifWindow
            screen: modelData

            // Track how many notifications are currently in "removing" state
            property int removingCount: 0

            // Window is only visible when there are non-removing notifications
            readonly property bool hasActiveNotifications: notificationModel.count > removingCount
            visible: hasActiveNotifications

            WlrLayershell.namespace: "notifications"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            color: "transparent"

            readonly property string pos: GlobalConfig.notificationPosition
            readonly property bool isTop: pos.startsWith("top")
            readonly property bool isBottom: pos.startsWith("bottom")
            readonly property bool isLeft: pos.endsWith("_left")
            readonly property bool isRight: pos.endsWith("_right")
            readonly property int barOffset: GlobalConfig.barHeight + GlobalConfig.notificationMargin

            anchors.top: isTop
            anchors.bottom: isBottom
            anchors.left: isLeft
            anchors.right: isRight

            margins.top: isTop ? (GlobalConfig.barPlacement === "top" ? barOffset : GlobalConfig.notificationMargin) : 0
            margins.bottom: isBottom ? (GlobalConfig.barPlacement === "bottom" ? barOffset : GlobalConfig.notificationMargin) : 0
            margins.left: isLeft ? GlobalConfig.notificationMargin : 0
            margins.right: isRight ? GlobalConfig.notificationMargin : 0

            implicitWidth: GlobalConfig.notificationWidth + 20
            implicitHeight: notificationColumn.implicitHeight + 20

            // Connect to animate signal
            Connections {
                target: loader
                function onAnimateAndRemove(notificationId) {
                    // Find the delegate and trigger animation
                    for (let i = 0; i < notificationRepeater.count; i++) {
                        const item = notificationRepeater.itemAt(i)
                        if (item && item.notifId === notificationId) {
                            item.animateOut()
                            return
                        }
                    }
                    // Fallback: just remove if delegate not found
                    loader.dismissNotification(notificationId)
                }
            }

            ColumnLayout {
                id: notificationColumn
                anchors.fill: parent
                anchors.margins: 10
                spacing: GlobalConfig.notificationSpacing
                // Allow notification exit animations to render outside bounds
                clip: false

                Repeater {
                    id: notificationRepeater
                    model: notificationModel

                    delegate: Item {
                        id: card
                        required property int index
                        required property var model

                        // Store ID for lookup
                        readonly property string notifId: model.id

                        Layout.fillWidth: true
                        // Shrink layout height to 0 when removing to eliminate input region
                        // Visual content uses absolute positioning to remain visible
                        Layout.preferredHeight: isRemoving ? 0 : _fixedHeight

                        // Disable all input on this item and children when removing
                        enabled: !isRemoving

                        // Allow visual content to render outside bounds during exit
                        clip: false

                        // Internal fixed height - set once after measuring, never animated
                        property real _fixedHeight: 80

                        // State flags
                        property bool isRemoving: false
                        property bool isHovered: false
                        property bool isDragging: false
                        property real swipeX: 0

                        readonly property real dismissThreshold: 100
                        readonly property bool isCritical: model.urgency === 2

                        // ============================================
                        // ENTRY ANIMATION - visual properties only
                        // ============================================
                        property real entryScale: 0.9
                        property real entryOpacity: 0.0
                        property real entrySlide: notifWindow.isTop ? -30 : 30

                        // Entry animation
                        NumberAnimation {
                            id: entryScaleAnim
                            target: card
                            property: "entryScale"
                            to: 1.0
                            duration: 200
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation {
                            id: entryOpacityAnim
                            target: card
                            property: "entryOpacity"
                            to: 1.0
                            duration: 180
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation {
                            id: entrySlideAnim
                            target: card
                            property: "entrySlide"
                            to: 0
                            duration: 220
                            easing.type: Easing.OutCubic
                        }

                        // ============================================
                        // EXIT ANIMATION - visual properties only
                        // ============================================
                        // Wipe: clip height shrinks, content slides up
                        property real exitClipHeight: 1.0  // 0 to 1 ratio
                        property real exitOpacity: 1.0

                        NumberAnimation {
                            id: exitClipAnim
                            target: card
                            property: "exitClipHeight"
                            to: 0.0
                            duration: 200
                            easing.type: Easing.InOutCubic
                            onFinished: {
                                // Decrement removing count before removal
                                notifWindow.removingCount--
                                // After visual animation completes, remove from model
                                // This causes INSTANT layout update (no jitter)
                                loader.dismissNotification(card.notifId)
                            }
                        }

                        NumberAnimation {
                            id: exitOpacityAnim
                            target: card
                            property: "exitOpacity"
                            to: 0.0
                            duration: 180
                            easing.type: Easing.InOutCubic
                        }

                        // Measure and start entry animation
                        Component.onCompleted: {
                            measureTimer.start()
                        }

                        Timer {
                            id: measureTimer
                            interval: 1
                            repeat: false
                            onTriggered: {
                                // Measure actual content height
                                card._fixedHeight = notifCard.implicitHeight + 4
                                // Start entry animation with stagger
                                entryDelayTimer.interval = card.index * 30
                                entryDelayTimer.start()
                            }
                        }

                        Timer {
                            id: entryDelayTimer
                            repeat: false
                            onTriggered: {
                                if (!card.isRemoving) {
                                    entryScaleAnim.start()
                                    entryOpacityAnim.start()
                                    entrySlideAnim.start()
                                }
                            }
                        }

                        function animateOut() {
                            if (isRemoving) return
                            isRemoving = true

                            // Immediately increment removing count to hide window when all removing
                            notifWindow.removingCount++

                            // Stop any entry animations
                            measureTimer.stop()
                            entryDelayTimer.stop()
                            entryScaleAnim.stop()
                            entryOpacityAnim.stop()
                            entrySlideAnim.stop()

                            // Ensure fully visible before exit
                            entryScale = 1.0
                            entryOpacity = 1.0
                            entrySlide = 0

                            // Start exit animation
                            exitClipAnim.start()
                            exitOpacityAnim.start()
                        }

                        // Hover handling
                        onIsHoveredChanged: {
                            if (isHovered) {
                                resumeTimer.stop()
                                loader.pauseTimeout(notifId)
                            } else {
                                resumeTimer.start()
                            }
                        }

                        Timer {
                            id: resumeTimer
                            interval: 50
                            repeat: false
                            onTriggered: {
                                if (!card.isHovered) {
                                    loader.resumeTimeout(card.notifId)
                                }
                            }
                        }

                        // ============================================
                        // VISUAL CONTENT - transforms applied here
                        // ============================================
                        Item {
                            id: visualContainer
                            // Use explicit size instead of anchors so it renders
                            // even when parent has 0 height (during exit)
                            width: parent.width
                            height: card._fixedHeight
                            x: 0
                            y: 0

                            // Entry transforms
                            scale: card.entryScale
                            opacity: card.entryOpacity * card.exitOpacity
                            transformOrigin: Item.Top

                            transform: Translate {
                                y: card.entrySlide
                            }

                            // Clip container for wipe effect
                            Item {
                                id: clipContainer
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                // Height is ratio of fixed height
                                height: card._fixedHeight * card.exitClipHeight
                                clip: true

                                Rectangle {
                                    id: notifCard
                                    width: parent.width
                                    implicitHeight: contentCol.implicitHeight + 20
                                    height: implicitHeight
                                    anchors.top: parent.top
                                    x: card.swipeX

                                    Behavior on x {
                                        enabled: !card.isDragging
                                        NumberAnimation {
                                            duration: 180
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    transform: Rotation {
                                        origin.x: notifCard.width / 2
                                        origin.y: notifCard.height / 2
                                        axis { x: 0; y: 1; z: 0 }
                                        angle: card.swipeX * 0.02
                                    }

                                    color: GlobalConfig.notificationBackground
                                    border.color: {
                                        const baseColor = (() => {
                                            switch (card.model.urgency) {
                                                case 0: return GlobalConfig.notificationLowColor
                                                case 2: return GlobalConfig.notificationCriticalColor
                                                default: return GlobalConfig.notificationNormalColor
                                            }
                                        })()
                                        return hoverArea.containsMouse ? Qt.lighter(baseColor, 1.4) : baseColor
                                    }
                                    border.width: hoverArea.containsMouse ? 2 : 1
                                    radius: GlobalConfig.popupRadius

                                    Behavior on border.color {
                                        ColorAnimation { duration: 120 }
                                    }

                                    // Timer bar
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: 4
                                        color: "transparent"
                                        radius: GlobalConfig.popupRadius

                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            height: card.isCritical ? parent.height : (parent.height * card.model.progress)
                                            radius: GlobalConfig.popupRadius

                                            color: {
                                                if (card.isCritical) return GlobalConfig.notificationCriticalColor
                                                if (card.model.urgency === 0) return GlobalConfig.notificationLowColor
                                                return GlobalConfig.notificationNormalColor
                                            }

                                            Behavior on height {
                                                enabled: !card.isCritical && !card.isRemoving
                                                NumberAnimation { duration: 60; easing.type: Easing.Linear }
                                            }

                                            SequentialAnimation on opacity {
                                                running: card.isCritical
                                                loops: Animation.Infinite
                                                NumberAnimation { to: 0.5; duration: 800; easing.type: Easing.InOutSine }
                                                NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        id: contentCol
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        anchors.leftMargin: 14
                                        spacing: 6

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Rectangle {
                                                width: 8
                                                height: 8
                                                radius: 4
                                                color: notifCard.border.color

                                                SequentialAnimation on scale {
                                                    running: card.isCritical
                                                    loops: Animation.Infinite
                                                    NumberAnimation { to: 1.3; duration: 600; easing.type: Easing.InOutSine }
                                                    NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                                                }
                                            }

                                            Text {
                                                text: card.model.appName
                                                color: GlobalConfig.dimmedColor
                                                font.family: GlobalConfig.fontFamily
                                                font.pixelSize: GlobalConfig.fontSize - 2
                                                font.weight: Font.Bold
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                visible: card.isCritical
                                                text: "CRITICAL"
                                                color: GlobalConfig.notificationCriticalColor
                                                font.family: GlobalConfig.fontFamily
                                                font.pixelSize: GlobalConfig.fontSize - 3
                                                font.weight: Font.Bold
                                            }

                                            Text {
                                                text: ""
                                                color: closeArea.containsMouse ? GlobalConfig.urgentColor : GlobalConfig.dimmedColor
                                                font.family: GlobalConfig.fontFamily
                                                font.pixelSize: GlobalConfig.fontSize + 2

                                                scale: closeArea.containsMouse ? 1.2 : 1.0
                                                Behavior on scale {
                                                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                                                }
                                                Behavior on color { ColorAnimation { duration: 100 } }

                                                MouseArea {
                                                    id: closeArea
                                                    anchors.fill: parent
                                                    anchors.margins: -6
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    enabled: !card.isRemoving
                                                    onClicked: card.animateOut()
                                                }
                                            }
                                        }

                                        Text {
                                            text: card.model.summary
                                            color: GlobalConfig.notificationForeground
                                            font.family: GlobalConfig.fontFamily
                                            font.pixelSize: GlobalConfig.fontSize
                                            font.weight: Font.Bold
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                            visible: text !== ""
                                        }

                                        Text {
                                            text: card.model.body
                                            color: Qt.lighter(GlobalConfig.dimmedColor, 1.2)
                                            font.family: GlobalConfig.fontFamily
                                            font.pixelSize: GlobalConfig.fontSize - 1
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            maximumLineCount: 4
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                            visible: text !== ""
                                            lineHeight: 1.2
                                        }

                                        Flow {
                                            Layout.fillWidth: true
                                            Layout.topMargin: 4
                                            spacing: 8
                                            visible: card.model.actions && card.model.actions.length > 0

                                            Repeater {
                                                model: card.model.actions || []

                                                Rectangle {
                                                    width: actionText.implicitWidth + 16
                                                    height: actionText.implicitHeight + 8
                                                    color: actionArea.containsMouse ? GlobalConfig.activeColor : "transparent"
                                                    border.color: GlobalConfig.activeColor
                                                    border.width: 1
                                                    radius: GlobalConfig.popupRadius > 0 ? GlobalConfig.popupRadius / 2 : 2

                                                    scale: actionArea.containsMouse ? 1.03 : 1.0
                                                    Behavior on scale {
                                                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                                                    }
                                                    Behavior on color { ColorAnimation { duration: 100 } }

                                                    Text {
                                                        id: actionText
                                                        anchors.centerIn: parent
                                                        text: modelData.text || "Action"
                                                        color: actionArea.containsMouse ? GlobalConfig.backgroundColor : GlobalConfig.activeColor
                                                        font.family: GlobalConfig.fontFamily
                                                        font.pixelSize: GlobalConfig.fontSize - 2
                                                        font.weight: Font.Medium

                                                        Behavior on color { ColorAnimation { duration: 100 } }
                                                    }

                                                    MouseArea {
                                                        id: actionArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        enabled: !card.isRemoving
                                                        onClicked: {
                                                            if (modelData.invoke) modelData.invoke()
                                                        }
                                                        onEntered: card.isHovered = true
                                                        onExited: card.isHovered = hoverArea.containsMouse
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: hoverArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.NoButton
                                        propagateComposedEvents: true
                                        enabled: !card.isRemoving
                                        onContainsMouseChanged: {
                                            card.isHovered = containsMouse
                                        }
                                    }

                                    MouseArea {
                                        id: dragArea
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                        propagateComposedEvents: true
                                        enabled: !card.isRemoving

                                        property real startX: 0
                                        property real startY: 0
                                        property bool horizontalSwipe: false
                                        property bool directionLocked: false

                                        onPressed: mouse => {
                                            if (mouse.button === Qt.LeftButton) {
                                                startX = mouse.x
                                                startY = mouse.y
                                                directionLocked = false
                                                horizontalSwipe = false
                                            }
                                        }

                                        onPositionChanged: mouse => {
                                            if (!(mouse.buttons & Qt.LeftButton)) return

                                            const dx = mouse.x - startX
                                            const dy = mouse.y - startY

                                            if (!directionLocked && (Math.abs(dx) > 8 || Math.abs(dy) > 8)) {
                                                horizontalSwipe = Math.abs(dx) > Math.abs(dy)
                                                directionLocked = true
                                                if (horizontalSwipe) {
                                                    card.isDragging = true
                                                }
                                            }

                                            if (horizontalSwipe) {
                                                card.swipeX = dx * 0.9
                                            }
                                        }

                                        onReleased: mouse => {
                                            if (mouse.button === Qt.RightButton) {
                                                card.animateOut()
                                                return
                                            }

                                            if (horizontalSwipe && card.isDragging) {
                                                if (Math.abs(card.swipeX) > card.dismissThreshold) {
                                                    const direction = card.swipeX > 0 ? 1 : -1
                                                    card.swipeX = direction * (GlobalConfig.notificationWidth + 50)
                                                    card.animateOut()
                                                } else {
                                                    card.swipeX = 0
                                                }
                                            }

                                            card.isDragging = false
                                            directionLocked = false
                                            horizontalSwipe = false
                                        }

                                        onCanceled: {
                                            card.isDragging = false
                                            directionLocked = false
                                            horizontalSwipe = false
                                            card.swipeX = 0
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
}
