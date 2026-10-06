import QtQuick
import Quickshell.Networking
import "../services"
import "../ui"

Column {
    id: root
    spacing: Theme.sectionSpacing

    // Skanuj tylko, gdy okno jest otwarte.
    property bool active: false

    // Sieć czekająca na wpisanie hasła.
    property var pendingNetwork: null
    // Sieć, z którą ostatnio próbowaliśmy się połączyć.
    property var connectingNetwork: null
    property string error: ""

    readonly property int maxNetworks: 6

    readonly property string summary:
        Wifi.primaryDevice !== null && Wifi.primaryDevice === Wifi.wiredDevice
            ? "Połączono przez kabel"
        : Wifi.primaryDevice !== null && Wifi.activeNetwork
            ? "Połączono z " + Wifi.activeNetwork.name
        : "Brak połączenia"

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
        return network.connected ? "Połączono"
            : network.stateChanging ? "Łączenie…"
            : network.known ? "Zapisana"
            : Wifi.isSecured(network) ? "Zabezpieczona"
            : "Otwarta"
    }

    Connections {
        target: root.connectingNetwork

        function onConnectionFailed(reason) {
            if (reason === ConnectionFailReason.NoSecrets) {
                root.error = "Nieprawidłowe hasło"
                root.pendingNetwork = root.connectingNetwork
            } else {
                root.error = "Nie udało się połączyć: "
                    + ConnectionFailReason.toString(reason)
            }
        }
    }

    DetailSection {
        width: root.width
        title: "Połączenie"

        DetailCard {
            width: parent.width
            icon: "\udb80\ude00"
            title: "Kabel"
            subtitle: !Wifi.wiredDevice ? "Brak karty sieciowej"
                : !Wifi.wiredConnected ? "Niepodłączony"
                : Wifi.wiredDevice.linkSpeed > 0 ? "Połączono · " + Wifi.wiredDevice.linkSpeed + " Mb/s"
                : "Połączono"
            selected: Wifi.wiredDevice !== null && Wifi.primaryDevice === Wifi.wiredDevice
        }

        DetailCard {
            width: parent.width
            icon: Wifi.isConnected ? Wifi.strengthIcon(Wifi.strength, false) : "\udb81\uddaa"
            title: "Wi-Fi"
            subtitle: !Wifi.wifiDevice ? "Brak karty sieciowej"
                : !Networking.wifiEnabled ? "Wyłączone"
                : Wifi.activeNetwork ? Wifi.activeNetwork.name
                : "Rozłączono"
            trailing: Wifi.isConnected ? Math.round(Wifi.strength * 100) + "%" : ""
            selected: Wifi.wifiDevice !== null && Wifi.primaryDevice === Wifi.wifiDevice
        }
    }

    DetailSection {
        width: root.width
        title: "Sieci w pobliżu"

        Text {
            visible: Wifi.networks.length === 0
            text: Wifi.wifiDevice && Networking.wifiEnabled ? "Szukam sieci…" : "Wi-Fi niedostępne"
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
        title: root.pendingNetwork ? "Hasło do " + root.pendingNetwork.name : ""

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
                text: "Połącz"
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
