import QtQuick
import Quickshell
import "services"
import "ui"

// Month calendar under the clock island. Weeks start on Monday.
PopupWindow {
    id: root

    readonly property date today: Time.date
    // First day of the month being shown.
    property date shown: new Date(today.getFullYear(), today.getMonth(), 1)

    readonly property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    // 42 cells (6 weeks) starting on the Monday on or before the 1st.
    readonly property var cells: {
        const first = new Date(shown.getFullYear(), shown.getMonth(), 1)
        const offset = (first.getDay() + 6) % 7
        const days = []
        for (let i = 0; i < 42; i++)
            days.push(new Date(first.getFullYear(), first.getMonth(), 1 - offset + i))
        return days
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate()
    }

    function moveMonth(delta) {
        root.shown = new Date(shown.getFullYear(), shown.getMonth() + delta, 1)
    }

    onVisibleChanged: {
        if (visible)
            root.shown = new Date(today.getFullYear(), today.getMonth(), 1)
    }

    // Same transparent gap strip as the Control Center (negative anchor
    // margins are ignored).
    readonly property int gap: 8
    readonly property int cell: 38

    implicitWidth: 7 * cell + 2 * Theme.padding
    implicitHeight: layout.implicitHeight + 2 * Theme.padding + gap
    color: "transparent"

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: root.gap
        color: Theme.popupBackground
        border.color: Theme.outline
        radius: Theme.popupRadius

        Column {
            id: layout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.padding
            spacing: 8

            // Today, in full.
            Column {
                width: parent.width
                spacing: 1

                Text {
                    text: Qt.formatDate(root.today, "dddd")
                    color: Theme.muted
                    font.pixelSize: Theme.subtitleSize
                }

                Text {
                    text: Qt.formatDate(root.today, "d MMMM yyyy")
                    color: Theme.foreground
                    font.pixelSize: Theme.headerSize
                    font.bold: true
                }
            }

            // Month switcher.
            Item {
                width: parent.width
                height: 30

                CCButton {
                    id: prev
                    size: 28
                    icon: ""
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.moveMonth(-1)
                }

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDate(root.shown, "MMMM yyyy")
                    color: Theme.foreground
                    font.pixelSize: Theme.titleSize
                    font.bold: true

                    MouseArea {
                        anchors.fill: parent
                        // Click the month name to jump back to today.
                        onClicked: root.shown = new Date(root.today.getFullYear(), root.today.getMonth(), 1)
                    }
                }

                CCButton {
                    size: 28
                    icon: ""
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.moveMonth(1)
                }
            }

            Rectangle {
                width: parent.width
                height: grid.implicitHeight + 8
                radius: Theme.tileRadius
                color: Theme.chip

                MouseArea {
                    anchors.fill: parent
                    onWheel: wheel => root.moveMonth(wheel.angleDelta.y > 0 ? -1 : 1)
                }

                Grid {
                    id: grid
                    anchors.centerIn: parent
                    columns: 7

                    Repeater {
                        model: root.weekdays

                        Text {
                            required property string modelData
                            required property int index
                            width: root.cell - 2
                            height: 24
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                            color: index >= 5 ? Theme.muted : Theme.mutedSelected
                            font.pixelSize: Theme.subtitleSize
                            font.bold: true
                        }
                    }

                    Repeater {
                        model: root.cells

                        Item {
                            id: day
                            required property var modelData
                            readonly property bool isToday: root.sameDay(modelData, root.today)
                            readonly property bool inMonth: modelData.getMonth() === root.shown.getMonth()

                            width: root.cell - 2
                            height: 32

                            Rectangle {
                                anchors.centerIn: parent
                                width: 28
                                height: 28
                                radius: 14
                                color: day.isToday ? Theme.accent : "transparent"
                            }

                            Text {
                                anchors.centerIn: parent
                                text: day.modelData.getDate()
                                color: day.isToday ? Theme.accentText
                                    : day.inMonth ? Theme.foreground
                                    : Theme.faint
                                font.pixelSize: Theme.titleSize
                                font.bold: day.isToday
                            }
                        }
                    }
                }
            }
        }
    }
}
