import QtQuick
import Quickshell.Networking
import "../services"
import "../ui"

Column {
    id: root
    spacing: Theme.spacing

    // Skanuj tylko, gdy okno jest otwarte.
    property bool active: false

    // Sieć czekająca na wpisanie hasła.
    property var pendingNetwork: null
    // Sieć, z którą ostatnio próbowaliśmy się połączyć.
    property var connectingNetwork: null
    property string error: ""

    readonly property int maxNetworks: 8

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

    Text {
        text: "Połączenie"
        color: Theme.foreground
    }

    WidgetCard {
        width: root.width
        icon: "󰈀"
        text: !Wifi.wiredDevice ? "Kabel · brak karty"
            : !Wifi.wiredConnected ? "Kabel · niepodłączony"
            : Wifi.wiredDevice.linkSpeed > 0 ? "Kabel · " + Wifi.wiredDevice.linkSpeed + " Mb/s"
            : "Kabel · połączono"
        selected: Wifi.wiredDevice !== null && Wifi.primaryDevice === Wifi.wiredDevice
    }

    WidgetCard {
        width: root.width
        icon: Wifi.isConnected ? Wifi.strengthIcon(Wifi.strength, false) : "\udb81\uddaa"
        text: !Wifi.wifiDevice ? "Wi-Fi · brak karty"
            : !Networking.wifiEnabled ? "Wi-Fi · wyłączone"
            : Wifi.activeNetwork ? "Wi-Fi · " + Wifi.activeNetwork.name
            : "Wi-Fi · rozłączono"
        selected: Wifi.wifiDevice !== null && Wifi.primaryDevice === Wifi.wifiDevice
    }

    Text {
        width: root.width
        visible: Wifi.wiredConnected && Wifi.isConnected
        wrapMode: Text.WordWrap
        text: Wifi.primaryDevice === Wifi.wiredDevice
            ? "Oba połączenia aktywne — ruch idzie kablem (ma wyższy priorytet)."
            : "Oba połączenia aktywne — ruch idzie przez Wi-Fi."
        color: Theme.foreground
    }

    Text {
        text: "Sieci w pobliżu"
        color: Theme.foreground
    }

    Text {
        visible: Wifi.networks.length === 0
        text: Wifi.wifiDevice && Networking.wifiEnabled ? "Szukam sieci…" : "Wi-Fi niedostępne"
        color: Theme.foreground
    }

    Repeater {
        model: Wifi.networks.slice(0, root.maxNetworks)

        WidgetCard {
            required property var modelData

            width: root.width
            icon: Wifi.strengthIcon(modelData.signalStrength, Wifi.isSecured(modelData))
            text: modelData.name
                + (modelData.stateChanging ? " · łączenie…" : "")
            selected: modelData.connected || modelData === root.pendingNetwork

            onClicked: root.select(modelData)
        }
    }

    Text {
        width: root.width
        visible: root.pendingNetwork !== null
        elide: Text.ElideRight
        text: "Hasło do " + (root.pendingNetwork?.name ?? "")
        color: Theme.foreground
    }

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
            border.color: Theme.outline
            radius: Theme.radius

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                echoMode: TextInput.Password
                color: Theme.foreground
                selectionColor: Theme.outline

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
        width: root.width
        visible: root.error !== ""
        wrapMode: Text.WordWrap
        text: root.error
        color: Theme.foreground
    }
}
