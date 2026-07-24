import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

Item {
    id: root
    implicitWidth: netRow.implicitWidth + GlobalConfig.widgetPadding * 2
    implicitHeight: GlobalConfig.barHeight

    property string ipAddress: "No IP"
    property string networkInterface: ""
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property var lastRxBytes: 0
    property var lastTxBytes: 0
    property var lastUpdateTime: 0
    property bool hasInternet: false
    property int linkSpeed: 0
    property bool internetCheckInProgress: false
    property int consecutiveFailures: 0

    Component.onCompleted: {
        detectInterface()
        checkInternet()
        updateLinkSpeed()
    }

    Timer {
        interval: GlobalConfig.networkInterval
        running: networkInterface !== ""
        repeat: true
        onTriggered: {
            updateIp()
            updateTraffic()
            updateLinkSpeed()
        }
    }

    Timer {
        interval: GlobalConfig.networkCheckInterval
        running: true
        repeat: true
        onTriggered: checkInternet()
    }

    // Fallback timer for faster checking when consecutive failures
    Timer {
        id: fastCheckTimer
        interval: 5000  // 5 seconds for fast checking when network is down
        running: consecutiveFailures > 0 && !internetCheckInProgress
        repeat: true
        onTriggered: {
            if (consecutiveFailures > 0) {
                checkInternet()
            }
        }
    }

    function checkInternet() {
        if (internetCheckInProgress) return
        
        internetCheckInProgress = true
        const endpoint = GlobalConfig.networkCheckEndpoint
        
        internetCheckProcess.command = ["curl", "-s", "--max-time", GlobalConfig.networkCheckTimeout.toString(), "-w", "%{http_code}", endpoint]
        internetCheckProcess.running = true
    }

    Process {
        id: internetCheckProcess
        
        stdout: SplitParser {
            onRead: data => {
                const output = data.trim()
                
                // Extract HTTP status code (it's the last thing curl prints with -w)
                const httpCodeMatch = output.match(/(\d{3})$/)
                const httpCode = httpCodeMatch ? parseInt(httpCodeMatch[1]) : 0
                
                // Consider 2xx and 3xx as success
                const wasConnected = root.hasInternet
                root.hasInternet = (httpCode >= 200 && httpCode < 400)
                
                if (root.hasInternet) {
                    if (!wasConnected) {
                        console.log("Network: Internet connectivity restored (HTTP", httpCode, ")")
                    }
                    root.consecutiveFailures = 0
                } else {
                    root.consecutiveFailures++
                    console.log("Network: Internet connectivity failed (HTTP", httpCode, ")")
                }
            }
        }
        
        onExited: (code) => {
            if (code !== 0) {
                const wasConnected = root.hasInternet
                root.hasInternet = false
                root.consecutiveFailures++
                console.log("Network: Internet connectivity failed (exit code", code, ")")
            }
            
            internetCheckInProgress = false
        }
    }

    function detectInterface() {
        interfaceProcess.running = true
    }

    Process {
        id: interfaceProcess
        command: ["sh", "-c", "ip route get 1.1.1.1 | grep -oP 'dev \\K\\S+'"]
        stdout: SplitParser {
            onRead: data => {
                root.networkInterface = data.trim()
                updateIp()
                updateTraffic()
            }
        }
    }

    function updateIp() {
        if (networkInterface === "") return
        ipProcess.running = true
    }

    Process {
        id: ipProcess
        command: ["sh", "-c", `ip addr show ${networkInterface} | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1`]
        stdout: SplitParser {
            onRead: data => {
                const ip = data.trim()
                if (ip && ip !== "127.0.0.1") {
                    root.ipAddress = ip
                }
            }
        }
    }

    function updateTraffic() {
        if (networkInterface === "") return
        trafficProcess.running = true
    }

    Process {
        id: trafficProcess
        command: ["sh", "-c", `cat /sys/class/net/${networkInterface}/statistics/rx_bytes /sys/class/net/${networkInterface}/statistics/tx_bytes`]
        stdout: SplitParser {
            onRead: data => {
                const lines = data.trim().split("\n")
                if (lines.length >= 2) {
                    const rxBytes = parseInt(lines[0])
                    const txBytes = parseInt(lines[1])
                    const now = Date.now()

                    if (lastUpdateTime > 0) {
                        const timeDelta = (now - lastUpdateTime) / 1000
                        if (timeDelta > 0) {
                            root.downloadSpeed = (rxBytes - lastRxBytes) / timeDelta
                            root.uploadSpeed = (txBytes - lastTxBytes) / timeDelta
                        }
                    }

                    lastRxBytes = rxBytes
                    lastTxBytes = txBytes
                    lastUpdateTime = now
                }
            }
        }
    }

    function updateLinkSpeed() {
        if (networkInterface === "") return
        linkSpeedProcess.running = true
    }

    Process {
        id: linkSpeedProcess
        command: ["cat", `/sys/class/net/${networkInterface}/speed`]
        stdout: SplitParser {
            onRead: data => {
                const speed = parseInt(data.trim())
                if (speed > 0) {
                    root.linkSpeed = speed
                }
            }
        }
    }

    Row {
        id: netRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: ipAddress + (linkSpeed > 0 ? " (" + linkSpeed + " Mbit/s)" : "")
            color: hasInternet ? GlobalConfig.goodColor : GlobalConfig.badColor
            font.family: GlobalConfig.fontFamily
            font.pixelSize: GlobalConfig.fontSize
            font.weight: GlobalConfig.fontWeight
            verticalAlignment: Text.AlignVCenter
        }
    }


}