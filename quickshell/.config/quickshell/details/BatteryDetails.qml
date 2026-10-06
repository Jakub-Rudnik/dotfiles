import QtQuick
import Quickshell.Services.UPower
import "../services"
import "../ui"

Column {
    id: root
    spacing: Theme.sectionSpacing

    readonly property var battery: Battery.laptopBattery
    readonly property string summary: Battery.available
        ? [Math.round(Battery.percentage * 100) + "%", Battery.stateText, Battery.timeText]
            .filter(part => part !== "").join(" · ")
        : "No battery"

    readonly property var profiles: [
        { profile: PowerProfile.PowerSaver, icon: "󰌪", title: "Power saver", subtitle: "Longer battery life" },
        { profile: PowerProfile.Balanced, icon: "󰗑", title: "Balanced", subtitle: "Standard performance and power usage" },
        { profile: PowerProfile.Performance, icon: "󰓅", title: "Performance", subtitle: "Maximum performance, higher power usage" }
    ]

    function degradationText(reason) {
        return reason === PerformanceDegradationReason.LapDetected ? "Limited: device on lap"
            : reason === PerformanceDegradationReason.HighTemperature ? "Limited: high temperature"
            : ""
    }

    function peripheralIcon(device) {
        return device.type === UPowerDeviceType.Mouse ? "󰍽"
            : device.type === UPowerDeviceType.Keyboard ? "󰌌"
            : device.type === UPowerDeviceType.Headset
                || device.type === UPowerDeviceType.Headphones ? "󰋋"
            : Battery.icon(device.percentage, false)
    }

    DetailSection {
        width: root.width
        title: "Battery"

        DetailCard {
            width: parent.width
            icon: Battery.icon(Battery.percentage, Battery.charging)
            title: Battery.available ? Math.round(Battery.percentage * 100) + "%" : "No battery"
            subtitle: Battery.available ? Battery.stateText : ""
            trailing: Battery.timeText
        }

        DetailCard {
            width: parent.width
            visible: Battery.available
            icon: UPower.onBattery ? "󱐋" : "󰚥"
            title: UPower.onBattery ? "On battery" : "Plugged in"
            subtitle: Battery.device?.changeRate > 0
                ? (Battery.charging ? "Charging at " : "Drawing ")
                    + Battery.device.changeRate.toFixed(1) + " W"
                : ""
        }

        DetailCard {
            width: parent.width
            visible: root.battery !== null && root.battery.healthSupported
            icon: "󰗶"
            title: "Health"
            subtitle: root.battery
                ? root.battery.energy.toFixed(1) + " / " + root.battery.energyCapacity.toFixed(1) + " Wh"
                : ""
            trailing: root.battery ? Math.round(root.battery.healthPercentage) + "%" : ""
        }
    }

    DetailSection {
        width: root.width
        title: "Power profile"

        Repeater {
            model: root.profiles.filter(p =>
                p.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

            DetailCard {
                required property var modelData

                width: parent.width
                icon: modelData.icon
                title: modelData.title
                subtitle: modelData.profile === PowerProfile.Performance
                        && PowerProfiles.degradationReason !== PerformanceDegradationReason.None
                    ? root.degradationText(PowerProfiles.degradationReason)
                    : modelData.subtitle
                selected: PowerProfiles.profile === modelData.profile

                onClicked: PowerProfiles.profile = modelData.profile
            }
        }
    }

    DetailSection {
        width: root.width
        visible: Battery.peripherals.length > 0
        title: "Devices"

        Repeater {
            model: Battery.peripherals

            DetailCard {
                required property var modelData

                width: parent.width
                icon: root.peripheralIcon(modelData)
                title: modelData.model || UPowerDeviceType.toString(modelData.type)
                subtitle: UPowerDeviceType.toString(modelData.type)
                trailing: Math.round(modelData.percentage * 100) + "%"
            }
        }
    }
}
