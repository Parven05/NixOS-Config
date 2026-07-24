import QtQuick
import QtQuick.Effects
import ".."

Item {
    id: root

    // ===========================================
    // PUBLIC API
    // ===========================================

    // Control animation state from parent
    property bool showPopup: false

    // Content to display inside the popup
    default property alias content: contentContainer.data

    // ===========================================
    // ANIMATED PROPERTIES
    // ===========================================

    property real animOpacity: 0
    property real animScale: PopupConfig.contentScaleStart

    // ===========================================
    // ANIMATIONS
    // ===========================================

    // Entry animations
    NumberAnimation {
        id: opacityInAnim
        target: root
        property: "animOpacity"
        to: 1.0
        duration: PopupConfig.popupContentDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveStandard
    }

    NumberAnimation {
        id: scaleInAnim
        target: root
        property: "animScale"
        to: 1.0
        duration: PopupConfig.popupContentDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveExpressiveDefault
    }

    // Exit animations
    NumberAnimation {
        id: opacityOutAnim
        target: root
        property: "animOpacity"
        to: 0
        duration: PopupConfig.popupContentDuration * 0.6
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveEmphasizedAccel
    }

    NumberAnimation {
        id: scaleOutAnim
        target: root
        property: "animScale"
        to: PopupConfig.contentScaleStart
        duration: PopupConfig.popupContentDuration * 0.6
        easing.type: Easing.BezierSpline
        easing.bezierCurve: PopupConfig.curveEmphasizedAccel
    }

    // ===========================================
    // STATE HANDLING
    // ===========================================

    onShowPopupChanged: {
        if (showPopup) {
            // Stop exit animations
            opacityOutAnim.stop()
            scaleOutAnim.stop()

            // Start entry animations
            opacityInAnim.start()
            scaleInAnim.start()
        } else {
            // Stop entry animations
            opacityInAnim.stop()
            scaleInAnim.stop()

            // Start exit animations
            opacityOutAnim.start()
            scaleOutAnim.start()
        }
    }

    // ===========================================
    // VISUAL STRUCTURE
    // ===========================================

    // Shadow layer
    Rectangle {
        id: shadowRect
        anchors.fill: backgroundRect
        anchors.margins: -PopupConfig.shadowSpread
        anchors.topMargin: -PopupConfig.shadowSpread
        anchors.bottomMargin: 0  // No shadow at bottom (merges with bar)
        radius: GlobalConfig.popupRadius + PopupConfig.shadowSpread
        color: PopupConfig.shadowColor
        visible: PopupConfig.shadowEnabled
        opacity: root.animOpacity * 0.4

        // Flat bottom for shadow
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: GlobalConfig.popupRadius + PopupConfig.shadowSpread
            color: parent.color
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: PopupConfig.shadowBlur
        }

        // Apply transforms to shadow too
        transform: Scale {
            origin.x: root.width / 2
            origin.y: root.height
            xScale: root.animScale
            yScale: root.animScale
        }
    }

    // Main background with rounded top, flat bottom
    Item {
        id: backgroundRect
        anchors.fill: parent
        opacity: root.animOpacity

        transform: Scale {
            origin.x: root.width / 2
            origin.y: root.height
            xScale: root.animScale
            yScale: root.animScale
        }

        // Main fill
        Rectangle {
            id: mainBg
            anchors.fill: parent
            radius: GlobalConfig.popupRadius
            color: GlobalConfig.backgroundColor
        }

        // Flat bottom overlay (covers bottom rounded corners)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: GlobalConfig.popupBorderWidth
            anchors.rightMargin: GlobalConfig.popupBorderWidth
            height: GlobalConfig.popupRadius
            color: GlobalConfig.backgroundColor
        }

        // Border - top only (with rounded corners)
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: GlobalConfig.popupBorderWidth
            radius: GlobalConfig.popupRadius
            color: GlobalConfig.popupBorderColor
        }

        // Border - left side
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: GlobalConfig.popupRadius / 2
            width: GlobalConfig.popupBorderWidth
            color: GlobalConfig.popupBorderColor
        }

        // Border - right side
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.topMargin: GlobalConfig.popupRadius / 2
            width: GlobalConfig.popupBorderWidth
            color: GlobalConfig.popupBorderColor
        }
    }

    // Content container
    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.leftMargin: GlobalConfig.popupBorderWidth
        anchors.rightMargin: GlobalConfig.popupBorderWidth
        anchors.topMargin: GlobalConfig.popupBorderWidth
        anchors.bottomMargin: 0
        opacity: root.animOpacity

        transform: Scale {
            origin.x: root.width / 2
            origin.y: root.height
            xScale: root.animScale
            yScale: root.animScale
        }
    }
}
