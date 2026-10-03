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
