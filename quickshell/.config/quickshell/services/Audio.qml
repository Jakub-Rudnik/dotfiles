pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var outputs: Pipewire.nodes.values.filter(                                 
       node => node.audio && node.isSink && !node.isStream
           && AudioAvailability.byName[node.name] !== false                                      
    )   
    readonly property PwNode sink: Pipewire.defaultAudioSink                                     
                                                                                                    
    PwObjectTracker {                                                                            
        objects: [root.sink]                                                                     
    }                                                                                            
                                                                                                    
    readonly property real volume: root.sink?.audio?.volume ?? 0
    readonly property bool muted: root.sink?.audio?.muted ?? false

    function selectOutput(node) {                                                                
        Pipewire.preferredDefaultAudioSink = node                                                
    }                                                                                            
                                                                                                
   function changeVolume(delta) {                                                               
       if (!root.sink?.ready || !root.sink.audio)                                               
           return                                                                               
                                                                                                
       root.sink.audio.volume = Math.max(                                                       
           0,                                                                                   
           Math.min(1, root.sink.audio.volume + delta)                                          
       )                                                                                        
   }   
}