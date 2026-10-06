import QtQuick
import "../services"
import "../ui"

Column {
    id: root
    spacing: Theme.sectionSpacing

    function outputName(node) {
        return node?.nickname || node?.description || node?.name || ""
    }

    readonly property string summary: Audio.sink ? outputName(Audio.sink) : "Brak wyjścia audio"

    DetailSection {
        width: root.width
        title: "Głośność"

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
        title: "Wyjście audio"

        Repeater {
            model: Audio.outputs

            DetailCard {
                required property var modelData

                width: parent.width
                title: root.outputName(modelData)
                subtitle: modelData === Audio.sink ? "Aktywne" : ""
                selected: modelData === Audio.sink

                onClicked: Audio.selectOutput(modelData)
            }
        }
    }
}
