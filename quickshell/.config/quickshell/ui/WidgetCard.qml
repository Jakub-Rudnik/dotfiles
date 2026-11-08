import QtQuick

// Bar chip: transparent until hovered or selected. Set flat: false for a
// filled button (e.g. inside popups).
Rectangle {
    id: root
    property alias icon: iconLabel.text
    property alias text: valueLabel.text
    property bool selected: false
    property bool flat: true
    property bool bold: false
    readonly property color contentColor: Theme.foreground
    signal clicked()

    implicitWidth: content.implicitWidth + 2 * Theme.cardPadding
    implicitHeight: Theme.widgetHeight

    color: root.selected ? Theme.selected
        : mouse.containsMouse || !root.flat ? Theme.chip
        : "transparent"
    radius: height / 2

    Behavior on color { ColorAnimation { duration: 120 } }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacing + 1

        Text {
            id: iconLabel
            visible: text != ""
            color: root.contentColor
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
            anchors.verticalCenter: content.verticalCenter
        }

        Text {
            id: valueLabel
            visible: text != ""
            color: root.contentColor
            font.bold: root.bold
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
