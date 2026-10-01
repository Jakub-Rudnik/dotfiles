import QtQuick
import Quickshell
import Quickshell.Widgets  
import "../services"
import "../ui"

WidgetCard {                        
    icon: Audio.muted ? "\ueee8" :               
        Audio.volume <= 0 ? "\uf026" :
        Audio.volume <= 0.33 ? "\uf027" :        
        Audio.volume <= 0.66 ? "\uefcf" :     
        "\uf028"
    text: Audio.sink ? Math.round(Audio.volume * 100) + "%" : "—"
}