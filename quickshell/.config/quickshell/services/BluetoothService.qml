pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false

    readonly property var allDevices: adapter ? adapter.devices.values : []

    // Paired devices, connected first.
    readonly property var pairedDevices: allDevices
        .filter(d => d.paired)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))

    // Discovered devices that are not paired yet; nameless ones are skipped.
    readonly property var availableDevices: allDevices
        .filter(d => !d.paired && d.deviceName !== "")
        .sort((a, b) => a.name.localeCompare(b.name))

    readonly property var connectedDevices: allDevices.filter(d => d.connected)

    // Device being paired; connected as soon as pairing succeeds.
    property var pairingDevice: null

    function setEnabled(value) {
        if (root.adapter)
            root.adapter.enabled = value
    }

    function setDiscovering(value) {
        if (root.adapter && root.adapter.enabled && root.adapter.discovering !== value)
            root.adapter.discovering = value
    }

    function toggle(device) {
        if (device.connected)
            device.disconnect()
        else if (device.paired)
            device.connect()
        else {
            root.pairingDevice = device
            device.pair()
        }
    }

    function deviceIcon(device) {
        const icon = device?.icon ?? ""
        return icon.startsWith("audio-head") ? "󰋋"
            : icon.startsWith("audio") ? "󰓃"
            : icon === "input-mouse" ? "󰍽"
            : icon === "input-keyboard" ? "󰌌"
            : icon === "input-gaming" ? "󰊗"
            : icon === "phone" ? "󰄜"
            : icon === "computer" ? "󰌢"
            : "󰂯"
    }

    function deviceStatus(device) {
        return device.state === BluetoothDeviceState.Connecting ? "Connecting…"
            : device.state === BluetoothDeviceState.Disconnecting ? "Disconnecting…"
            : device.pairing ? "Pairing…"
            : device.connected ? "Connected"
            : device.paired ? "Paired"
            : "Not paired"
    }

    Connections {
        target: root.pairingDevice

        function onPairedChanged() {
            const device = root.pairingDevice
            if (!device.paired)
                return
            device.trusted = true
            device.connect()
            root.pairingDevice = null
        }
    }
}
