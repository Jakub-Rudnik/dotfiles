pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
  readonly property var device: UPower.displayDevice

  // The physical laptop battery; the display device lacks health data.
  readonly property var laptopBattery:
    UPower.devices.values.find(d => d.isLaptopBattery) ?? null

  readonly property bool available:
    device !== null && device.isPresent

  readonly property real percentage: available ? device.percentage : 0

  readonly property bool charging: available && (device.state == UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge)

  readonly property string stateText: !available ? "No battery"
    : device.state === UPowerDeviceState.Charging ? "Charging"
    : device.state === UPowerDeviceState.Discharging ? "Discharging"
    : device.state === UPowerDeviceState.FullyCharged ? "Fully charged"
    : device.state === UPowerDeviceState.PendingCharge ? "Plugged in, not charging"
    : device.state === UPowerDeviceState.PendingDischarge ? "Waiting to discharge"
    : device.state === UPowerDeviceState.Empty ? "Empty"
    : "Unknown"

  // Remaining time as text, e.g. "2 h 5 min left"; empty when unknown.
  readonly property string timeText: {
    if (!available)
      return ""
    if (device.state === UPowerDeviceState.Charging && device.timeToFull > 0)
      return formatDuration(device.timeToFull) + " to full"
    if (device.state === UPowerDeviceState.Discharging && device.timeToEmpty > 0)
      return formatDuration(device.timeToEmpty) + " left"
    return ""
  }

  // Batteries of peripherals (mouse, headset, ...), excluding the laptop battery.
  readonly property var peripherals: UPower.devices.values.filter(d =>
    d.isPresent && !d.isLaptopBattery && !d.powerSupply
      && d.type !== UPowerDeviceType.LinePower)

  function formatDuration(seconds) {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.round((seconds % 3600) / 60)
    return hours > 0 ? hours + " h " + minutes + " min" : minutes + " min"
  }

  function icon(percentage, charging) {
    if (charging)
      return "\udb80\udc84"
    const icons = ["\udb80\udc7a", "\udb80\udc7b", "\udb80\udc7c", "\udb80\udc7d", "\udb80\udc7e",
      "\udb80\udc7f", "\udb80\udc80", "\udb80\udc81", "\udb80\udc82"]
    return icons[Math.min(icons.length - 1, Math.max(0, Math.ceil(percentage * 10 - 1e-9) - 1))]
  }
}
