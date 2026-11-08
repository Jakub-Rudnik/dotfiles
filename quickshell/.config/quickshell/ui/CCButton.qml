import QtQuick

// Round icon button for the Control Center (session actions, media).
Rectangle {
    id: root
    property string icon: ""
    property bool highlighted: false
    property int size: 34
    signal clicked()

    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: root.highlighted ? Theme.accent
        : mouse.containsMouse ? Theme.chipHover
        : Theme.chip

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.highlighted ? Theme.accentText : Theme.foreground
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
