import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Io
import ".."

Variants {
    id: root

    model: GlobalConfig.osdEnabled ? Quickshell.screens : []

    delegate: Loader {
        id: loader

        required property var modelData

        active: false

        // Audio system detection and tracking
        property string audioSystem: "unknown"
        property bool pipewireWorking: false
        property int pulseVolume: 0
        property bool pulseMuted: false

        readonly property PwNode sink: Pipewire.ready ? Pipewire.defaultAudioSink : null
        
        // Combined volume/mute properties
        readonly property real volume: {
            if (audioSystem === "pipewire" && pipewireWorking) {
                return sink?.audio?.volume ?? 0
            } else {
                return pulseVolume / 100.0
            }
        }
        readonly property bool muted: {
            if (audioSystem === "pipewire" && pipewireWorking) {
                return sink?.audio?.muted ?? false
            } else {
                return pulseMuted
            }
        }

        property real lastVolume: -1
        property bool lastMuted: false
        property bool startupComplete: false

        PwObjectTracker {
            objects: loader.sink ? [loader.sink] : []
            onObjectsChanged: {
                // Check if Pipewire actually has working audio
                if (loader.sink?.audio) {
                    pipewireWorking = true
                    audioSystem = "pipewire"
                    console.log("VolumeOSD: Using Pipewire")
                } else {
                    pipewireWorking = false
                    // Fallback to PulseAudio
                    testPulseAudio()
                }
            }
        }

        // PulseAudio fallback processes
        Process {
            id: pulseGetSinkProcess
            command: ["sh", "-c", "pactl get-default-sink"]
            stdout: SplitParser {
                onRead: data => {
                    const sinkName = data.trim()
                    if (sinkName) {
                        loader.fallbackSink = sinkName
                        console.log("VolumeOSD: Using PulseAudio fallback with sink:", sinkName)
                        pulseGetVolumeProcess.command = ["sh", "-c", `pactl get-sink-volume "${sinkName}"`]
                        pulseGetMuteProcess.command = ["sh", "-c", `pactl get-sink-mute "${sinkName}"`]
                    }
                }
            }
            onExited: (code) => {
                if (code === 0) {
                    audioSystem = "pulseaudio"
                    console.log("VolumeOSD: Using PulseAudio fallback")
                } else {
                    console.log("VolumeOSD: Failed to get PulseAudio sink")
                }
            }
        }

        Process {
            id: pulseGetVolumeProcess
            command: ["sh", "-c", "echo waiting for sink"]
            stdout: SplitParser {
                onRead: data => {
                    // Parse volume from pactl output: "Volume: front-left: 45876 /  70% / -9.29 dB"
                    const match = data.match(/(\d+)%/)
                    if (match) {
                        const newVolume = parseInt(match[1])
                        if (newVolume !== loader.pulseVolume) {
                            console.log("VolumeOSD: Volume changed from", loader.pulseVolume, "to", newVolume)
                            loader.pulseVolume = newVolume
                        }
                    }
                }
            }
        }

        Process {
            id: pulseGetMuteProcess
            command: ["sh", "-c", `pactl get-sink-mute "${loader.fallbackSink || ''}"`]
            stdout: SplitParser {
                onRead: data => {
                    const newMuted = data.trim().includes("yes")
                    if (newMuted !== loader.pulseMuted) {
                        console.log("VolumeOSD: Mute changed from", loader.pulseMuted, "to", newMuted)
                        loader.pulseMuted = newMuted
                    }
                }
            }
        }

        property string fallbackSink: ""

        // PulseAudio fallback monitoring
        Timer {
            id: pulseUpdateTimer
            interval: 150  // Faster polling for better responsiveness
            running: true
            repeat: true
            onTriggered: {
                if (!pipewireWorking && fallbackSink) {
                    pulseGetVolumeProcess.running = true
                    pulseGetMuteProcess.running = true
                }
            }
        }

        function testPulseAudio() {
            pulseGetSinkProcess.running = true
            return true
        }

        function updatePulseAudio() {
            // This is now handled by the Timer and Process components
            if (fallbackSink) {
                pulseGetVolumeProcess.running = true
                pulseGetMuteProcess.running = true
            }
        }

        // Startup delay to avoid showing OSD on initial load
        Timer {
            id: startupTimer
            interval: 1000
            running: true
            onTriggered: {
                loader.lastVolume = loader.volume
                loader.lastMuted = loader.muted
                loader.startupComplete = true
            }
        }

        // Watch for volume changes
        onVolumeChanged: {
            if (!startupComplete) return
            if (Math.abs(volume - lastVolume) > 0.001) {
                lastVolume = volume
                showOSD()
            }
        }

        onMutedChanged: {
            if (!startupComplete) return
            if (muted !== lastMuted) {
                lastMuted = muted
                showOSD()
            }
        }

        onPulseVolumeChanged: {
            if (!startupComplete || pipewireWorking) return
            if (Math.abs((pulseVolume / 100.0) - lastVolume) > 0.001) {
                lastVolume = pulseVolume / 100.0
                showOSD()
            }
        }

        onPulseMutedChanged: {
            if (!startupComplete || pipewireWorking) return
            if (pulseMuted !== lastMuted) {
                lastMuted = pulseMuted
                showOSD()
            }
        }

        Component.onCompleted: {
            // Initialize PulseAudio fallback after a short delay
            startupDelayTimer.start()
        }

        Timer {
            id: startupDelayTimer
            interval: 500
            onTriggered: {
                if (!pipewireWorking) {
                    testPulseAudio()
                }
            }
        }

        function showOSD() {
            if (!loader.active) {
                loader.active = true
            }
            if (loader.item) {
                loader.item.showOSD()
            } else {
                Qt.callLater(() => {
                    if (loader.item) loader.item.showOSD()
                })
            }
        }

        sourceComponent: PanelWindow {
            id: osdWindow
            screen: modelData

            WlrLayershell.namespace: "volume-osd"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            color: "transparent"

            // Position
            readonly property string pos: GlobalConfig.osdPosition
            readonly property int barOffset: GlobalConfig.barHeight + GlobalConfig.osdMargin

            anchors.top: pos === "top"
            anchors.bottom: pos === "bottom" || pos === "center"
            anchors.left: true
            anchors.right: true

            margins.top: {
                if (pos === "top") return GlobalConfig.barPlacement === "top" ? barOffset : GlobalConfig.osdMargin
                return 0
            }
            margins.bottom: {
                if (pos === "center") return (screen.height - implicitHeight) / 2
                if (pos === "bottom") return GlobalConfig.barPlacement === "bottom" ? barOffset : GlobalConfig.osdMargin
                return 0
            }
            // Use left/right margins to center the OSD
            margins.left: (screen.width - GlobalConfig.osdWidth - 20) / 2
            margins.right: (screen.width - GlobalConfig.osdWidth - 20) / 2

            implicitWidth: GlobalConfig.osdWidth + 20
            implicitHeight: GlobalConfig.osdHeight + 20

            Item {
                id: osdItem
                anchors.fill: parent
                anchors.margins: 10
                visible: false
                opacity: 0
                scale: 0.9

                Behavior on opacity {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Timer {
                    id: hideTimer
                    interval: GlobalConfig.osdTimeout
                    onTriggered: osdItem.visible = false
                }

                Timer {
                    id: visibilityTimer
                    interval: 200
                    onTriggered: {
                        osdItem.visible = false
                        loader.active = false
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: GlobalConfig.osdBackground
                    border.color: GlobalConfig.osdBorder
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        // Volume icon
                        Text {
                            text: {
                                if (loader.muted) return ""
                                if (loader.volume < 0.01) return ""
                                if (loader.volume <= 0.5) return ""
                                return ""
                            }
                            color: loader.muted ? GlobalConfig.urgentColor : GlobalConfig.osdForeground
                            font.family: GlobalConfig.fontFamily
                            font.pixelSize: GlobalConfig.fontSize + 4
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Progress bar
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 8
                            Layout.alignment: Qt.AlignVCenter
                            color: GlobalConfig.osdBarBackground
                            radius: 4

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: parent.width * Math.min(1.0, loader.volume)
                                radius: parent.radius
                                color: {
                                    if (loader.muted) return GlobalConfig.dimmedColor
                                    if (loader.volume > 1.0) return GlobalConfig.badColor
                                    if (loader.volume > 0.5) return GlobalConfig.degradedColor
                                    return GlobalConfig.goodColor
                                }

                                Behavior on width {
                                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                                }
                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                        }

                        // Percentage
                        Text {
                            text: loader.muted ? "MUTE" : Math.round(loader.volume * 100) + "%"
                            color: loader.muted ? GlobalConfig.urgentColor : GlobalConfig.osdForeground
                            font.family: GlobalConfig.fontFamily
                            font.pixelSize: GlobalConfig.fontSize
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                function show() {
                    hideTimer.stop()
                    visibilityTimer.stop()
                    osdItem.visible = true
                    Qt.callLater(() => {
                        osdItem.opacity = 1
                        osdItem.scale = 1.0
                    })
                    hideTimer.start()
                }

                function hide() {
                    hideTimer.stop()
                    visibilityTimer.stop()
                    osdItem.opacity = 0
                    osdItem.scale = 0.9
                    visibilityTimer.start()
                }
            }

            function showOSD() {
                osdItem.show()
            }
        }
    }
}
