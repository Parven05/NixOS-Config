import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root
    implicitWidth: memText.implicitWidth + GlobalConfig.widgetPadding * 2
    implicitHeight: GlobalConfig.barHeight

    property real memoryUsedGiB: 0
    property real memoryTotalGiB: 0
    property real memoryUsagePercent: 0

    Timer {
        interval: GlobalConfig.systemStatsInterval
        running: true
        repeat: true
        onTriggered: updateMemory()
    }

    Component.onCompleted: updateMemory()

    function updateMemory() {
        memProcess.running = true
    }

    Process {
        id: memProcess
        command: ["sh", "-c", "awk '/MemTotal/ {total=$2} /MemAvailable/ {avail=$2} END {printf \"%d %d\", total, avail}' /proc/meminfo"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 2) {
                    const totalKB = parseInt(parts[0])
                    const availKB = parseInt(parts[1])

                    if (totalKB > 0 && availKB >= 0) {
                        const usedKB = totalKB - availKB

                        root.memoryTotalGiB = totalKB / 1024 / 1024
                        root.memoryUsedGiB = usedKB / 1024 / 1024
                        root.memoryUsagePercent = (usedKB / totalKB) * 100
                    }
                }
            }
        }
    }

    Text {
        id: memText
        anchors.centerIn: parent
        text: "RAM: " + memoryUsedGiB.toFixed(1) + " GiB/" + memoryTotalGiB.toFixed(1) + " GiB"
        color: {
            if (memoryUsagePercent >= 85) return GlobalConfig.urgentColor
            else if (memoryUsagePercent >= 44) return GlobalConfig.degradedColor
            else if (memoryUsagePercent >= 10) return GlobalConfig.goodColor
            else return GlobalConfig.foregroundColor
        }
        font.family: GlobalConfig.fontFamily
        font.pixelSize: GlobalConfig.fontSize
        font.weight: GlobalConfig.fontWeight
    }
}
