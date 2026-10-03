import QtQuick                                                                               
import Quickshell                                                                            
                                                                                                
PopupWindow {                                                                                
    default property alias content: body.data                                                
                                                                                            
    implicitWidth: 320                                                                       
    implicitHeight: body.implicitHeight + 2 * Theme.padding                                                                
    grabFocus: true
    visible: false                                                                           
    color: "transparent"                                                                     
                                                                                            
    // Pod widgetem, rozwija się w lewo.                                                     
    anchor.edges: Edges.Bottom | Edges.Right                                                 
    anchor.gravity: Edges.Bottom | Edges.Left                                                
    anchor.margins.bottom: Theme.spacing                                                     
                                                                                            
    Rectangle {                                                                              
        anchors.fill: parent                                                                 
        color: Theme.background                                                              
        border.color: Theme.outline                                                          
        radius: Theme.radius                                                                 
                                                                                            
        Column {                                                                             
            id: body                                                                         
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top                                                             
            anchors.margins: Theme.padding                                                   
            spacing: Theme.spacing                                                           
        }                                                                                    
    }                                                                                        
}      