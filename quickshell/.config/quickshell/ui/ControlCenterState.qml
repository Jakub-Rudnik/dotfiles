pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Which screen's Control Center / calendar is open ("" when closed). Only
// one of them is open at a time.
// From outside: qs ipc call controlCenter toggle, qs ipc call calendar toggle
Singleton {
    id: root

    property string screen: ""
    property string calendarScreen: ""
    // Page shown when it opens: "", "network", "bluetooth", "sound", "battery".
    property string initialPage: ""

    function toggle(screenName) {
        root.initialPage = ""
        root.calendarScreen = ""
        root.screen = root.screen === screenName ? "" : screenName
    }

    function toggleCalendar(screenName) {
        root.screen = ""
        root.calendarScreen = root.calendarScreen === screenName ? "" : screenName
    }

    function close() {
        root.screen = ""
        root.calendarScreen = ""
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

    IpcHandler {
        target: "calendar"

        function toggle(): void {
            root.toggleCalendar(Hyprland.focusedMonitor?.name ?? "")
        }
    }
}
