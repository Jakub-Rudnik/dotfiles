pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink                                     
                                                                                                    
    PwObjectTracker {                                                                            
        objects: [root.sink]                                                                     
    }                                                                                            
                                                                                                    
    readonly property real volume: root.sink?.audio?.volume ?? 0
    readonly property bool muted: root.sink?.audio?.muted
}