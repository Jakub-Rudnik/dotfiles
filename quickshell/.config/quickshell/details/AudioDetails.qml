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

    CCSlider {
        width: root.width
        title: "Volume"
        detail: Audio.sink ? Math.round(Audio.volume * 100) + "%" : "—"
        icon: Audio.muted ? "\ueee8" : "\uf028"
        value: Audio.muted ? 0 : Audio.volume

        onMoved: value => Audio.setVolume(value)
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

        Repeater {
            model: Audio.inactiveOutputs

            DetailCard {
                required property var modelData

                width: parent.width
                title: modelData.description
                subtitle: "Switches card profile"

                onClicked: Audio.selectInactiveOutput(modelData)
            }
        }
    }
}
