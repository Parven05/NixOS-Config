import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import ".."

PopupWindow {
    id: root
    color: "transparent"
    visible: false

    // Ensure cleanup on destruction
    Component.onDestruction: {
        PopupManager.unregisterPopup(root)
    }

    readonly property int popupWidth: 280
    readonly property int popupPadding: 12
    readonly property int sliderWidth: 180

    implicitWidth: popupWidth
    implicitHeight: Math.min(380, contentColumn.implicitHeight + popupPadding * 2)

    property var anchorItem: null
    property bool showContent: false

    onVisibleChanged: {
        if (visible) {
            PopupManager.registerPopup(root)
        } else {
            PopupManager.unregisterPopup(root)
            showContent = false  // Reset state when hidden
        }
    }

    anchor.item: anchorItem
    anchor.rect.x: -(popupWidth / 2) + (anchorItem?.width ?? 0) / 2
    anchor.rect.y: -implicitHeight - GlobalConfig.popupGap

    property real localVolume: 0
    property bool localVolumeChanging: false

    // Reference the parent widget's audio system and volume properties
    property var parentWidget: null
    
    readonly property PwNode sink: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property real volume: parentWidget ? parentWidget.volumeLevel / 100.0 : (sink?.audio?.volume ?? 0)
    readonly property bool muted: parentWidget ? parentWidget.isMuted : (sink?.audio?.muted ?? false)

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    PwNodeLinkTracker {
        id: sinkLinkTracker
        node: root.sink
    }

    // Media player properties
    readonly property var currentPlayer: {
        if (!Mpris.players || Mpris.players.values.length === 0) return null
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

    function mediaPlayPause() {
        if (currentPlayer) {
            if (isPlaying) currentPlayer.pause()
            else currentPlayer.play()
        }
    }

    function mediaNext() {
        if (currentPlayer && canGoNext) currentPlayer.next()
    }

    function mediaPrevious() {
        if (currentPlayer && canGoPrevious) currentPlayer.previous()
    }

    readonly property var appStreams: {
        if (!Pipewire.ready || !sink) return []
        var connectedStreamIds = {}
        var connectedStreams = []
        var intermediateNodeIds = {}
        if (!sinkLinkTracker.linkGroups) return []
        var linkGroupsCount = sinkLinkTracker.linkGroups.length ?? sinkLinkTracker.linkGroups.count ?? 0
        for (var i = 0; i < linkGroupsCount; i++) {
            var linkGroup = sinkLinkTracker.linkGroups.get ? sinkLinkTracker.linkGroups.get(i) : sinkLinkTracker.linkGroups[i]
            if (!linkGroup?.source) continue
            var sourceNode = linkGroup.source
            if (sourceNode.isStream && sourceNode.audio) {
                if (!connectedStreamIds[sourceNode.id]) {
                    connectedStreamIds[sourceNode.id] = true
                    connectedStreams.push(sourceNode)
                }
            } else {
                intermediateNodeIds[sourceNode.id] = true
            }
        }
        if (Object.keys(intermediateNodeIds).length > 0 || connectedStreams.length === 0) {
            try {
                var allNodes = Pipewire.nodes?.values || []
                for (var j = 0; j < allNodes.length; j++) {
                    var node = allNodes[j]
                    if (!node?.isStream || !node.audio) continue
                    if (connectedStreamIds[node.id]) continue
                    var props = node.properties || {}
                    if (props["stream.capture.sink"] !== undefined) continue
                    var mediaClass = props["media.class"] || ""
                    if (mediaClass.includes("Capture") || mediaClass === "Stream/Input") continue
                    connectedStreamIds[node.id] = true
                    connectedStreams.push(node)
                }
            } catch (e) {}
        }
        return connectedStreams
    }

    PwObjectTracker { objects: root.appStreams }

    Component.onCompleted: { localVolume = volume }

    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() {
            if (!localVolumeChanging) localVolume = root.volume
        }
    }

    // Auto-hide timer
    Timer {
        id: autoHideTimer
        interval: 5000
        repeat: false
        onTriggered: {
            if (!popupMouseArea.containsMouse) {
                root.hide()
            } else {
                autoHideTimer.restart()
            }
        }
    }

    Timer {
        id: hideTimer
        interval: GlobalConfig.popupAnimationDuration
        onTriggered: root.visible = false
    }

    function show(item) {
        hideTimer.stop()  // Stop any pending hide
        anchorItem = item
        localVolume = volume
        visible = true
        forceActiveFocus()
        autoHideTimer.start()
        Qt.callLater(() => {
            root.anchor.updateAnchor()
            showContent = true
        })
    }

    function hide() {
        showContent = false
        autoHideTimer.stop()
        hideTimer.start()
    }

    function setVolume(val) {
        if (parentWidget) {
            parentWidget.changeVolume(Math.round((val - volume) * 100))
        } else if (sink?.audio) {
            sink.audio.volume = Math.max(0, Math.min(1.5, val))
        }
    }

    function toggleMute() {
        if (parentWidget) {
            parentWidget.toggleMute()
        } else if (sink?.audio) {
            sink.audio.muted = !sink.audio.muted
        }
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.hide()
    }

    // Main mouse area to track if mouse is inside popup
    MouseArea {
        id: popupMouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton

        onContainsMouseChanged: {
            if (containsMouse) {
                autoHideTimer.stop()
            } else if (root.visible) {
                autoHideTimer.restart()
            }
        }
    }

    PopupBackground {
        anchors.fill: parent
        showPopup: root.showContent

        Flickable {
            anchors.fill: parent
            anchors.margins: root.popupPadding
            contentHeight: contentColumn.implicitHeight
            clip: true
            interactive: contentHeight > height

            Column {
                id: contentColumn
                width: parent.width
                spacing: 10

                // Media player section (only visible when something is playing)
                Column {
                    width: parent.width
                    spacing: 4
                    visible: hasPlayer && trackTitle !== ""

                    Text {
                        text: "NOW PLAYING"
                        color: GlobalConfig.dimmedColor
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize - 2
                        font.weight: Font.Bold
                    }

                    // Track info
                    Column {
                        width: parent.width
                        spacing: 2

                        Text {
                            text: trackTitle
                            color: GlobalConfig.foregroundColor
                            font.family: GlobalConfig.fontFamily
                            font.pixelSize: GlobalConfig.fontSize
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: trackArtist
                            color: GlobalConfig.dimmedColor
                            font.family: GlobalConfig.fontFamily
                            font.pixelSize: GlobalConfig.fontSize - 1
                            elide: Text.ElideRight
                            width: parent.width
                            visible: trackArtist !== ""
                        }
                    }

                    // Play/Pause control
                    Rectangle {
                        width: 32; height: 32
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: GlobalConfig.popupRadius > 0 ? GlobalConfig.popupRadius / 2 : 0
                        color: playArea.containsMouse ? GlobalConfig.activeColor : "transparent"
                        opacity: canPlay ? 1.0 : 0.3

                        Text {
                            anchors.centerIn: parent
                            text: isPlaying ? "󰏤" : "󰐊"
                            color: playArea.containsMouse ? GlobalConfig.backgroundColor : GlobalConfig.foregroundColor
                            font.family: GlobalConfig.iconFont
                            font.pixelSize: GlobalConfig.fontSize + 2
                        }

                        MouseArea {
                            id: playArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: canPlay
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.mediaPlayPause()
                        }
                    }
                }

                Rectangle {
                    width: parent.width; height: 1
                    color: GlobalConfig.borderColor
                    visible: hasPlayer && trackTitle !== ""
                }

                Text {
                    text: "VOLUME"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize - 2
                    font.weight: Font.Bold
                }

                Column {
                    width: parent.width
                    spacing: 4

                    Row {
                        width: parent.width
                        spacing: 8

                        Rectangle {
                            width: 24; height: 24
                            radius: GlobalConfig.popupRadius > 0 ? GlobalConfig.popupRadius / 3 : 0
                            color: muteArea.containsMouse ? GlobalConfig.activeColor : "transparent"
                            border.width: 1
                            border.color: root.muted ? GlobalConfig.urgentColor : GlobalConfig.borderColor

                            Text {
                                anchors.centerIn: parent
                                text: root.muted ? "󰖁" : "󰕾"
                                color: root.muted ? GlobalConfig.urgentColor : GlobalConfig.foregroundColor
                                font.family: GlobalConfig.iconFont
                                font.pixelSize: GlobalConfig.fontSize + 2
                            }
                            MouseArea {
                                id: muteArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.toggleMute()
                            }
                        }

                        Item {
                            width: root.sliderWidth; height: 24
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width; height: 4
                                radius: 2
                                color: GlobalConfig.borderColor
                                Rectangle {
                                    width: parent.width * Math.min(1, localVolume)
                                    height: parent.height
                                    radius: 2
                                    color: root.muted ? GlobalConfig.dimmedColor : GlobalConfig.goodColor
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onPressed: mouse => {
                                    localVolumeChanging = true
                                    localVolume = mouse.x / width
                                    root.setVolume(localVolume)
                                }
                                onPositionChanged: mouse => {
                                    if (pressed) {
                                        localVolume = Math.max(0, Math.min(1.5, mouse.x / width))
                                        root.setVolume(localVolume)
                                    }
                                }
                                onReleased: { localVolumeChanging = false }
                            }
                        }

                        Text {
                            width: 44
                            text: Math.round(localVolume * 100) + "%  "
                            color: GlobalConfig.foregroundColor
                            font.family: GlobalConfig.fontFamily
                            font.pixelSize: GlobalConfig.fontSize
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Text {
                        text: root.sink?.description || "No output device"
                        color: GlobalConfig.dimmedColor
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize - 2
                        elide: Text.ElideRight
                        width: parent.width
                        leftPadding: 32
                    }
                }

                Rectangle {
                    width: parent.width; height: 1
                    color: GlobalConfig.borderColor
                    visible: appStreamsRepeater.count > 0
                }

                Text {
                    text: "MIXER"
                    color: GlobalConfig.dimmedColor
                    font.family: GlobalConfig.fontFamily
                    font.pixelSize: GlobalConfig.fontSize - 2
                    font.weight: Font.Bold
                    visible: appStreamsRepeater.count > 0
                }

                Column {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        id: appStreamsRepeater
                        model: root.appStreams

                        Column {
                            id: appItem
                            required property PwNode modelData
                            width: parent.width
                            spacing: 2

                            property PwNodeAudio nodeAudio: modelData?.audio ?? null
                            property real appVolume: nodeAudio?.volume ?? 0
                            property bool appMuted: nodeAudio?.muted ?? false
                            property real localAppVolume: appVolume
                            property bool localAppVolumeChanging: false

                            PwObjectTracker { objects: modelData ? [modelData] : [] }
                            Connections {
                                target: appItem.nodeAudio
                                function onVolumeChanged() {
                                    if (!appItem.localAppVolumeChanging) appItem.localAppVolume = appItem.appVolume
                                }
                            }
                            Component.onCompleted: { localAppVolume = appVolume }

                            readonly property string appName: {
                                if (!modelData) return "Unknown"
                                var props = modelData.properties || {}
                                var name = props["application.name"] || props["media.name"] || modelData.description || modelData.name || ""
                                if (name) return name.charAt(0).toUpperCase() + name.slice(1)
                                return "Unknown"
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: 24; height: 24
                                    radius: GlobalConfig.popupRadius > 0 ? GlobalConfig.popupRadius / 3 : 0
                                    color: appMuteArea.containsMouse ? GlobalConfig.activeColor : "transparent"
                                    border.width: 1
                                    border.color: appItem.appMuted ? GlobalConfig.urgentColor : GlobalConfig.borderColor

                                    Text {
                                        anchors.centerIn: parent
                                        text: appItem.appMuted ? "󰖁" : "󰕾"
                                        color: appItem.appMuted ? GlobalConfig.urgentColor : GlobalConfig.foregroundColor
                                        font.family: GlobalConfig.iconFont
                                        font.pixelSize: GlobalConfig.fontSize + 2
                                    }
                                    MouseArea {
                                        id: appMuteArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: { if (appItem.nodeAudio) appItem.nodeAudio.muted = !appItem.appMuted }
                                    }
                                }

                                Item {
                                    width: root.sliderWidth; height: 24
                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width; height: 4
                                        radius: 2
                                        color: GlobalConfig.borderColor
                                        Rectangle {
                                            width: parent.width * Math.min(1, appItem.localAppVolume)
                                            height: parent.height
                                            radius: 2
                                            color: appItem.appMuted ? GlobalConfig.dimmedColor : GlobalConfig.activeColor
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: mouse => {
                                            appItem.localAppVolumeChanging = true
                                            appItem.localAppVolume = mouse.x / width
                                            if (appItem.nodeAudio) appItem.nodeAudio.volume = appItem.localAppVolume
                                        }
                                        onPositionChanged: mouse => {
                                            if (pressed) {
                                                appItem.localAppVolume = Math.max(0, Math.min(1.5, mouse.x / width))
                                                if (appItem.nodeAudio) appItem.nodeAudio.volume = appItem.localAppVolume
                                            }
                                        }
                                        onReleased: { appItem.localAppVolumeChanging = false }
                                    }
                                }

                                Text {
                                    width: 40
                                    text: Math.round(appItem.localAppVolume * 100) + "%"
                                    color: GlobalConfig.foregroundColor
                                    font.family: GlobalConfig.fontFamily
                                    font.pixelSize: GlobalConfig.fontSize
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            Text {
                                text: appItem.appName
                                color: GlobalConfig.dimmedColor
                                font.family: GlobalConfig.fontFamily
                                font.pixelSize: GlobalConfig.fontSize - 2
                                elide: Text.ElideRight
                                width: parent.width
                                leftPadding: 32
                            }
                        }
                    }

                    Text {
                        visible: appStreamsRepeater.count === 0
                        text: "No applications playing audio"
                        color: GlobalConfig.dimmedColor
                        font.family: GlobalConfig.fontFamily
                        font.pixelSize: GlobalConfig.fontSize - 1
                        font.italic: true
                    }
                }
            }
        }
    }
}
