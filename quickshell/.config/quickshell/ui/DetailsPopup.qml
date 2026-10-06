import QtQuick
import Quickshell

PopupWindow {
    id: popup
    default property alias content: body.data
    property string title: ""
    property string subtitle: ""

    implicitWidth: Theme.popupWidth
    implicitHeight: layout.implicitHeight + 2 * Theme.padding
    visible: false
    color: "transparent"

    // Pod widgetem, rozwija się w lewo.
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.bottom: Theme.spacing

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        border.color: Theme.outline
        radius: Theme.radius

        Column {
            id: layout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.padding
            spacing: Theme.sectionSpacing

            Column {
                visible: popup.title !== ""
                width: parent.width
                spacing: 2

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: popup.title
                    color: Theme.foreground
                    font.pixelSize: Theme.headerSize
                    font.bold: true
                }

                Text {
                    visible: text !== ""
                    width: parent.width
                    elide: Text.ElideRight
                    text: popup.subtitle
                    color: Theme.muted
                    font.pixelSize: Theme.subtitleSize
                }
            }

            Column {
                id: body
                width: parent.width
                spacing: Theme.sectionSpacing
            }
        }
    }
}
