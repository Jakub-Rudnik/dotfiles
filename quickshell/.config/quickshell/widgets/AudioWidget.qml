import QtQuick
import Quickshell
import Quickshell.Widgets  
import "../services"

Rectangle {
    height: 30
    width: audioContent.implicitWidth + 30
    radius: 5
    color: "#000"
    border.color: "#404040"

    Row {
        id: audioContent
        spacing: 5
        anchors.centerIn: parent

        Text {                                                                                                                             
            text: Audio.muted ? "\ueee8" :                                                                                            
                Audio.volume <= 0 ? "\uf026" :
                Audio.volume <= 0.33 ? "\uf027" :                                                                                 
                Audio.volume <= 0.66 ? "\uefcf" :                                                                                
                "\uf028"                                                                                                                 
                                                                                                                                        
            font.family: "Symbols Nerd Font"                                                                                               
            font.pixelSize: 17                                                                                                             
            color: "white"
        }      

        Text {
            text: Audio.sink ? Math.round(Audio.volume * 100) + "%" : "—"
            color: "white"    
        }
    }
}