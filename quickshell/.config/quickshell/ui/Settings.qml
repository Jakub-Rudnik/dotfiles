pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// User preferences, persisted in Quickshell's state dir.
// Toggle the bar style with: qs ipc call bar toggleStyle
Singleton {
    id: root

    // "islands" (floating pills) or "full" (edge-to-edge bar).
    readonly property string barStyle: adapter.barStyle
    readonly property bool islands: barStyle !== "full"

    function setBarStyle(style) {
        adapter.barStyle = style === "full" ? "full" : "islands"
    }

    FileView {
        path: Quickshell.statePath("settings.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter()
        }

        JsonAdapter {
            id: adapter
            property string barStyle: "islands"
        }
    }

    IpcHandler {
        target: "bar"

        function toggleStyle(): void {
            root.setBarStyle(root.islands ? "full" : "islands")
        }

        function setStyle(style: string): void {
            root.setBarStyle(style)
        }
    }
}
