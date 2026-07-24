import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

PopupWindow {
    id: root
    color: "transparent"
    visible: false

    // Ensure cleanup on destruction
    Component.onDestruction: {
        PopupManager.unregisterPopup(root)
    }

    readonly property int popupWidth: 320
    readonly property int popupPadding: 12

    implicitWidth: popupWidth
    implicitHeight: contentColumn.implicitHeight + popupPadding * 2

    property var anchorItem: null
    property var parentWidget: null
    property bool showContent: false

    // Network properties - bound to parent widget when available
    property string ipAddress: parentWidget?.ipAddress ?? "No IP"
    property string networkId: "N/A"
    property string gateway: "N/A"
    property string networkInterface: parentWidget?.networkInterface ?? ""
    property real downloadSpeed: parentWidget?.downloadSpeed ?? 0
    property real uploadSpeed: parentWidget?.uploadSpeed ?? 0
    property int linkSpeed: parentWidget?.linkSpeed ?? 0
    property bool hasInternet: parentWidget?.hasInternet ?? false

    // Cumulative traffic
    property real totalDownloadMB: 0
    property real totalUploadMB: 0
    property real sessionStartRxBytes: 0
    property real sessionStartTxBytes: 0
    property real currentRxBytes: 0
    property real currentTxBytes: 0

    // Cache file path
    readonly property string cacheDir: StandardPaths.writableLocation(StandardPaths.CacheLocation) ||
                                       StandardPaths.home + "/.cache/quickshell"
    readonly property string cacheFile: cacheDir + "/network-stats.json"

    onVisibleChanged: {
        if (visible) {
            PopupManager.registerPopup(root)
            loadCache()
            initializeSession()
            updateNetworkInfo()
            updateTimer.start()
        } else {
            PopupManager.unregisterPopup(root)
            updateTimer.stop()
            saveCache()
            showContent = false  // Reset state when hidden
        }
    }

    anchor.item: anchorItem
    anchor.rect.x: -(popupWidth - (anchorItem?.width ?? 0)) / 2
    anchor.rect.y: -implicitHeight - GlobalConfig.popupGap

    // Update timer
    Timer {
        id: updateTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: updateNetworkInfo()
    }

    Timer {
        id: hideTimer
        interval: GlobalConfig.popupAnimationDuration
        onTriggered: root.visible = false
    }

    Component.onCompleted: {
        ensureCacheDir()
    }

    function ensureCacheDir() {
        Process.exec("mkdir", ["-p", cacheDir])
    }

    function loadCache() {
        const readProcess = Process.exec("cat", [cacheFile])
        if (readProcess.exitCode === 0 && readProcess.stdout.trim() !== "") {
            try {
                const data = JSON.parse(readProcess.stdout)
                totalDownloadMB = data.totalDownloadMB || 0
                totalUploadMB = data.totalUploadMB || 0
            } catch (e) {
                console.log("Failed to parse network cache:", e)
                totalDownloadMB = 0
                totalUploadMB = 0
            }
        } else {
            totalDownloadMB = 0
            totalUploadMB = 0
        }
    }

    function saveCache() {
        const data = {
            totalDownloadMB: totalDownloadMB,
            totalUploadMB: totalUploadMB,
            timestamp: Date.now()
        }
        const json = JSON.stringify(data)
        Process.exec("sh", ["-c", `echo '${json}' > "${cacheFile}"`])
    }

    function initializeSession() {
        if (networkInterface === "") return
        const result = Process.exec("sh", ["-c", `cat /sys/class/net/${networkInterface}/statistics/rx_bytes /sys/class/net/${networkInterface}/statistics/tx_bytes`])
        if (result.exitCode === 0) {
            const lines = result.stdout.trim().split("\n")
            if (lines.length >= 2) {
                sessionStartRxBytes = parseInt(lines[0]) || 0
                sessionStartTxBytes = parseInt(lines[1]) || 0
                currentRxBytes = sessionStartRxBytes
                currentTxBytes = sessionStartTxBytes
            }
        }
    }

    function updateNetworkInfo() {
        if (networkInterface === "") {
            detectInterfaceProcess.running = true
        } else {
            updateIpProcess.running = true
            updateGatewayProcess.running = true
            updateTrafficProcess.running = true
        }
    }

    function show(item, widget) {
        hideTimer.stop()  // Stop any pending hide
        anchorItem = item
        parentWidget = widget
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

    // Detect network interface
    Process {
        id: detectInterfaceProcess
        command: ["sh", "-c", "ip route get 1.1.1.1 | grep -oP 'dev \\K\\S+'"]
        stdout: SplitParser {
            onRead: data => {
                root.networkInterface = data.trim()
                updateNetworkInfo()
            }
        }
    }

    // Update IP address and network ID
    Process {
        id: updateIpProcess
        command: ["sh", "-c", `ip addr show ${networkInterface} | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}'`]
        stdout: SplitParser {
            onRead: data => {
                const cidr = data.trim()
                if (cidr && cidr !== "127.0.0.1") {
                    const parts = cidr.split('/')
                    root.ipAddress = parts[0]
                    if (parts.length === 2) {
                        // Calculate network ID
                        const prefix = parseInt(parts[1])
                        const ipParts = parts[0].split('.').map(p => parseInt(p))
                        const mask = ((0xFFFFFFFF << (32 - prefix)) >>> 0)
                        const networkParts = [
                            (ipParts[0] & (mask >>> 24)) >>> 0,
                            (ipParts[1] & ((mask >>> 16) & 0xFF)) >>> 0,
                            (ipParts[2] & ((mask >>> 8) & 0xFF)) >>> 0,
                            (ipParts[3] & (mask & 0xFF)) >>> 0
                        ]
                        root.networkId = networkParts.join('.') + '/' + prefix
                    }
                }
            }
        }
    }

    // Update gateway
    Process {
        id: updateGatewayProcess
        command: ["sh", "-c", `ip route show default dev ${networkInterface} | awk '{print $3}' | head -1`]
        stdout: SplitParser {
            onRead: data => {
                const gw = data.trim()
                root.gateway = gw || "N/A"
            }
        }
    }

    // Update traffic and calculate cumulative totals for this session
    Process {
        id: updateTrafficProcess
        command: ["sh", "-c", `cat /sys/class/net/${networkInterface}/statistics/rx_bytes /sys/class/net/${networkInterface}/statistics/tx_bytes`]
        stdout: SplitParser {
            onRead: data => {
                const lines = data.trim().split("\n")
                if (lines.length >= 2) {
                    const rxBytes = parseInt(lines[0]) || 0
                    const txBytes = parseInt(lines[1]) || 0

                    // Update current bytes
                    if (currentRxBytes > 0 && currentTxBytes > 0) {
                        // Calculate delta since last update
                        const rxDelta = rxBytes - currentRxBytes
                        const txDelta = txBytes - currentTxBytes

                        // Only accumulate if delta is positive and reasonable (not a reset)
                        if (rxDelta > 0 && rxDelta < 1000000000) {  // Less than 1GB per second (sanity check)
                            root.totalDownloadMB += rxDelta / (1024 * 1024)
                        }
                        if (txDelta > 0 && txDelta < 1000000000) {
                            root.totalUploadMB += txDelta / (1024 * 1024)
                        }
                    }

                    currentRxBytes = rxBytes
                    currentTxBytes = txBytes
                }
            }
        }
    }

    function formatSpeed(bytesPerSec) {
        const bitsPerSec = bytesPerSec * 8
        if (bitsPerSec < 1000) return bitsPerSec.toFixed(0) + " bit/s"
        else if (bitsPerSec < 1000000) return (bitsPerSec / 1000).toFixed(1) + " Kbit/s"
        else if (bitsPerSec < 1000000000) return (bitsPerSec / 1000000).toFixed(1) + " Mbit/s"
        else return (bitsPerSec / 1000000000).toFixed(2) + " Gbit/s"
    }

    function formatDataSize(mb) {
        if (mb < 1) return (mb * 1024).toFixed(2) + " KB"
        else if (mb < 1024) return mb.toFixed(2) + " MB"
        else return (mb / 1024).toFixed(2) + " GB"
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.hide()
    }

    PopupBackground {
        anchors.fill: parent
        showPopup: root.showContent

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.hide()
        }

        Column {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: root.popupPadding
            spacing: 10

            // Title
            Text {
                text: "NETWORK INFORMATION"
                color: GlobalConfig.dimmedColor
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontSize - 1
                font.weight: Font.Bold
            }

            // Interface
            Row {
                spacing: 8
                Text {
                    text: "Interface:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: networkInterface || "N/A"
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: Font.Bold
                }
            }

            // IP Address
            Row {
                spacing: 8
                Text {
                    text: "IP Address:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: ipAddress
                    color: hasInternet ? GlobalConfig.goodColor : GlobalConfig.badColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: Font.Bold
                }
            }

            // Network ID
            Row {
                spacing: 8
                Text {
                    text: "Network ID:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: networkId
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                }
            }

            // Gateway
            Row {
                spacing: 8
                Text {
                    text: "Gateway:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: gateway
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                }
            }

            // Link Speed
            Row {
                spacing: 8
                Text {
                    text: "Link Speed:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: linkSpeed > 0 ? linkSpeed + " Mbit/s" : "N/A"
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                }
            }

            // Internet Status
            Row {
                spacing: 8
                Text {
                    text: "Internet:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: hasInternet ? "Connected" : "Disconnected"
                    color: hasInternet ? GlobalConfig.goodColor : GlobalConfig.badColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: Font.Bold
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: GlobalConfig.borderColor
            }

            // Current Speed Section
            Text {
                text: "CURRENT SPEED"
                color: GlobalConfig.dimmedColor
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontSize - 1
                font.weight: Font.Bold
            }

            Row {
                spacing: 8
                Text {
                    text: "↓ Download:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: formatSpeed(downloadSpeed)
                    color: GlobalConfig.goodColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: Font.Bold
                }
            }

            Row {
                spacing: 8
                Text {
                    text: "↑ Upload:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: formatSpeed(uploadSpeed)
                    color: GlobalConfig.activeColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: Font.Bold
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: GlobalConfig.borderColor
            }

            // Total Traffic Section
            Text {
                text: "TOTAL TRAFFIC (SESSION)"
                color: GlobalConfig.dimmedColor
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontSize - 1
                font.weight: Font.Bold
            }

            Row {
                spacing: 8
                Text {
                    text: "Downloaded:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: formatDataSize(totalDownloadMB)
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: Font.Bold
                }
            }

            Row {
                spacing: 8
                Text {
                    text: "Uploaded:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: formatDataSize(totalUploadMB)
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: Font.Bold
                }
            }

            Row {
                spacing: 8
                Text {
                    text: "Total:"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    width: 100
                }
                Text {
                    text: formatDataSize(totalDownloadMB + totalUploadMB)
                    color: GlobalConfig.foregroundColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: Font.Bold
                }
            }

            // Help text
            Text {
                text: "Click to close"
                color: GlobalConfig.dimmedColor
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontSize - 2
                font.italic: true
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 4
            }
        }
    }
}
