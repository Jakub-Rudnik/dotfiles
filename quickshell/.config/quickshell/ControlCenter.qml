import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import Quickshell.Widgets
import "services"
import "ui"
import "details"

// macOS-style Control Center: quick toggles and sliders on the main page,
// the existing details views as sub-pages.
PopupWindow {
    id: root

    // "" for the main page, else "network", "bluetooth", "sound" or "battery".
    property string page: ""
    // Session action waiting for a confirming second click.
    property string pendingAction: ""
    signal closeRequested()

    readonly property var pages: ({
        network: { title: "Network", details: wifiDetails },
        bluetooth: { title: "Bluetooth", details: bluetoothDetails },
        sound: { title: "Sound", details: audioDetails },
        battery: { title: "Battery", details: batteryDetails }
    })

    readonly property bool wired:
        Wifi.primaryDevice !== null && Wifi.primaryDevice === Wifi.wiredDevice

    // Prefer the player that is playing, else the first one.
    readonly property var player:
        Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null

    readonly property var profiles: [
        { profile: PowerProfile.PowerSaver, icon: "󰌪", title: "Power saver" },
        { profile: PowerProfile.Balanced, icon: "󰗑", title: "Balanced" },
        { profile: PowerProfile.Performance, icon: "󰓅", title: "Performance" }
    ].filter(p => p.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)
    readonly property var currentProfile:
        profiles.find(p => p.profile === PowerProfiles.profile) ?? profiles[0]

    // Same command as the logout keybind in hyprland.lua.
    readonly property string logoutCommand:
        "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"

    readonly property var actions: [
        { id: "lock", icon: "󰌾", title: "Lock", confirm: false,
            command: ["sh", "-c", "~/.config/hypr/lock.sh"] },
        { id: "suspend", icon: "󰒲", title: "Suspend", confirm: false,
            command: ["systemctl", "suspend"] },
        { id: "logout", icon: "󰍃", title: "Log out", confirm: true,
            command: ["sh", "-c", root.logoutCommand] },
        { id: "reboot", icon: "󰜉", title: "Restart", confirm: true,
            command: ["systemctl", "reboot"] },
        { id: "poweroff", icon: "󰐥", title: "Shut down", confirm: true,
            command: ["systemctl", "poweroff"] }
    ]

    function run(action) {
        if (action.confirm && root.pendingAction !== action.id) {
            root.pendingAction = action.id
            return
        }
        root.pendingAction = ""
        root.closeRequested()
        Quickshell.execDetached(action.command)
    }

    function volumeIcon() {
        return Audio.muted ? ""
            : Audio.volume <= 0 ? ""
            : Audio.volume <= 0.5 ? ""
            : ""
    }

    function outputName(node) {
        return node?.nickname || node?.description || node?.name || ""
    }

    function nextProfile() {
        const i = root.profiles.indexOf(root.currentProfile)
        PowerProfiles.profile = root.profiles[(i + 1) % root.profiles.length].profile
    }

    onVisibleChanged: {
        root.page = visible ? ControlCenterState.initialPage : ""
        root.pendingAction = ""
        if (visible)
            Brightness.refresh()
    }

    // Brightness keys change the backlight outside of the slider.
    Timer {
        running: root.visible && root.page === ""
        interval: 1000
        repeat: true
        onTriggered: Brightness.refresh()
    }

    implicitWidth: Theme.popupWidth
    // Negative anchor margins are ignored, so the gap below the island is
    // a transparent strip at the top of the popup.
    readonly property int gap: 8
    implicitHeight: layout.implicitHeight + 2 * Theme.padding + gap
    color: "transparent"

    // Below the status island, aligned to its right edge.
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: root.gap
        color: Theme.popupBackground
        border.color: Theme.outline
        radius: Theme.popupRadius

        Column {
            id: layout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.padding
            spacing: 8

            // ---------- Main page ----------

            Row {
                visible: root.page === ""
                width: parent.width
                spacing: 8

                CCTile {
                    width: (parent.width - parent.spacing) / 2
                    checked: Wifi.primaryDevice !== null
                    icon: root.wired ? "󰈀"
                        : Wifi.isConnected ? Wifi.strengthIcon(Wifi.strength, false)
                        : "󰖪"
                    title: root.wired ? "Wired" : "Wi-Fi"
                    subtitle: root.wired
                        ? (Wifi.wiredDevice.linkSpeed > 0 ? Wifi.wiredDevice.linkSpeed + " Mb/s" : "Connected")
                        : !Networking.wifiEnabled ? "Off"
                        : Wifi.activeNetwork ? Wifi.activeNetwork.name
                        : "Not connected"

                    onToggled: {
                        if (root.wired)
                            root.page = "network"
                        else
                            Networking.wifiEnabled = !Networking.wifiEnabled
                    }
                    onClicked: root.page = "network"
                }

                CCTile {
                    width: (parent.width - parent.spacing) / 2
                    checked: BluetoothService.enabled
                    icon: BluetoothService.enabled ? "󰂯" : "󰂲"
                    title: "Bluetooth"
                    subtitle: !BluetoothService.available ? "No adapter"
                        : !BluetoothService.enabled ? "Off"
                        : BluetoothService.connectedDevices.length === 1
                            ? BluetoothService.connectedDevices[0].name
                        : BluetoothService.connectedDevices.length > 1
                            ? BluetoothService.connectedDevices.length + " devices"
                        : "On"

                    onToggled: BluetoothService.setEnabled(!BluetoothService.enabled)
                    onClicked: root.page = "bluetooth"
                }
            }

            CCSlider {
                visible: root.page === ""
                width: parent.width
                title: "Sound"
                detail: root.outputName(Audio.sink)
                icon: root.volumeIcon()
                value: Audio.muted ? 0 : Audio.volume
                chevron: true

                onMoved: value => Audio.setVolume(value)
                onClicked: root.page = "sound"
            }

            CCSlider {
                visible: root.page === "" && Brightness.available
                width: parent.width
                title: "Display"
                detail: Math.round(Brightness.value * 100) + "%"
                icon: "󰃟"
                value: Brightness.value

                onMoved: value => Brightness.set(value)
            }

            // Now playing (any MPRIS player).
            Rectangle {
                visible: root.page === "" && root.player !== null
                width: parent.width
                height: 56
                radius: Theme.tileRadius
                color: Theme.chip

                ClippingRectangle {
                    id: art
                    width: 36
                    height: 36
                    radius: 8
                    color: Theme.chip
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.cardPadding
                    anchors.verticalCenter: parent.verticalCenter

                    readonly property string appIcon: {
                        DesktopEntries.applications.values
                        const entry = DesktopEntries.heuristicLookup(root.player?.desktopEntry ?? "")
                        return entry ? Quickshell.iconPath(entry.icon, true) : ""
                    }

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: root.player?.trackArtUrl || art.appIcon
                        sourceSize.width: 72
                        sourceSize.height: 72
                    }
                }

                Column {
                    anchors.left: art.right
                    anchors.leftMargin: 10
                    anchors.right: controls.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: root.player?.trackTitle || root.player?.identity || ""
                        color: Theme.foreground
                        font.pixelSize: Theme.titleSize
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: root.player?.trackArtist || root.player?.identity || ""
                        color: Theme.muted
                        font.pixelSize: Theme.subtitleSize
                    }
                }

                Row {
                    id: controls
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.cardPadding
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    CCButton {
                        size: 30
                        icon: root.player?.isPlaying ? "󰏤" : "󰐊"
                        onClicked: root.player?.togglePlaying()
                    }

                    CCButton {
                        size: 30
                        visible: root.player?.canGoNext ?? false
                        icon: "󰒭"
                        onClicked: root.player?.next()
                    }
                }
            }

            Row {
                visible: root.page === ""
                width: parent.width
                spacing: 8

                CCTile {
                    width: (parent.width - parent.spacing) / 2
                    checked: Battery.charging
                    icon: Battery.icon(Battery.percentage, Battery.charging)
                    title: Battery.available ? Math.round(Battery.percentage * 100) + "%" : "Battery"
                    subtitle: Battery.timeText || Battery.stateText

                    onToggled: root.page = "battery"
                    onClicked: root.page = "battery"
                }

                CCTile {
                    width: (parent.width - parent.spacing) / 2
                    checked: PowerProfiles.profile !== PowerProfile.Balanced
                    icon: root.currentProfile.icon
                    title: root.currentProfile.title
                    subtitle: "Power mode"

                    onToggled: root.nextProfile()
                    onClicked: root.nextProfile()
                }
            }

            // Session actions; confirm ones need a second click.
            Item {
                visible: root.page === ""
                width: parent.width
                height: sessionRow.height + sessionLabel.height + 6

                Row {
                    id: sessionRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14

                    Repeater {
                        model: root.actions

                        CCButton {
                            required property var modelData
                            icon: modelData.icon
                            highlighted: root.pendingAction === modelData.id
                            onClicked: root.run(modelData)
                        }
                    }
                }

                Text {
                    id: sessionLabel
                    anchors.top: sessionRow.bottom
                    anchors.topMargin: 6
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.pendingAction !== ""
                        ? "Click again to " + root.actions.find(a => a.id === root.pendingAction).title.toLowerCase()
                        : ""
                    color: Theme.muted
                    font.pixelSize: Theme.subtitleSize
                }
            }

            // ---------- Sub-pages ----------

            Item {
                visible: root.page !== ""
                width: parent.width
                height: 32

                CCButton {
                    id: back
                    size: 28
                    icon: ""
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.page = ""
                }

                Column {
                    anchors.left: back.right
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: root.pages[root.page]?.title ?? ""
                        color: Theme.foreground
                        font.pixelSize: Theme.headerSize
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: root.pages[root.page]?.details.summary ?? ""
                        color: Theme.muted
                        font.pixelSize: Theme.subtitleSize
                    }
                }
            }

            WifiDetails {
                id: wifiDetails
                visible: root.page === "network"
                active: root.visible && visible
                width: parent.width
            }

            BluetoothDetails {
                id: bluetoothDetails
                visible: root.page === "bluetooth"
                active: root.visible && visible
                width: parent.width
            }

            AudioDetails {
                id: audioDetails
                visible: root.page === "sound"
                width: parent.width
            }

            BatteryDetails {
                id: batteryDetails
                visible: root.page === "battery"
                width: parent.width
            }
        }
    }
}
