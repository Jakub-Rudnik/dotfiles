import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "widgets"
import "ui"
import "details"

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      required property var modelData
      screen: modelData

      // Nazwa otwartego okna szczegółów ("" gdy żadne nie jest otwarte).
      property string openDetails: ""

      function toggleDetails(name) {
        bar.openDetails = bar.openDetails === name ? "" : name
      }

      color: "transparent"

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 40

      // Klawiatura potrzebna np. do wpisania hasła Wi-Fi.
      WlrLayershell.keyboardFocus: bar.openDetails !== ""
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

      // Pasek jest na liście okien grabu, więc klik w inny widget od razu
      // przełącza okno szczegółów; klik poza paskiem i oknem je zamyka.
      HyprlandFocusGrab {
        active: bar.openDetails !== ""
        windows: [bar.openDetails === "wifi" ? wifiPopup : audioPopup, bar]
        onCleared: bar.openDetails = ""
      }

      WorkspaceWidget {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
      }

      ClockWidget {
        anchors.centerIn: parent
      }

      Row {
        spacing: 5
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right

        AudioWidget {
          id: audioWidget

          selected: audioPopup.visible
          onClicked: bar.toggleDetails("audio")
        }
        WifiWidget {
          id: wifiWidget

          selected: wifiPopup.visible
          onClicked: bar.toggleDetails("wifi")
        }
        BatteryWidget { }
      }

      DetailsPopup {
        id: audioPopup
        anchor.item: audioWidget
        visible: bar.openDetails === "audio"
        title: "Dźwięk"
        subtitle: audioDetails.summary

        AudioDetails {
          id: audioDetails
          width: parent.width
        }
      }

      DetailsPopup {
        id: wifiPopup
        anchor.item: wifiWidget
        visible: bar.openDetails === "wifi"
        title: "Sieć"
        subtitle: wifiDetails.summary

        WifiDetails {
          id: wifiDetails
          width: parent.width
          active: wifiPopup.visible
        }
      }
    }
  }
}
