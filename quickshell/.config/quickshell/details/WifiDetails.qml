import QtQuick
import Quickshell.Networking
import "../services"
import "../ui"

Column {
    id: root
    spacing: Theme.sectionSpacing

    // Scan only while the popup is open.
    property bool active: false

    // Network waiting for a password.
    property var pendingNetwork: null
    // Network we last tried to connect to.
    property var connectingNetwork: null
    property string error: ""

    readonly property int maxNetworks: 6

    readonly property string summary:
        Wifi.primaryDevice !== null && Wifi.primaryDevice === Wifi.wiredDevice
            ? "Connected via Ethernet"
        : Wifi.primaryDevice !== null && Wifi.activeNetwork
            ? "Connected to " + Wifi.activeNetwork.name
        : "Not connected"

    onActiveChanged: {
        if (!active) {
            root.pendingNetwork = null
            root.error = ""
        }
    }

    Binding {
        when: Wifi.wifiDevice !== null
        target: Wifi.wifiDevice
        property: "scannerEnabled"
        value: root.active
    }

    function select(network) {
        root.error = ""
        if (network.connected)
            return

        if (network.known || !Wifi.isSecured(network)) {
            root.pendingNetwork = null
            root.connectingNetwork = network
            network.connect()
        } else {
            root.pendingNetwork = network
        }
    }

    function submitPassword() {
        const network = root.pendingNetwork
        if (!network || passwordInput.text === "")
            return

        root.error = ""
        root.connectingNetwork = network
        network.connectWithPsk(passwordInput.text)
        root.pendingNetwork = null
    }

    function networkStatus(network) {
        return network.connected ? "Connected"
            : network.stateChanging ? "Connecting…"
            : network.known ? "Saved"
            : Wifi.isSecured(network) ? "Secured"
            : "Open"
    }

    Connections {
        target: root.connectingNetwork

        function onConnectionFailed(reason) {
            if (reason === ConnectionFailReason.NoSecrets) {
                root.error = "Wrong password"
                root.pendingNetwork = root.connectingNetwork
            } else {
                root.error = "Failed to connect: "
                    + ConnectionFailReason.toString(reason)
            }
        }
    }

    DetailSection {
        width: root.width
        title: "Connection"

        DetailCard {
            width: parent.width
            icon: "\udb80\ude00"
            title: "Ethernet"
            subtitle: !Wifi.wiredDevice ? "No adapter"
                : !Wifi.wiredConnected ? "Unplugged"
                : Wifi.wiredDevice.linkSpeed > 0 ? "Connected · " + Wifi.wiredDevice.linkSpeed + " Mb/s"
                : "Connected"
            selected: Wifi.wiredDevice !== null && Wifi.primaryDevice === Wifi.wiredDevice
        }

        DetailCard {
            width: parent.width
            icon: Wifi.isConnected ? Wifi.strengthIcon(Wifi.strength, false) : "\udb81\uddaa"
            title: "Wi-Fi"
            subtitle: !Wifi.wifiDevice ? "No adapter"
                : !Networking.wifiEnabled ? "Off"
                : Wifi.activeNetwork ? Wifi.activeNetwork.name
                : "Disconnected"
            trailing: Wifi.isConnected ? Math.round(Wifi.strength * 100) + "%" : ""
            selected: Wifi.wifiDevice !== null && Wifi.primaryDevice === Wifi.wifiDevice
        }
    }

    DetailSection {
        width: root.width
        title: "Nearby networks"

        Text {
            visible: Wifi.networks.length === 0
            text: Wifi.wifiDevice && Networking.wifiEnabled ? "Scanning…" : "Wi-Fi unavailable"
            color: Theme.muted
            font.pixelSize: Theme.subtitleSize
        }

        Repeater {
            model: Wifi.networks.slice(0, root.maxNetworks)

            DetailCard {
                required property var modelData

                width: parent.width
                icon: Wifi.strengthIcon(modelData.signalStrength, Wifi.isSecured(modelData))
                title: modelData.name
                subtitle: root.networkStatus(modelData)
                trailing: Math.round(modelData.signalStrength * 100) + "%"
                selected: modelData.connected || modelData === root.pendingNetwork

                onClicked: root.select(modelData)
            }
        }
    }

    DetailSection {
        width: root.width
        visible: root.pendingNetwork !== null || root.error !== ""
        title: root.pendingNetwork ? "Password for " + root.pendingNetwork.name : ""

        Row {
            visible: root.pendingNetwork !== null
            spacing: Theme.spacing

            onVisibleChanged: {
                passwordInput.text = ""
                if (visible)
                    passwordInput.forceActiveFocus()
            }

            Rectangle {
                width: root.width - connectButton.width - Theme.spacing
                height: Theme.widgetHeight
                color: Theme.background
                border.color: passwordInput.activeFocus ? Theme.foreground : Theme.outline
                radius: Theme.radius

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: Theme.cardPadding
                    anchors.rightMargin: Theme.cardPadding
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    echoMode: TextInput.Password
                    color: Theme.foreground
                    selectionColor: Theme.outline
                    font.pixelSize: Theme.titleSize

                    onAccepted: root.submitPassword()
                    Keys.onEscapePressed: root.pendingNetwork = null
                }
            }

            WidgetCard {
                id: connectButton
                text: "Connect"
                onClicked: root.submitPassword()
            }
        }

        Text {
            width: parent.width
            visible: root.error !== ""
            wrapMode: Text.WordWrap
            text: root.error
            color: Theme.muted
            font.pixelSize: Theme.subtitleSize
        }
    }
}
