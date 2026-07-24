pragma Singleton
import QtQuick

QtObject {
    id: root

    property var openPopups: []
    property bool hasOpenPopups: openPopups.length > 0

    signal popupsChanged()

    // Validate that a popup reference is still valid
    function isValidPopup(popup) {
        try {
            // Check if popup exists and has expected properties
            if (!popup) return false
            // Try to access a property - will throw if object is destroyed
            var test = popup.visible
            return true
        } catch (e) {
            return false
        }
    }

    // Clean up any stale/destroyed popup references
    function cleanupStalePopups() {
        var validPopups = openPopups.filter(p => isValidPopup(p))
        if (validPopups.length !== openPopups.length) {
            console.log("PopupManager: cleaned up", openPopups.length - validPopups.length, "stale popups")
            openPopups = validPopups
            popupsChanged()
        }
    }

    function registerPopup(popup) {
        // First clean up any stale references
        cleanupStalePopups()

        if (openPopups.indexOf(popup) === -1) {
            openPopups = openPopups.concat([popup])
            console.log("PopupManager: registered popup, count:", openPopups.length)
            popupsChanged()
        }
    }

    function unregisterPopup(popup) {
        openPopups = openPopups.filter(p => p !== popup)
        // Also clean up any stale references while we're at it
        openPopups = openPopups.filter(p => isValidPopup(p))
        console.log("PopupManager: unregistered popup, count:", openPopups.length)
        popupsChanged()
    }

    function closeAllPopups() {
        console.log("PopupManager: closing all popups, count:", openPopups.length)
        var popupsCopy = openPopups.slice()
        for (var i = 0; i < popupsCopy.length; i++) {
            var popup = popupsCopy[i]
            if (isValidPopup(popup)) {
                if (popup.hideMenu) {
                    popup.hideMenu()
                } else if (popup.hide) {
                    popup.hide()
                }
            }
        }
        // Clean up after closing
        cleanupStalePopups()
    }

    // Force reset - use this as emergency cleanup
    function forceReset() {
        console.log("PopupManager: force reset called")
        openPopups = []
        popupsChanged()
    }
}
