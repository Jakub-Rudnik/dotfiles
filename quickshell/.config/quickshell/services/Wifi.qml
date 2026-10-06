pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: wifi

    readonly property var wifiDevice:
        Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null

    // Prefer a connected interface when there are several (e.g. a dock).
    readonly property var wiredDevice:
        Networking.devices.values.find(d => d.type === DeviceType.Wired && d.connected)
        ?? Networking.devices.values.find(d => d.type === DeviceType.Wired)
        ?? null

    readonly property var activeNetwork: wifiDevice
        ? wifiDevice.networks.values.find(n => n.connected) ?? null
        : null

    readonly property bool isConnected:
        wifiDevice !== null && wifiDevice.connected

    readonly property bool wiredConnected:
        wiredDevice !== null && wiredDevice.connected

    readonly property real strength:
        activeNetwork ? activeNetwork.signalStrength : 0

    // Detected networks, strongest signal first.
    readonly property var networks: wifiDevice
        ? wifiDevice.networks.values
            .filter(n => n.name !== "")
            .sort((a, b) => b.signalStrength - a.signalStrength)
        : []

    // Interface carrying the default route. NetworkManager gives wired a lower
    // metric (100) than Wi-Fi (600), so wired wins when both are connected.
    property string routeDevice: ""
    readonly property var primaryDevice:
        Networking.devices.values.find(d => d.name === routeDevice && d.connected)
        ?? (wiredConnected ? wiredDevice : isConnected ? wifiDevice : null)

    function strengthIcon(strength, secured) {
        const icons = secured
            ? ["\udb82\udd21", "\udb82\udd24", "\udb82\udd27", "\udb82\udd2a"]
            : ["\udb82\udd1f", "\udb82\udd22", "\udb82\udd25", "\udb82\udd28"]
        return strength <= 0.25 ? icons[0] :
            strength <= 0.50 ? icons[1] :
            strength <= 0.75 ? icons[2] : icons[3]
    }

    function isSecured(network) {
        return network.security !== WifiSecurityType.Open
            && network.security !== WifiSecurityType.Owe
    }

    // Changes whenever any interface changes state; refresh the route then.
    readonly property string devicesState:
        Networking.devices.values.map(d => d.name + ":" + d.state).join(",")
    onDevicesStateChanged: routeRefresh.restart()

    Timer {
        id: routeRefresh
        interval: 500
        onTriggered: {
            if (routeQuery.running)
                routeRefresh.restart()
            else
                routeQuery.running = true
        }
    }

    Process {
        id: routeQuery
        command: ["ip", "-j", "route", "get", "1.1.1.1"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    wifi.routeDevice = JSON.parse(text)[0]?.dev ?? ""
                } catch (error) {
                    wifi.routeDevice = ""
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                wifi.routeDevice = ""
        }
    }
}
