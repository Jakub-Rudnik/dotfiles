import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "widgets"
import "ui"

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      required property var modelData
      screen: modelData

      readonly property bool controlCenterOpen: ControlCenterState.screen === modelData.name

      color: "transparent"

      anchors {
        top: true
        left: true
        right: true
      }

      // Islands float Theme.barMargin below the screen edge.
      implicitHeight: Theme.barHeight + (Settings.islands ? Theme.barMargin : 0)

      // Keyboard is needed e.g. to type a Wi-Fi password.
      WlrLayershell.keyboardFocus: bar.controlCenterOpen
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

      // Clicking outside the bar and the Control Center closes it.
      HyprlandFocusGrab {
        active: bar.controlCenterOpen
        windows: [controlCenter, bar]
        onCleared: ControlCenterState.close()
      }

      // Full-width style: one glass strip with a hairline at the bottom.
      Rectangle {
        visible: !Settings.islands
        anchors.fill: parent
        color: Theme.background

        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: 1
          color: Theme.outline
        }
      }

      BarGroup {
        anchors.left: parent.left
        anchors.leftMargin: Settings.islands ? Theme.barMargin : 0
        anchors.top: parent.top
        anchors.topMargin: Settings.islands ? Theme.barMargin : 0

        WorkspaceWidget { }
      }

      BarGroup {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Settings.islands ? Theme.barMargin : 0

        ClockWidget { }
      }

      // Status island: every icon opens the Control Center.
      BarGroup {
        id: statusGroup
        highlighted: bar.controlCenterOpen
        anchors.right: parent.right
        anchors.rightMargin: Settings.islands ? Theme.barMargin : 0
        anchors.top: parent.top
        anchors.topMargin: Settings.islands ? Theme.barMargin : 0

        AudioWidget {
          onClicked: ControlCenterState.toggle(bar.modelData.name)
        }
        BluetoothWidget {
          onClicked: ControlCenterState.toggle(bar.modelData.name)
        }
        WifiWidget {
          onClicked: ControlCenterState.toggle(bar.modelData.name)
        }
        BatteryWidget {
          onClicked: ControlCenterState.toggle(bar.modelData.name)
        }
      }

      ControlCenter {
        id: controlCenter
        anchor.item: statusGroup
        visible: bar.controlCenterOpen
        onCloseRequested: ControlCenterState.close()
      }
    }
  }
}
