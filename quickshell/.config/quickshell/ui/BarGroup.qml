import QtQuick

// A group of bar widgets. In islands mode it is drawn as a floating glass
// pill; in full mode it is transparent and the bar background shows instead.
Rectangle {
    id: root
    default property alias content: row.data
    property bool highlighted: false
    readonly property int inset: (Theme.barHeight - Theme.widgetHeight) / 2

    implicitWidth: row.implicitWidth + 2 * inset
    implicitHeight: Theme.barHeight

    radius: height / 2
    color: root.highlighted ? Theme.selected
        : Settings.islands ? Theme.background
        : "transparent"
    border.color: Settings.islands ? Theme.outline : "transparent"

    Behavior on color { ColorAnimation { duration: 120 } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing
    }
}
