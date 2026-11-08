import QtQuick

// Control Center slider: a label row and a pill track with the icon inside
// the filled part. Emits moved(value) while dragging, clicking or scrolling.
Rectangle {
    id: root
    property string title: ""
    property string detail: ""      // small text on the right of the title
    property string icon: ""
    property real value: 0          // 0..1
    property bool chevron: false
    signal moved(real value)
    signal clicked()                 // title row clicked

    implicitHeight: column.implicitHeight + 2 * Theme.cardPadding
    radius: Theme.tileRadius
    color: Theme.chip

    function valueAt(x) {
        return Math.max(0, Math.min(1, x / track.width))
    }

    Column {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.cardPadding
        spacing: 6

        Item {
            width: parent.width
            height: titleText.implicitHeight

            Text {
                id: titleText
                anchors.left: parent.left
                text: root.title
                color: Theme.foreground
                font.pixelSize: Theme.titleSize
                font.bold: true
            }

            Text {
                anchors.left: titleText.right
                anchors.leftMargin: 6
                anchors.right: arrow.left
                anchors.rightMargin: 4
                anchors.baseline: titleText.baseline
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                text: root.detail
                color: Theme.muted
                font.pixelSize: Theme.subtitleSize
            }

            Text {
                id: arrow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: root.chevron ? implicitWidth : 0
                visible: root.chevron
                text: ""
                color: Theme.muted
                font.family: Theme.iconFont
                font.pixelSize: 10
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.chevron
                onClicked: root.clicked()
            }
        }

        Rectangle {
            id: track
            width: parent.width
            height: 22
            radius: height / 2
            color: Theme.chip

            Rectangle {
                // Never narrower than the round end, so the icon always fits.
                width: Math.max(track.height, track.width * root.value)
                height: parent.height
                radius: height / 2
                color: Theme.accent

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.icon
                    color: Theme.accentText
                    font.family: Theme.iconFont
                    font.pixelSize: 12
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressed: mouse => root.moved(root.valueAt(mouse.x))
                onPositionChanged: mouse => {
                    if (pressed)
                        root.moved(root.valueAt(mouse.x))
                }
                onWheel: wheel => root.moved(Math.max(0, Math.min(1,
                    root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
            }
        }
    }
}
