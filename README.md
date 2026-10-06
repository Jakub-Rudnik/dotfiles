# Dotfiles

my simple dotfiles as i'm exploring the linux ricing.

Hyprland + Qucikshell

> [!Note]
> This is in constant development so be careful

## Hyprlock (Arch Linux)

```sh
sudo pacman -S --needed hyprlock
stow -t "$HOME" hypr
hyprctl reload
```

- **Win + L** locks the session; enter your Linux account password to unlock.
- **Win + M** logs out (closes the session).
- `hypr/.config/hypr/hyprlock.conf` provides a black-and-white lock screen
  matching the Quickshell bar, with a clock, date and password field.

Hyprlock is not a login manager: the login screen at boot remains GDM.

## PipeWire low latency (JACK)

```sh
sudo pacman -S --needed pipewire pipewire-jack wireplumber
stow -t "$HOME" pipewire
systemctl --user restart pipewire pipewire-pulse wireplumber
```

- `pipewire/.config/pipewire/pipewire.conf.d/92-low-latency.conf` sets the
  default quantum (JACK buffer size) to 64 samples at 48 kHz.
- Check with `pw-top` (QUANT column).
