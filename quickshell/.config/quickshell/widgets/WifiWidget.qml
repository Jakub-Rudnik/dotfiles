import QtQuick
import "../services"
import "../ui"

WidgetCard {
    text: Wifi.isConnected ? 
        Wifi.strength <= 0.25 ? "\udb82\udd1f" :
        Wifi.strength <= 0.50 ? "\udb82\udd22" :
        Wifi.strength <= 0.75 ? "\udb82\udd25" : "\udb82\udd28"
        : "-" 
}