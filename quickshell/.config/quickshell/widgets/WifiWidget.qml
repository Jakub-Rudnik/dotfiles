import QtQuick
import "../services"
import "../ui"

// Shows the interface carrying traffic: cable when wired is primary, else Wi-Fi strength.
WidgetCard {
    text: Wifi.primaryDevice === null ? "-"
        : Wifi.primaryDevice === Wifi.wiredDevice ? "󰈀"
        : Wifi.strengthIcon(Wifi.strength, false)
}
