pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Which screen's Control Center is open ("" when closed).
// From outside: qs ipc call controlCenter toggle
Singleton {
    id: root

    property string screen: ""
    // Page shown when it opens: "", "network", "bluetooth", "sound", "battery".
    property string initialPage: ""

    function toggle(screenName) {
        root.initialPage = ""
        root.screen = root.screen === screenName ? "" : screenName
    }

    function close() {
        root.screen = ""
    }

    IpcHandler {
        target: "controlCenter"

        // Opens on the focused monitor.
        function toggle(): void {
            root.toggle(Hyprland.focusedMonitor?.name ?? "")
        }

        function close(): void {
            root.close()
        }

        // e.g. qs ipc call controlCenter open network
        function open(page: string): void {
            root.close()
            root.initialPage = page
            root.screen = Hyprland.focusedMonitor?.name ?? ""
        }
    }
}
