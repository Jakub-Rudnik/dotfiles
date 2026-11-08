import QtQuick

// Control Center tile: round icon (a toggle) plus title and subtitle.
// Clicking the icon emits toggled(), clicking the rest emits clicked().
Rectangle {
    id: root
    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool chevron: false
    signal toggled()
    signal clicked()

    implicitHeight: 52
    radius: Theme.tileRadius
    color: mouse.containsMouse ? Theme.chipHover : Theme.chip

    Behavior on color { ColorAnimation { duration: 120 } }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Rectangle {
        id: badge
        width: 30
        height: 30
        radius: 15
        anchors.left: parent.left
        anchors.leftMargin: Theme.cardPadding
        anchors.verticalCenter: parent.verticalCenter
        color: root.checked ? Theme.accent : Theme.chip

        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.checked ? Theme.accentText : Theme.foreground
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.toggled()
        }
    }

    Column {
        anchors.left: badge.right
        anchors.leftMargin: 8
        anchors.right: arrow.left
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.title
            color: Theme.foreground
            font.pixelSize: Theme.titleSize
            font.bold: true
        }

        Text {
            width: parent.width
            visible: text !== ""
            elide: Text.ElideRight
            text: root.subtitle
            color: Theme.muted
            font.pixelSize: Theme.subtitleSize
        }
    }

    Text {
        id: arrow
        anchors.right: parent.right
        anchors.rightMargin: root.chevron ? Theme.cardPadding : 0
        anchors.verticalCenter: parent.verticalCenter
        width: root.chevron ? implicitWidth : 0
        visible: root.chevron
        text: ""
        color: Theme.muted
        font.family: Theme.iconFont
        font.pixelSize: 10
    }
}
