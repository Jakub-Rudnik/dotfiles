import QtQuick
import Quickshell
import "widgets"

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      color: "transparent"

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 40

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

        WifiWidget { }
        BatteryWidget { }
      }
    }
  }
 }
