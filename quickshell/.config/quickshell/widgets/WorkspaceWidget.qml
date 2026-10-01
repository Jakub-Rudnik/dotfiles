import QtQuick
import Quickshell.Hyprland
import "../ui"

Row {
    spacing: 5

    Repeater {
        model: 8

        WidgetCard {
            required property int index                                    
            readonly property int workspaceId: index + 1                   
                                                                            
            selected: Hyprland.focusedWorkspace?.id === workspaceId        
                                                                            
            width: Theme.widgetHeight                                      
            text: String(workspaceId)                                      
                                                                            
            onClicked: Hyprland.dispatch("workspace " + workspaceId) 
        }
    }
}