pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property color background: "#000000"
    readonly property color foreground: "#ffffff"
    readonly property color outline: "#404040"
    readonly property color muted: "#9a9a9a"
    readonly property color mutedSelected: "#505050"

    readonly property int widgetHeight: 30
    readonly property int radius: 5
    readonly property int padding: 15
    readonly property int spacing: 5

    readonly property int popupWidth: 340
    readonly property int sectionSpacing: 18
    readonly property int cardPadding: 10
    readonly property int cardSpacing: 6

    readonly property int headerSize: 17
    readonly property int titleSize: 13
    readonly property int subtitleSize: 11
    readonly property int sectionSize: 11

    readonly property string iconFont: "Symbols Nerd Font"
    readonly property int iconSize: 15
    readonly property int cardIconSize: 20
}
