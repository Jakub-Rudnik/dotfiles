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

      // Name of the open details popup ("" when none is open).
      property string openDetails: ""

      function popupFor(name) {
        return name === "wifi" ? wifiPopup
          : name === "battery" ? batteryPopup
          : audioPopup
      }

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

      // Keyboard is needed e.g. to type a Wi-Fi password.
      WlrLayershell.keyboardFocus: bar.openDetails !== ""
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

      // The bar is whitelisted in the grab, so clicking another widget switches
      // popups directly; clicking outside the bar and popup closes it.
      HyprlandFocusGrab {
        active: bar.openDetails !== ""
        windows: [bar.popupFor(bar.openDetails), bar]
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
        BatteryWidget {
          id: batteryWidget

          selected: batteryPopup.visible
          onClicked: bar.toggleDetails("battery")
        }
      }

      DetailsPopup {
        id: audioPopup
        anchor.item: audioWidget
        visible: bar.openDetails === "audio"
        title: "Sound"
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
        title: "Network"
        subtitle: wifiDetails.summary

        WifiDetails {
          id: wifiDetails
          width: parent.width
          active: wifiPopup.visible
        }
      }

      DetailsPopup {
        id: batteryPopup
        anchor.item: batteryWidget
        visible: bar.openDetails === "battery"
        title: "Battery"
        subtitle: batteryDetails.summary

        BatteryDetails {
          id: batteryDetails
          width: parent.width
        }
      }
    }
  }
}
