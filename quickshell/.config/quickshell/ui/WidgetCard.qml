import QtQuick

Rectangle {
    id: root
    property alias icon: iconLabel.text
    property alias text: valueLabel.text
    property bool selected: false                                              
    readonly property color contentColor: selected ? Theme.background : Theme.foreground                         
    signal clicked() 

    implicitWidth: content.implicitWidth + 2 * Theme.padding    
    implicitHeight: Theme.widgetHeight

    color: root.selected ? Theme.foreground : Theme.background
    border.color: Theme.outline
    radius: Theme.radius

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacing

        Text {                             
            id: iconLabel
            visible: text != ""
            color: root.contentColor
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
            anchors.verticalCenter: content.verticalCenter
        }         

        Text {
            id: valueLabel
            visible: text != ""
            color: root.contentColor
        }
    }

    MouseArea {                                                                
        anchors.fill: parent                                                   
        onClicked: root.clicked()                                              
    }
}