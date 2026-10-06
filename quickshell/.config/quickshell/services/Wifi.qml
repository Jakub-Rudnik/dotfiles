pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: wifi

    readonly property var wifiDevice:
        Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null

    // Preferuj podłączony interfejs, gdy jest ich kilka (np. stacja dokująca).
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

    // Wykryte sieci, od najsilniejszego sygnału.
    readonly property var networks: wifiDevice
        ? wifiDevice.networks.values
            .filter(n => n.name !== "")
            .sort((a, b) => b.signalStrength - a.signalStrength)
        : []

    // Interfejs, przez który idzie domyślna trasa. NetworkManager daje kablowi
    // niższą metrykę (100) niż Wi-Fi (600), więc przy obu połączeniach wygrywa kabel.
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

    // Zmienia się przy każdej zmianie stanu interfejsów — wtedy odświeżamy trasę.
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
