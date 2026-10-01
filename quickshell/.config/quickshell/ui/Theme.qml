pragma Singleton                                                           
                                                                              
import QtQuick                                                             
import Quickshell                                                          
                                                                            
Singleton {                                                                
    readonly property color background: "#000000"                          
    readonly property color foreground: "#ffffff"                          
    readonly property color outline: "#404040"                             
                                                                            
    readonly property int widgetHeight: 30                                 
    readonly property int radius: 5                                        
    readonly property int padding: 15                                      
    readonly property int spacing: 5                                       
                                                                            
    readonly property string iconFont: "Symbols Nerd Font"                 
    readonly property int iconSize: 15                                    
}         