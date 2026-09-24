pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
  readonly property var device: UPower.displayDevice

  readonly property bool available:
    device !== null && device.isPresent

  readonly property real percentage: available ? device.percentage : 0

  readonly property bool charging: available && (device.state == UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge)
}
