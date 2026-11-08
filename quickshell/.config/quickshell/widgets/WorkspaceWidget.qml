import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "../ui"

// Occupied workspaces (plus the focused one) with the icons of their apps.
Row {
    id: root
    spacing: Theme.spacing

    readonly property int maxIcons: 3

    // Wayland app id, falling back to the Hyprland window class.
    function appId(toplevel) {
        return toplevel.wayland?.appId || toplevel.lastIpcObject?.class || ""
    }

    function iconFor(id) {
        // Desktop entries load lazily and asynchronously; reading the list makes
        // bindings calling this re-run once it is populated.
        DesktopEntries.applications.values
        // Lowercase retry: e.g. Spotify's class is "Spotify", its StartupWMClass "spotify".
        const entry = DesktopEntries.heuristicLookup(id)
            ?? DesktopEntries.heuristicLookup(id.toLowerCase())
        // "" when the theme has no such icon; the tile then shows a letter instead.
        return Quickshell.iconPath(entry?.icon || id, true)
    }

    Repeater {
        model: Hyprland.workspaces.values
            .filter(ws => ws.id > 0 && (ws.focused || ws.toplevels.values.length > 0))
            .sort((a, b) => a.id - b.id)

        Rectangle {
            id: tile
            required property HyprlandWorkspace modelData
            readonly property bool selected: modelData.focused
            // One icon per app, in window order.
            readonly property var apps: [...new Set(modelData.toplevels.values.map(root.appId))]
                .filter(id => id !== "")

            implicitWidth: content.implicitWidth + 2 * Theme.cardPadding
            implicitHeight: Theme.widgetHeight
            color: selected ? Theme.selected : hover.containsMouse ? Theme.chip : "transparent"
            radius: height / 2

            Behavior on color { ColorAnimation { duration: 120 } }

            Row {
                id: content
                anchors.centerIn: parent
                spacing: Theme.spacing

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: tile.modelData.id
                    font.bold: true
                    color: Theme.foreground
                }

                Repeater {
                    model: tile.apps.slice(0, root.maxIcons)

                    Item {
                        id: app
                        required property string modelData
                        readonly property string icon: root.iconFor(modelData)
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 16
                        implicitHeight: 16

                        IconImage {
                            anchors.fill: parent
                            visible: app.icon !== ""
                            source: app.icon
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: app.icon === ""
                            color: "transparent"
                            border.color: Theme.foreground
                            radius: 3

                            Text {
                                anchors.centerIn: parent
                                text: app.modelData.charAt(0).toUpperCase()
                                font.pixelSize: 10
                                font.bold: true
                                color: Theme.foreground
                            }
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: tile.apps.length > root.maxIcons
                    text: "+" + (tile.apps.length - root.maxIcons)
                    font.pixelSize: 10
                    color: tile.selected ? Theme.mutedSelected : Theme.muted
                }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: tile.modelData.activate()
            }
        }
    }
}
