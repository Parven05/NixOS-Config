import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import ".."

Item {
    id: root
    objectName: "volumeWidget"
    implicitWidth: volumeRow.width + GlobalConfig.widgetPadding * 2
    implicitHeight: GlobalConfig.barHeight

    property bool hovered: false
    
    // OSD connection interface
    property var osdComponent: null

    // Audio system fallback logic: Pipewire -> PulseAudio -> ALSA
    property string audioSystem: "unknown"
    property bool pipewireAvailable: false
    property bool pulseaudioAvailable: false
    property bool alsaAvailable: false

    // Original Pipewire integration (primary)
    readonly property PwNode sink: Pipewire.ready ? Pipewire.defaultAudioSink : null
    
    // Fallback data properties
    property int fallbackVolume: 0
    property bool fallbackMuted: false
    property string fallbackSink: ""

    // Combined volume properties with fallback logic
    readonly property int volumeLevel: {
        if (audioSystem === "pipewire" && sink?.audio) {
            return Math.round(sink.audio.volume * 100)
        } else if (audioSystem === "pulseaudio" || audioSystem === "alsa") {
            return fallbackVolume
        }
        return 0
    }
    
    readonly property bool isMuted: {
        if (audioSystem === "pipewire" && sink?.audio) {
            return sink.audio.muted
        } else if (audioSystem === "pulseaudio" || audioSystem === "alsa") {
            return fallbackMuted
        }
        return false
    }

    // Volume color based on level
    readonly property color volumeColor: {
        if (isMuted) return GlobalConfig.dimmedColor  // Dark gray when muted
        if (volumeLevel > 100) return GlobalConfig.badColor      // Red: over 100%
        if (volumeLevel > 50) return GlobalConfig.degradedColor  // Yellow: 51-100%
        return GlobalConfig.goodColor                             // Green: 0-50%
    }

    readonly property string volumeIcon: {
        if (isMuted) return " "  // Dark gray when muted
        if (volumeLevel > 50) return " "      // Red: over 100%
        if (volumeLevel > 25) return " "  // Yellow: 51-100%
        return ""                             // Green: 0-50%
    }

    // Media player properties
    readonly property var currentPlayer: {
        if (!Mpris.players || Mpris.players.values.length === 0) return null
        // Find first playing player, or first available
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const p = Mpris.players.values[i]
            if (p.playbackState === MprisPlaybackState.Playing) return p
        }
        return Mpris.players.values[0]
    }
    readonly property bool hasPlayer: currentPlayer !== null
    readonly property bool isPlaying: currentPlayer?.playbackState === MprisPlaybackState.Playing
    readonly property string trackTitle: currentPlayer?.trackTitle ?? ""
    readonly property string trackArtist: currentPlayer?.trackArtist ?? ""
    readonly property bool canGoNext: currentPlayer?.canGoNext ?? false
    readonly property bool canGoPrevious: currentPlayer?.canGoPrevious ?? false
    readonly property bool canPlay: currentPlayer?.canPlay ?? false

    // Show media section only when hovered AND there's something playing/paused with track info
    readonly property bool showMedia: hovered && hasPlayer && trackTitle !== ""

    // Track sink for Pipewire
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    // PulseAudio fallback processes
    Process {
        id: pulseGetSinkProcess
        command: ["sh", "-c", "pactl get-default-sink"]
        stdout: SplitParser {
            onRead: data => {
                const sinkName = data.trim()
                if (sinkName) {
                    root.fallbackSink = sinkName
                    root.pulseaudioAvailable = true
                    pulseGetVolumeProcess.command = ["sh", "-c", `pactl get-sink-volume "${sinkName}"`]
                    pulseGetVolumeProcess.running = true
                }
            }
        }
        onExited: checkPulseAudioResult()
    }

    Process {
        id: pulseGetVolumeProcess
        command: ["sh", "-c", "echo waiting for sink"]
        stdout: SplitParser {
            onRead: data => {
                // Parse volume from pactl output: "Volume: front-left: 45876 /  70% / -9.29 dB"
                const match = data.match(/(\d+)%/)
                if (match) {
                    root.fallbackVolume = parseInt(match[1])
                }
            }
        }
    }

    Process {
        id: pulseGetMuteProcess
        command: ["sh", "-c", `pactl get-sink-mute "${root.fallbackSink}"`]
        stdout: SplitParser {
            onRead: data => {
                root.fallbackMuted = data.trim().includes("yes")
            }
        }
    }

    Process {
        id: pulseSetVolumeProcess
        command: ["sh", "-c", `pactl set-sink-volume "${root.fallbackSink}" PLACEHOLDER`]
    }

    Process {
        id: pulseToggleMuteProcess
        command: ["sh", "-c", `pactl set-sink-mute "${root.fallbackSink}" toggle`]
    }

    // ALSA fallback processes
    Process {
        id: alsaGetVolumeProcess
        command: ["sh", "-c", "amixer sget Master 2>/dev/null || amixer sget PCM 2>/dev/null || amixer sget 'Headphone' 2>/dev/null"]
        stdout: SplitParser {
            onRead: data => {
                // Parse from amixer output: "Front Left: Playback 24144 [37%] [on]"
                const volumeMatch = data.match(/\[(\d+)%\]/)
                if (volumeMatch) {
                    root.fallbackVolume = parseInt(volumeMatch[1])
                    root.alsaAvailable = true
                }
                // Parse mute state: "[on]" or "[off]"
                const muteMatch = data.match(/\[(on|off)\]/)
                if (muteMatch) {
                    root.fallbackMuted = muteMatch[1] === "off"
                }
            }
        }
        onExited: checkAlsaResult()
    }

    Process {
        id: alsaSetVolumeProcess
        command: ["sh", "-c", "amixer sset Master PLACEHOLDER 2>/dev/null || amixer sset PCM PLACEHOLDER 2>/dev/null || amixer sset 'Headphone' PLACEHOLDER 2>/dev/null"]
    }

    Process {
        id: alsaToggleMuteProcess
        command: ["sh", "-c", "amixer sset Master toggle 2>/dev/null || amixer sset PCM toggle 2>/dev/null || amixer sset 'Headphone' toggle 2>/dev/null"]
    }

    // Update timer for fallback systems
    Timer {
        id: updateTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateFallbackVolume()
    }

    // Audio system detection on startup
    Timer {
        id: detectionTimer
        interval: 100
        running: true
        repeat: false
        onTriggered: detectAudioSystem()
    }

    Component.onCompleted: {
        // Start audio system detection after component is ready
        detectionTimer.start()
    }

    // Volume popup
    VolumePopup {
        id: volumePopup
        parentWidget: root
    }

    function detectAudioSystem() {
        // Test Pipewire first
        if (Pipewire.ready && sink?.audio) {
            audioSystem = "pipewire"
            pipewireAvailable = true
            console.log("Volume: Using Pipewire")
            return
        }

        // Test PulseAudio
        pulseGetSinkProcess.running = true
    }

    function checkPulseAudioResult() {
        if (pulseaudioAvailable) {
            audioSystem = "pulseaudio"
            console.log("Volume: Using PulseAudio fallback")
            updateFallbackVolume()
            return
        }

        // Test ALSA as last resort
        alsaGetVolumeProcess.running = true
    }

    function checkAlsaResult() {
        if (alsaAvailable) {
            audioSystem = "alsa"
            console.log("Volume: Using ALSA fallback")
            updateFallbackVolume()
        } else {
            console.log("Volume: No audio system detected")
            audioSystem = "none"
        }
    }

    function updateFallbackVolume() {
        if (audioSystem === "pulseaudio" && fallbackSink) {
            pulseGetVolumeProcess.running = true
            pulseGetMuteProcess.running = true
        } else if (audioSystem === "alsa") {
            alsaGetVolumeProcess.running = true
        }
    }

    function toggleMute() {
        if (audioSystem === "pipewire" && sink?.audio) {
            sink.audio.muted = !sink.audio.muted
            Qt.callLater(triggerVolumeOSD)
        } else if (audioSystem === "pulseaudio") {
            pulseToggleMuteProcess.running = true
            // Update status after toggle
            Qt.callLater(() => {
                pulseGetMuteProcess.running = true
                Qt.callLater(triggerVolumeOSD)
            })
        } else if (audioSystem === "alsa") {
            alsaToggleMuteProcess.running = true
            // Update status after toggle
            Qt.callLater(() => {
                alsaGetVolumeProcess.running = true
                Qt.callLater(triggerVolumeOSD)
            })
        }
    }

    function triggerVolumeOSD() {
        // Trigger OSD by updating global properties that VolumeOSD watches
        // Using a simple approach - set a global property
        if (typeof globalThis !== 'undefined') {
            globalThis.lastVolumeChange = {
                volume: volumeLevel,
                muted: isMuted,
                timestamp: Date.now()
            }
        }
    }

    function changeVolume(delta) {
        if (audioSystem === "pipewire" && sink?.audio) {
            var newVol = sink.audio.volume + (delta / 100)
            sink.audio.volume = Math.max(0, Math.min(1.5, newVol))
            Qt.callLater(triggerVolumeOSD)
        } else if (audioSystem === "pulseaudio") {
            const currentVol = fallbackVolume
            const newVol = Math.max(0, Math.min(150, currentVol + delta))
            pulseSetVolumeProcess.command = ["sh", "-c", `pactl set-sink-volume "${fallbackSink}" ${newVol}%`]
            pulseSetVolumeProcess.running = true
            // Update after change
            Qt.callLater(() => {
                pulseGetVolumeProcess.running = true
                Qt.callLater(triggerVolumeOSD)
            })
        } else if (audioSystem === "alsa") {
            const currentVol = fallbackVolume
            const newVol = Math.max(0, Math.min(150, currentVol + delta))
            alsaSetVolumeProcess.command = ["sh", "-c", `amixer sset Master ${newVol}% 2>/dev/null || amixer sset PCM ${newVol}% 2>/dev/null || amixer sset 'Headphone' ${newVol}% 2>/dev/null`]
            alsaSetVolumeProcess.running = true
            // Update after change
            Qt.callLater(() => {
                alsaGetVolumeProcess.running = true
                Qt.callLater(triggerVolumeOSD)
            })
        }
    }

    function showPopup() {
        if (volumePopup.visible) {
            volumePopup.hide()
        } else {
            volumePopup.show(volumeTextWrapper)
        }
    }

    function mediaPlayPause() {
        if (currentPlayer) {
            if (isPlaying) {
                currentPlayer.pause()
            } else {
                currentPlayer.play()
            }
        }
    }

    function mediaNext() {
        if (currentPlayer && canGoNext) {
            currentPlayer.next()
        }
    }

    function mediaPrevious() {
        if (currentPlayer && canGoPrevious) {
            currentPlayer.previous()
        }
    }

    // Hover detection area (behind everything)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered: root.hovered = true
        onExited: root.hovered = false
        propagateComposedEvents: true

        // Handle wheel events for volume
        onWheel: wheel => {
            const delta = wheel.angleDelta.y > 0 ? 5 : -5
            root.changeVolume(delta)
        }
    }

    // Row anchored to the right, so it expands leftward
    Row {
        id: volumeRow
        anchors.right: parent.right
        anchors.rightMargin: GlobalConfig.widgetPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        layoutDirection: Qt.RightToLeft  // Layout from right to left

        // Volume text (rightmost, stays in place)
        Item {
            id: volumeTextWrapper
            width: volumeText.implicitWidth
            height: volumeText.implicitHeight

            Text {
                id: volumeText
                anchors.centerIn: parent
                text: isMuted ? " MUTE" : volumeIcon + " " + volumeLevel + "%"
                color: volumeColor
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontSize
                font.weight: GlobalConfig.fontWeight
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        root.showPopup()
                    } else if (mouse.button === Qt.MiddleButton) {
                        root.toggleMute()
                    } else if (mouse.button === Qt.RightButton) {
                        root.toggleMute()
                    }
                }
            }
        }

        // Media controls and info - slide in on hover when media is available (expands to the left)
        Row {
            spacing: 5
            width: showMedia ? implicitWidth : 0
            clip: true
            layoutDirection: Qt.RightToLeft  // Keep controls in right order when expanding left

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            // Track info (leftmost of the media section)
            Text {
                text: trackArtist ? trackArtist + " - " + trackTitle : trackTitle
                color: GlobalConfig.foregroundColor
                font.family: GlobalConfig.fontFamily
                font.pixelSize: GlobalConfig.fontSize
                font.weight: GlobalConfig.fontWeight
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                maximumLineCount: 1
                width: Math.min(implicitWidth, 200)
            }

            // Previous button
            Item {
                width: prevText.implicitWidth
                height: prevText.implicitHeight

                Text {
                    id: prevText
                    text: ""
                    color: canGoPrevious ? GlobalConfig.foregroundColor : GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: GlobalConfig.fontWeight
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: canGoPrevious
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.mediaPrevious()
                }
            }

            // Play/Pause button
            Item {
                width: playText.implicitWidth
                height: playText.implicitHeight

                Text {
                    id: playText
                    text: isPlaying ? "" : ""
                    color: canPlay ? GlobalConfig.foregroundColor : GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: GlobalConfig.fontWeight
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: canPlay
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.mediaPlayPause()
                }
            }

            // Next button
            Item {
                width: nextText.implicitWidth
                height: nextText.implicitHeight

                Text {
                    id: nextText
                    text: ""
                    color: canGoNext ? GlobalConfig.foregroundColor : GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize
                    font.weight: GlobalConfig.fontWeight
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: canGoNext
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.mediaNext()
                }
            }
        }
    }
}
