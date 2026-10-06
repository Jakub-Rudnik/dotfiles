import QtQuick
import "../services"
import "../ui"

WidgetCard {
    icon: !BluetoothService.enabled ? "󰂲"
        : BluetoothService.connectedDevices.length > 0 ? "󰂱"
        : "󰂯"
}
