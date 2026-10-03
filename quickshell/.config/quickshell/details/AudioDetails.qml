import QtQuick                                                                               
   import "../services"                                                                         
   import "../ui"                                                                               
                                                                                                
    Column {                                                                                     
       id: root                                                                                 
       spacing: Theme.spacing                                                                   
                                                                                                
        Text {                                                                                   
            text: "Głośność"                                                                     
            color: Theme.foreground                                                              
        }                                                                                        
                                                                                                
        Row {                                                                                    
           spacing: Theme.spacing                                                               
                                                                                                
            WidgetCard {                                                                         
               text: "−"                                                                        
               onClicked: Audio.changeVolume(-0.05)                                             
            }                                                                                    
                                                                                                
            Text {                                                                               
               anchors.verticalCenter: parent.verticalCenter                                    
               text: Audio.sink                                                                 
                   ? Math.round(Audio.volume * 100) + "%"                                       
                   : "—"                                                                        
               color: Theme.foreground                                                          
            }                                                                                    
                                                                                                
            WidgetCard {                                                                         
               text: "+"                                                                        
               onClicked: Audio.changeVolume(0.05)                                              
            }                                                                                    
        }                                                                                        
                                                                                                
        Text {                                                                                   
           text: "Wyjście audio"                                                                
           color: Theme.foreground                                                              
        }                                                                                        
                                                                                                
        Repeater {                                                                               
           model: Audio.outputs                                                                 
                                                                                                
            WidgetCard {                                                                         
               required property var modelData                                                  
                                                                                                
               width: root.width                                                                
               text: modelData.nickname || modelData.description || modelData.name              
               selected: modelData === Audio.sink                                               
                                                                                                
               onClicked: Audio.selectOutput(modelData)                                         
            }                                                                                    
        }                                                                                        
   }    