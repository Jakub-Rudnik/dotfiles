import QtQuick
import Quickshell
import Quickshell.Widgets
import "../services"
import "../ui"

WidgetCard {
    icon: Battery.icon(Battery.percentage, Battery.charging)
    text: Battery.available ? `${Math.round(Battery.percentage * 100)}%` : "-"
}
