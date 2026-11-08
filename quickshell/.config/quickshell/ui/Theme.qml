pragma Singleton

import QtQuick
import Quickshell

// Frosted-glass palette. Colors are #AARRGGBB; the blur itself comes from the
// Hyprland layer rule for the "quickshell" namespace (hyprland.lua).
Singleton {
    readonly property color background: "#5c202024"       // bar islands
    readonly property color popupBackground: "#6b202024"  // Control Center
    readonly property color foreground: "#ffffff"
    readonly property color outline: "#29ffffff"
    readonly property color muted: "#a6ffffff"
    readonly property color faint: "#59ffffff"            // days outside the month
    readonly property color mutedSelected: "#ccffffff"
    readonly property color chip: "#1affffff"             // tiles, cards
    readonly property color chipHover: "#26ffffff"
    readonly property color selected: "#33ffffff"         // active chip
    readonly property color accent: "#ebffffff"           // "on" toggles, slider fill
    readonly property color accentText: "#141416"

    readonly property int barHeight: 34
    readonly property int barMargin: 6                    // islands gap to screen edge
    readonly property int widgetHeight: 26
    readonly property int radius: 8
    readonly property int popupRadius: 20
    readonly property int tileRadius: 14
    readonly property int padding: 12
    readonly property int spacing: 4

    readonly property int popupWidth: 330
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
