import QtQuick
import QtQuick.Effects
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

    // ===========================================
    // PUBLIC API
    // ===========================================

    // Anchor configuration
    property var anchorItem: null
    property int anchorOffsetX: 0
    property int anchorOffsetY: 0

    // Content to display inside the popup
    default property alias content: contentContainer.data

    // Target dimensions (set these to your popup's desired size)
    property real targetWidth: 280
    property real targetHeight: 200

    // Padding inside the popup
    property int popupPadding: 12

    // ===========================================
    // INTERNAL STATE
    // ===========================================

    property bool isOpen: false
    property bool isAnimating: false

    // Animated dimensions (these drive the "growing from bar" effect)
    property real animWidth: 0
    property real animHeight: 0
    property real contentOpacity: 0
    property real contentScale: PopupConfig.contentScaleStart

    // The wrapper expands, creating the merge effect
    implicitWidth: animWidth
    implicitHeight: animHeight

    // Anchor setup
    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? (-(targetWidth / 2) + (anchorItem.width / 2) + anchorOffsetX) : anchorOffsetX
    anchor.rect.y: -targetHeight + anchorOffsetY

    // ===========================================
    // ANIMATIONS
    // ===========================================

    // Wrapper expansion animation
    NumberAnimation {
        id: expandWidthAnim
        target: root
        property: "animWidth"
        duration: PopupConfig.popupExpandDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveEmphasizedDecel
    }

    NumberAnimation {
        id: expandHeightAnim
        target: root
        property: "animHeight"
        duration: PopupConfig.popupExpandDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveEmphasizedDecel
    }

    // Content fade/scale animation
    NumberAnimation {
        id: contentOpacityAnim
        target: root
        property: "contentOpacity"
        duration: PopupConfig.popupContentDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveStandard
    }

    NumberAnimation {
        id: contentScaleAnim
        target: root
        property: "contentScale"
        duration: PopupConfig.popupContentDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveExpressiveDefault
    }

    // Collapse animations (faster, accelerating)
    NumberAnimation {
        id: collapseWidthAnim
        target: root
        property: "animWidth"
        to: 0
        duration: PopupConfig.popupExpandDuration * 0.7
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveEmphasizedAccel
        onFinished: {
            if (!root.isOpen) {
                root.visible = false
                root.isAnimating = false
            }
        }
    }

    NumberAnimation {
        id: collapseHeightAnim
        target: root
        property: "animHeight"
        to: 0
        duration: PopupConfig.popupExpandDuration * 0.7
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveEmphasizedAccel
    }

    // Content exit animation
    NumberAnimation {
        id: contentExitOpacityAnim
        target: root
        property: "contentOpacity"
        to: 0
        duration: PopupConfig.popupContentDuration * 0.6
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveStandard
    }

    NumberAnimation {
        id: contentExitScaleAnim
        target: root
        property: "contentScale"
        to: PopupConfig.contentScaleStart
        duration: PopupConfig.popupContentDuration * 0.6
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveStandard
    }

    // Delay timer for content animation
    Timer {
        id: contentDelayTimer
        interval: PopupConfig.popupContentDelay
        repeat: false
        onTriggered: {
            contentOpacityAnim.to = 1
            contentOpacityAnim.start()
            contentScaleAnim.to = 1
            contentScaleAnim.start()
        }
    }

    // ===========================================
    // PUBLIC METHODS
    // ===========================================

    function show(item) {
        if (isAnimating && isOpen) return

        // Stop any closing animations
        collapseWidthAnim.stop()
        collapseHeightAnim.stop()
        contentExitOpacityAnim.stop()
        contentExitScaleAnim.stop()

        anchorItem = item
        isOpen = true
        isAnimating = true

        // Reset to initial state
        animWidth = 0
        animHeight = 0
        contentOpacity = 0
        contentScale = PopupConfig.contentScaleStart

        // Show and register
        visible = true
        PopupManager.registerPopup(root)

        // Update anchor position
        Qt.callLater(() => {
            root.anchor.updateAnchor()

            // Start expansion animation
            expandWidthAnim.to = targetWidth
            expandHeightAnim.to = targetHeight
            expandWidthAnim.start()
            expandHeightAnim.start()

            // Delay content animation slightly
            contentDelayTimer.start()
        })
    }

    function hide() {
        if (isAnimating && !isOpen) return
        if (!visible) return

        isOpen = false
        isAnimating = true

        // Stop any opening animations
        expandWidthAnim.stop()
        expandHeightAnim.stop()
        contentOpacityAnim.stop()
        contentScaleAnim.stop()
        contentDelayTimer.stop()

        // Start exit animations
        contentExitOpacityAnim.start()
        contentExitScaleAnim.start()

        // Collapse with slight delay
        Qt.callLater(() => {
            collapseWidthAnim.start()
            collapseHeightAnim.start()
        })

        PopupManager.unregisterPopup(root)
    }

    // ===========================================
    // ESCAPE KEY
    // ===========================================
    Item {
        anchors.fill: parent
        focus: root.visible
        Keys.onEscapePressed: root.hide()
    }

    // ===========================================
    // VISUAL STRUCTURE
    // ===========================================

    // Clipping container - this is the key to the "merge" effect
    Item {
        id: clipWrapper
        anchors.fill: parent
        clip: true

        // Shadow layer
        Rectangle {
            id: shadowRect
            anchors.fill: backgroundRect
            anchors.margins: -PopupConfig.shadowSpread
            radius: GlobalConfig.popupRadius + PopupConfig.shadowSpread
            color: PopupConfig.shadowColor
            visible: PopupConfig.shadowEnabled
            opacity: root.contentOpacity * 0.5

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1.0
                blurMax: PopupConfig.shadowBlur
            }
        }

        // Background with rounded top, flat bottom (merges with bar)
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: GlobalConfig.backgroundColor
            radius: GlobalConfig.popupRadius

            // Flat bottom to merge with bar
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: GlobalConfig.popupRadius
                color: parent.color
            }

            // Border - top and sides only
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: GlobalConfig.popupBorderWidth
                radius: GlobalConfig.popupRadius
                color: GlobalConfig.popupBorderColor
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: GlobalConfig.popupBorderWidth
                color: GlobalConfig.popupBorderColor
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: GlobalConfig.popupBorderWidth
                color: GlobalConfig.popupBorderColor
            }
        }

        // Content container with scale and opacity animation
        Item {
            id: contentContainer
            anchors.fill: parent
            anchors.margins: root.popupPadding

            opacity: root.contentOpacity
            scale: root.contentScale
            transformOrigin: Item.Bottom
        }
    }
}
