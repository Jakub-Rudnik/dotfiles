import QtQuick
import "../services"

Rectangle {
  height: 30
  width: clockContent.implicitWidth + 30
  radius: 5
  color: "#000"
  border.color: "#404040"

  Text {
    id: clockContent
    text: Time.time
    anchors.centerIn: parent
    color: "white"
  }
}
