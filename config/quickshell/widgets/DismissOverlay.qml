import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

// Full-screen overlay to catch clicks outside popups
PanelWindow {
    id: root
    // Slight tint to see the overlay (for debugging)
    // color: PopupManager.hasOpenPopups ? "#10ffffff" : "transparent"
    color: "transparent"
    visible: PopupManager.hasOpenPopups

    onVisibleChanged: {
        console.log("DismissOverlay: visible changed to", visible, "hasOpenPopups:", PopupManager.hasOpenPopups)
        // Start/stop the failsafe timer based on visibility
        if (visible) {
            failsafeTimer.start()
        } else {
            failsafeTimer.stop()
        }
    }

    // Failsafe timer: periodically validate that registered popups are still valid
    // This catches cases where popups were destroyed without proper cleanup
    Timer {
        id: failsafeTimer
        interval: 2000  // Check every 2 seconds
        repeat: true
        running: false
        onTriggered: {
            // Ask PopupManager to clean up any stale references
            PopupManager.cleanupStalePopups()
        }
    }

    // Layer settings - sits below popups but above other windows
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-dismiss-overlay"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Full-screen click catcher
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: {
            console.log("DismissOverlay clicked! Closing popups...")
            PopupManager.closeAllPopups()
        }
    }
}
