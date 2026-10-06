import QtQuick

// Karta w oknie szczegółów: ikona, tytuł, podtytuł i opcjonalna wartość po prawej.
Rectangle {
    id: root
    property alias icon: iconLabel.text
    property alias title: titleLabel.text
    property alias subtitle: subtitleLabel.text
    property alias trailing: trailingLabel.text
    property bool selected: false
    readonly property color contentColor: selected ? Theme.background : Theme.foreground
    readonly property color mutedColor: selected ? Theme.mutedSelected : Theme.muted
    signal clicked()

    implicitHeight: Math.max(Theme.widgetHeight, texts.implicitHeight + 2 * Theme.cardPadding)

    color: root.selected ? Theme.foreground : Theme.background
    border.color: Theme.outline
    radius: Theme.radius

    Text {
        id: iconLabel
        visible: text !== ""
        width: visible ? Theme.cardIconSize : 0
        anchors.left: parent.left
        anchors.leftMargin: Theme.cardPadding
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        color: root.contentColor
        font.family: Theme.iconFont
        font.pixelSize: Theme.cardIconSize
    }

    Column {
        id: texts
        anchors.left: iconLabel.right
        anchors.leftMargin: iconLabel.visible ? Theme.cardPadding : 0
        anchors.right: trailingLabel.left
        anchors.rightMargin: trailingLabel.visible ? Theme.cardPadding : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            id: titleLabel
            width: parent.width
            elide: Text.ElideRight
            color: root.contentColor
            font.pixelSize: Theme.titleSize
        }

        Text {
            id: subtitleLabel
            visible: text !== ""
            width: parent.width
            elide: Text.ElideRight
            color: root.mutedColor
            font.pixelSize: Theme.subtitleSize
        }
    }

    Text {
        id: trailingLabel
        visible: text !== ""
        anchors.right: parent.right
        anchors.rightMargin: Theme.cardPadding
        anchors.verticalCenter: parent.verticalCenter
        color: root.mutedColor
        font.pixelSize: Theme.subtitleSize
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
