pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var byName: ({})
    // Plugged-in outputs that live in a card profile other than the active one
    // (e.g. Headphones vs Speaker on SOF/UCM cards), so they have no sink yet.
    property var inactiveOutputs: []
    property var pendingOutput: null

    function updateAvailability(sinks) {
        const availability = {};
        for (const sink of sinks) {
            const ports = sink.ports || [];
            availability[sink.name] = ports.length === 0
                || ports.some(port => port.availability !== "not available");
        }
        root.byName = availability;

        if (root.pendingOutput) {
            const pending = root.pendingOutput;
            const sink = sinks.find(sink =>
                sink.properties?.["device.name"] === pending.card
                && (sink.ports || []).some(port => port.name === pending.port));
            if (sink) {
                root.pendingOutput = null;
                pendingTimeout.stop();
                setDefaultSink.command = ["pactl", "set-default-sink", sink.name];
                setDefaultSink.running = true;
            }
        }
    }

    function updateCards(cards) {
        const outputs = [];
        for (const card of cards) {
            for (const [portName, port] of Object.entries(card.ports || {})) {
                if (!portName.startsWith("[Out]")
                        || port.availability === "not available"
                        || (port.profiles || []).includes(card.active_profile))
                    continue;

                const profile = (port.profiles || [])
                    .map(name => ({
                        name: name,
                        available: card.profiles?.[name]?.available,
                        priority: card.profiles?.[name]?.priority,
                    }))
                    .filter(profile => profile.available !== false)
                    .sort((a, b) => (b.priority ?? 0) - (a.priority ?? 0))[0];
                if (!profile)
                    continue;

                outputs.push({
                    card: card.name,
                    port: portName,
                    profile: profile.name,
                    description: port.description || portName,
                });
            }
        }
        root.inactiveOutputs = outputs;
    }

    // Switches the card to the output's profile, then makes its sink default
    // once it shows up in the next sink refresh.
    function activateOutput(output) {
        root.pendingOutput = output;
        pendingTimeout.restart();
        setProfile.command = ["pactl", "set-card-profile", output.card, output.profile];
        setProfile.running = true;
    }

    function refresh() {
        query.running = true;
        cardsQuery.running = true;
    }

    Process {
        id: setProfile
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("AudioAvailability: set-card-profile exited with code", exitCode);
            refreshTimer.restart();
        }
    }

    Process {
        id: setDefaultSink
    }

    Timer {
        id: pendingTimeout
        interval: 3000
        onTriggered: root.pendingOutput = null
    }

    Process {
        id: cardsQuery
        command: ["pactl", "--format=json", "list", "cards"]
        environment: ({ LC_ALL: "C" })
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim())
                    return;

                try {
                    root.updateCards(JSON.parse(text));
                } catch (error) {
                    console.warn("AudioAvailability: invalid pactl cards response:", error);
                }
            }
        }
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
            if (query.running || cardsQuery.running)
                refreshTimer.restart();
            else
                root.refresh();
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
