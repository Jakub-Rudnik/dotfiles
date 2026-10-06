import QtQuick
import Quickshell
import Quickshell.Io
import "../ui"

Column {
    id: root
    spacing: Theme.sectionSpacing

    property bool active: false

    // Action waiting for a confirming second click.
    property string pendingAction: ""
    property string uptime: ""

    readonly property string summary: root.uptime !== ""
        ? "Up " + root.uptime
        : Quickshell.env("USER") ?? ""

    // Same command as the logout keybind in hyprland.lua.
    readonly property string logoutCommand:
        "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"

    readonly property var actions: [
        { id: "lock", icon: "󰌾", title: "Lock", subtitle: "Lock the screen",
            confirm: false, command: ["sh", "-c", "pgrep -x hyprlock >/dev/null || hyprlock"] },
        { id: "logout", icon: "󰍃", title: "Log out", subtitle: "End the Hyprland session",
            confirm: true, command: ["sh", "-c", root.logoutCommand] },
        { id: "reboot", icon: "󰜉", title: "Restart", subtitle: "Reboot the computer",
            confirm: true, command: ["systemctl", "reboot"] },
        { id: "poweroff", icon: "󰐥", title: "Shut down", subtitle: "Power off the computer",
            confirm: true, command: ["systemctl", "poweroff"] }
    ]

    signal actionTriggered()

    onActiveChanged: {
        root.pendingAction = ""
        if (active)
            uptimeQuery.running = true
    }

    function formatUptime(seconds) {
        const days = Math.floor(seconds / 86400)
        const hours = Math.floor((seconds % 86400) / 3600)
        const minutes = Math.floor((seconds % 3600) / 60)
        return days > 0 ? days + " d " + hours + " h"
            : hours > 0 ? hours + " h " + minutes + " min"
            : minutes + " min"
    }

    function run(action) {
        if (action.confirm && root.pendingAction !== action.id) {
            root.pendingAction = action.id
            return
        }

        root.pendingAction = ""
        root.actionTriggered()
        Quickshell.execDetached(action.command)
    }

    Process {
        id: uptimeQuery
        command: ["cat", "/proc/uptime"]

        stdout: StdioCollector {
            onStreamFinished: {
                const seconds = parseFloat(text.split(" ")[0])
                root.uptime = isNaN(seconds) ? "" : root.formatUptime(seconds)
            }
        }
    }

    DetailSection {
        width: root.width
        title: "Session"

        Repeater {
            model: root.actions

            DetailCard {
                required property var modelData
                readonly property bool pending: root.pendingAction === modelData.id

                width: parent.width
                icon: modelData.icon
                title: modelData.title
                subtitle: pending ? "Click again to confirm" : modelData.subtitle
                selected: pending

                onClicked: root.run(modelData)
            }
        }
    }
}
