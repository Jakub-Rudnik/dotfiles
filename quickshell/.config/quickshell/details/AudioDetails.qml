import QtQuick
import "../services"
import "../ui"

Column {
    id: root
    spacing: Theme.sectionSpacing

    function outputName(node) {
        return node?.nickname || node?.description || node?.name || ""
    }

    readonly property string summary: Audio.sink ? outputName(Audio.sink) : "No audio output"

    DetailSection {
        width: root.width
        title: "Volume"

        Row {
            spacing: Theme.spacing

            WidgetCard {
                text: "−"
                onClicked: Audio.changeVolume(-0.05)
            }

            Text {
                width: 50
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                text: Audio.sink
                    ? Math.round(Audio.volume * 100) + "%"
                    : "—"
                color: Theme.foreground
                font.pixelSize: Theme.titleSize
            }

            WidgetCard {
                text: "+"
                onClicked: Audio.changeVolume(0.05)
            }
        }
    }

    DetailSection {
        width: root.width
        title: "Audio output"

        Repeater {
            model: Audio.outputs

            DetailCard {
                required property var modelData

                width: parent.width
                title: root.outputName(modelData)
                subtitle: modelData === Audio.sink ? "Active" : ""
                selected: modelData === Audio.sink

                onClicked: Audio.selectOutput(modelData)
            }
        }
    }
}
