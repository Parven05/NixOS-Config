import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root
    implicitWidth: cpuText.implicitWidth + GlobalConfig.widgetPadding * 2
    implicitHeight: GlobalConfig.barHeight

    property real cpuUsagePercent: 0

    // Previous values for delta calculation
    property real prevTotal: 0
    property real prevIdle: 0

    Timer {
        interval: GlobalConfig.systemStatsInterval
        running: true
        repeat: true
        onTriggered: updateCpu()
    }

    Component.onCompleted: updateCpu()

    function updateCpu() {
        cpuProcess.running = true
    }

    Process {
        id: cpuProcess
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                // Parse: cpu user nice system idle iowait irq softirq steal
                const parts = data.trim().split(/\s+/)
                if (parts.length < 5) return

                // Skip "cpu" label, parse numbers
                const user = parseInt(parts[1]) || 0
                const nice = parseInt(parts[2]) || 0
                const system = parseInt(parts[3]) || 0
                const idle = parseInt(parts[4]) || 0
                const iowait = parseInt(parts[5]) || 0
                const irq = parseInt(parts[6]) || 0
                const softirq = parseInt(parts[7]) || 0
                const steal = parseInt(parts[8]) || 0

                // Total = sum of all fields
                const total = user + nice + system + idle + iowait + irq + softirq + steal

                // Idle total = idle + iowait
                const idleTotal = idle + iowait

                // Calculate delta
                if (root.prevTotal > 0) {
                    const deltaTotal = total - root.prevTotal
                    const deltaIdle = idleTotal - root.prevIdle

                    if (deltaTotal > 0) {
                        // Usage = (delta_total - delta_idle) / delta_total * 100
                        root.cpuUsagePercent = ((deltaTotal - deltaIdle) / deltaTotal) * 100
                    }
                }

                // Store for next iteration
                root.prevTotal = total
                root.prevIdle = idleTotal
            }
        }
    }

    Text {
        id: cpuText
        anchors.centerIn: parent
        text: "CPU: " + cpuUsagePercent.toFixed(0) + "%"
        color: {
            if (cpuUsagePercent >= 85) return GlobalConfig.urgentColor
            else if (cpuUsagePercent >= 45) return GlobalConfig.degradedColor
            else if (cpuUsagePercent >= 15) return GlobalConfig.foregroundColor
            else return GlobalConfig.foregroundColor
        }
        font.family: GlobalConfig.fontFamily
        font.pixelSize: GlobalConfig.fontSize
        font.weight: GlobalConfig.fontWeight
    }
}
