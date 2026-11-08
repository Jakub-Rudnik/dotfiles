pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Laptop panel backlight via brightnessctl. Call refresh() to re-read it
// (brightness keys change it behind our back).
Singleton {
    id: root

    property bool available: false
    property real value: 0      // 0..1

    function refresh() {
        if (!query.running)
            query.running = true
    }

    function set(fraction) {
        const percent = Math.round(Math.max(0.01, Math.min(1, fraction)) * 100)
        root.value = percent / 100
        Quickshell.execDetached(["brightnessctl", "-c", "backlight", "-q", "set", percent + "%"])
    }

    Component.onCompleted: refresh()

    Process {
        id: query
        // Machine-readable: name,class,current,percent,max
        command: ["brightnessctl", "-c", "backlight", "-m"]

        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",")
                const current = parseInt(fields[2])
                const max = parseInt(fields[4])
                root.available = max > 0
                if (root.available)
                    root.value = current / max
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root.available = false
        }
    }
}
