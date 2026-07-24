pragma Singleton
import QtQuick

QtObject {
    // i3status-inspired colors
    readonly property color backgroundColor: "#111418"
    readonly property color foregroundColor: "#c9d1d9"
    readonly property color dimmedColor: "#6e7681"
    readonly property color activeColor: "#6ea8e0"
    readonly property color urgentColor: "#be5a55"
    readonly property color borderColor: "#1f242b"
    readonly property color goodColor: "#6eaa82"
    readonly property color degradedColor: "#c8aa5a"
    readonly property color badColor: "#be5a55"

    // i3status-style separator
    readonly property string separator: "|"

    // Bar dimensions
    readonly property int barHeight: 24
    readonly property int widgetPadding: 4

    // System tray
    property int trayIconSize: 20
    property int trayIconSpacing: 4

    // Bar placement: "top" or "bottom"
    property string barPlacement: "top"

    // Typography - easily configurable
    // property string fontFamily: "CaskaydiaCove Nerd Font"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property string iconFont: "JetBrainsMono Nerd Font"  // Font for nerd font icons
    property int fontSize: 13
    property int fontSizeLarge: 13
    property int fontWeight: Font.Bold // Normal, Bold

    // Update intervals (milliseconds)
    readonly property int clockInterval: 1000
    readonly property int systemStatsInterval: 2000
    readonly property int networkInterval: 3000

    // Animation settings
    readonly property int animationDuration: 120
    readonly property int popupAnimationDuration: 150

    // ===================
    // Popup Styling
    // ===================
    // Rounding for popup corners (0 for sharp corners like classic i3)
    readonly property int popupRadius: 4
    // Shadow settings for popup elevation effect
    readonly property bool popupShadowEnabled: true
    readonly property int popupShadowBlur: 20
    readonly property int popupShadowSpread: 4
    readonly property color popupShadowColor: "#80000000"
    readonly property int popupShadowOffsetY: 4
    // Popup border
    readonly property int popupBorderWidth: 1
    readonly property color popupBorderColor: "#1f242b"
    // Gap between popup and bar (0 = popup merges with bar)
    readonly property int popupGap: 0
    // Animation easing
    readonly property int popupScaleStart: 95  // percentage (95 = 0.95 scale)

    // Power menu commands (configurable)
    property string lockCommand: "swaylock"
    property string logoutCommand: "niri msg action quit"
    property string suspendCommand: "systemctl suspend"
    property string rebootCommand: "systemctl reboot"
    property string poweroffCommand: "systemctl poweroff"

    // Network interface (auto-detect if empty)
    property string networkInterface: ""

    // ===================
    // Network Check Settings
    // ===================
    // Single endpoint for privacy-focused network connectivity checking
    // Recommended: Cloudflare DNS (1.1.1.1) - privacy-respecting and reliable
    // Change to any endpoint that returns HTTP 200-399 for connectivity check
    property string networkCheckEndpoint: "https://1.1.1.1/"
    // Request timeout in seconds
    property int networkCheckTimeout: 3
    // How often to check connectivity (milliseconds)
    property int networkCheckInterval: 15000

    // ===================
    // Notification Settings
    // ===================
    property bool notificationsEnabled: true
    property string notificationPosition: "top_right"  // top_left, top_right, bottom_left, bottom_right
    property int notificationWidth: 350
    property int notificationMaxVisible: 5
    property int notificationTimeout: 5000  // ms, 0 = no auto-dismiss
    property int notificationSpacing: 8
    property int notificationMargin: 10
    // Notification colors (defaults to main colors, can be overridden)
    property color notificationBackground: backgroundColor
    property color notificationForeground: foregroundColor
    property color notificationBorder: borderColor
    // Urgency colors
    // property color notificationLowColor: dimmedColor
    // property color notificationNormalColor: activeColor
    // property color notificationCriticalColor: urgentColor
    // 8bit colors
    property color notificationLowColor: dimmedColor
    property color notificationNormalColor: goodColor
    property color notificationCriticalColor: badColor

    // ===================
    // Volume OSD Settings
    // ===================
    property bool osdEnabled: true
    property string osdPosition: "center"  // top, bottom, center
    property int osdWidth: 300
    property int osdHeight: 40
    property int osdTimeout: 1500  // ms
    property int osdMargin: 50
    // OSD colors
    property color osdBackground: backgroundColor
    property color osdForeground: foregroundColor
    property color osdBorder: borderColor
    property color osdBarBackground: borderColor
    property color osdBarForeground: activeColor

    // ===================
    // Drive Widget Settings
    // ===================
    // Mount points to monitor (1-5 entries)
    // Each entry: { name: "display name", mountpoint: "/path/to/mount" }
    property var driveMountPoints: [
        { name: "root", mountpoint: "/" },
        { name: "storage", mountpoint: "/mnt/storage" },
        { name: "VMs", mountpoint: "/mnt/VMs" }
    ]
    // Thresholds for drive space coloring (based on percentage USED)
    property int driveGoodThreshold: 50      // 0-50% used = green (goodColor)
    property int driveDegradedThreshold: 80  // 51-80% used = yellow (degradedColor)
    // Above 80% = red (badColor)
    property int driveUpdateInterval: 30000  // Update every 30 seconds (drives don't change often)
}
