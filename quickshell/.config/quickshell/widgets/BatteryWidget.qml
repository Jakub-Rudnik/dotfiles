import QtQuick                                                                                                                     
import Quickshell                                                                                                                  
import Quickshell.Widgets  
import "../services"
import "../ui"

WidgetCard {                                                                                                                          
    icon: Battery.charging ? "\udb80\udc84" :                                                                                            
        Battery.percentage <= 0.10 ? "\udb80\udc7a" :
        Battery.percentage <= 0.20 ? "\udb80\udc7b" :                                                                                 
        Battery.percentage <= 0.30 ? "\udb80\udc7c" :                                                                                  
        Battery.percentage <= 0.40 ? "\udb80\udc7d" :
        Battery.percentage <= 0.50 ? "\udb80\udc7e" :
        Battery.percentage <= 0.60 ? "\udb80\udc7f" :                                                                                 
        Battery.percentage <= 0.70 ? "\udb80\udc80" :                                                                                  
        Battery.percentage <= 0.80 ? "\udb80\udc81" :                                                                                  
        "\udb80\udc82"                 
    text: Battery.available ? `${Math.round(Battery.percentage * 100)}%` : "-"    
}