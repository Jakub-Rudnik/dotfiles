import QtQuick
import Quickshell.Hyprland

Row {
    spacing: 5

    Repeater {
        model: 8

        Rectangle {
            id: title

            required property int index
            readonly property int workspaceId: index + 1
            readonly property bool selected:
                Hyprland.focusedWorkspace !== null &&
                Hyprland.focusedWorkspace.id === workspaceId

            width: 30
            height: 30
            radius: 5
            color: selected ? "#fff" : "#000"
            border.color: "#404040"

            Text {
                anchors.centerIn: parent
                text: title.workspaceId
                color: title.selected ? "#000" : "#fff"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + title.workspaceId)
            }
        }
    }
}