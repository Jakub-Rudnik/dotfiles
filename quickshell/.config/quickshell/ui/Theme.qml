pragma Singleton

import QtQuick
import Quickshell

// Frosted-glass palette. Colors are #AARRGGBB; the blur itself comes from the
// Hyprland layer rule for the "quickshell" namespace (hyprland.lua).
Singleton {
    readonly property color background: "#731c1c20"       // bar / islands
    readonly property color popupBackground: "#a61c1c20"  // details popups
    readonly property color foreground: "#ffffff"
    readonly property color outline: "#26ffffff"
    readonly property color muted: "#99ffffff"
    readonly property color mutedSelected: "#b3ffffff"
    readonly property color chip: "#1affffff"             // cards, hover
    readonly property color selected: "#40ffffff"         // active chip

    readonly property int barHeight: 34
    readonly property int barMargin: 6                    // islands gap to screen edge
    readonly property int widgetHeight: 26
    readonly property int radius: 8
    readonly property int popupRadius: 14
    readonly property int padding: 12
    readonly property int spacing: 4

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
