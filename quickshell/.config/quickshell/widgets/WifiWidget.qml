import QtQuick
import "../services"
import "../ui"

WidgetCard {
    text: Wifi.isConnected ? Wifi.strengthIcon(Wifi.strength, false) : "-"
}