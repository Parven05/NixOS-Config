import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitHeight: parent ? parent.height : 24
    implicitWidth: Math.min(titleText.contentWidth + 8, 250)

    property string title: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!getTitle.running) getTitle.running = true
        }
    }

    Process {
        id: getTitle
        command: ["sh", "-c", "niri msg focused-window 2>/dev/null | grep 'Title:' | head -1 | sed 's/.*Title: \"\\(.*\\)\"/\\1/'"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.title = text.trim()
            }
        }
    }

    Text {
        id: titleText
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        color: "#6e7681"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        font.weight: Font.Normal
        elide: Text.ElideRight
        maximumLineCount: 1
        width: 600
        clip: true
    }
}
