pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var byName: ({})

    function updateAvailability(sinks) {
        const availability = {};
        for (const sink of sinks) {
            const ports = sink.ports || [];
            availability[sink.name] = ports.length === 0
                || ports.some(port => port.availability !== "not available");
        }
        root.byName = availability;
    }

    Process {
        id: query
        command: ["pactl", "--format=json", "list", "sinks"]
        environment: ({ LC_ALL: "C" })
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim())
                    return;

                try {
                    root.updateAvailability(JSON.parse(text));
                } catch (error) {
                    console.warn("AudioAvailability: invalid pactl response:", error);
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("AudioAvailability: pactl exited with code", exitCode);
        }
    }

    Timer {
        id: refreshTimer
        interval: 150
        onTriggered: {
            if (query.running)
                refreshTimer.restart();
            else
                query.running = true;
        }
    }

    Process {
        id: subscription
        command: ["pactl", "subscribe"]
        environment: ({ LC_ALL: "C" })
        running: true

        stdout: SplitParser {
            onRead: line => {
                if (/ on (sink|card|server)(?:\s|$)/.test(line))
                    refreshTimer.restart();
            }
        }

        onRunningChanged: {
            if (!running)
                reconnectTimer.restart();
        }
    }

    Timer {
        id: reconnectTimer
        interval: 2000
        onTriggered: {
            subscription.running = true;
            refreshTimer.restart();
        }
    }
}
