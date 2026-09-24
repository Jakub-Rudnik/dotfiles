import QtQuick
import "../services"

Rectangle {
  height: 30
  width: clockContent.implicitWidth + 30
  radius: 5
  color: "#000"
  border.color: "#404040"

    Row {
        spacing: 5
        anchors.centerIn: parent

        Text {
            id: clockContent
            text: Wifi.isConnected ? 
                Wifi.strength <= 0.25 ? "\udb82\udd1f" :
                Wifi.strength <= 0.50 ? "\udb82\udd22" :
                Wifi.strength <= 0.75 ? "\udb82\udd25" : "\udb82\udd28"
                : "-" 
            anchors.centerIn: parent
            color: "white"
        }
    }
}