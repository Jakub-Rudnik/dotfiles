import QtQuick
import "../services"
import "../ui"

Column {
    id: root
    spacing: Theme.sectionSpacing

    // Discover new devices only while the popup is open.
    property bool active: false

    readonly property string summary: !BluetoothService.available ? "No adapter"
        : !BluetoothService.enabled ? "Off"
        : BluetoothService.connectedDevices.length === 1
            ? "Connected to " + BluetoothService.connectedDevices[0].name
        : BluetoothService.connectedDevices.length > 1
            ? BluetoothService.connectedDevices.length + " devices connected"
        : "No devices connected"

    readonly property int maxAvailable: 6

    onActiveChanged: BluetoothService.setDiscovering(active)

    Connections {
        target: BluetoothService.adapter

        function onEnabledChanged() {
            BluetoothService.setDiscovering(root.active)
        }
    }

    DetailCard {
        width: root.width
        icon: BluetoothService.enabled ? "󰂯" : "󰂲"
        title: "Bluetooth"
        subtitle: BluetoothService.adapter?.name ?? "No adapter"
        trailing: BluetoothService.enabled ? "On" : "Off"
        selected: BluetoothService.enabled

        onClicked: BluetoothService.setEnabled(!BluetoothService.enabled)
    }

    DetailSection {
        width: root.width
        visible: BluetoothService.enabled && BluetoothService.pairedDevices.length > 0
        title: "My devices"

        Repeater {
            model: BluetoothService.pairedDevices

            DetailCard {
                required property var modelData

                width: parent.width
                icon: BluetoothService.deviceIcon(modelData)
                title: modelData.name
                subtitle: BluetoothService.deviceStatus(modelData)
                trailing: modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : ""
                selected: modelData.connected

                onClicked: BluetoothService.toggle(modelData)
            }
        }
    }

    DetailSection {
        width: root.width
        visible: BluetoothService.enabled
        title: "Available"

        Text {
            visible: BluetoothService.availableDevices.length === 0
            text: "Searching…"
            color: Theme.muted
            font.pixelSize: Theme.subtitleSize
        }

        Repeater {
            model: BluetoothService.availableDevices.slice(0, root.maxAvailable)

            DetailCard {
                required property var modelData

                width: parent.width
                icon: BluetoothService.deviceIcon(modelData)
                title: modelData.name
                subtitle: BluetoothService.deviceStatus(modelData)

                onClicked: BluetoothService.toggle(modelData)
            }
        }
    }
}
