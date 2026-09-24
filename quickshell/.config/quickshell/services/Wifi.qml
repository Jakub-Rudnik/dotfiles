pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
    id: wifi

    readonly property var wifiDevice:                                                                                                  
       Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null                                                        
                                                                                                                                      
   readonly property var activeNetwork: wifiDevice                                                                                    
       ? wifiDevice.networks.values.find(n => n.connected) ?? null                                                                    
       : null                                                                                                                         
                                                                                                                                      
   readonly property bool isConnected:                                                                                                
       wifiDevice !== null && wifiDevice.connected                                                                                    
                                                                                                                                      
   readonly property real strength:                                                                                                   
       activeNetwork ? activeNetwork.signalStrength : 0  
}