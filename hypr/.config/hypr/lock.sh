#!/bin/sh
# Start hyprlock and restart it if it dies without unlocking, so the session
# never stays on Hyprland's "lockscreen app died" screen. Needs
# misc.allow_session_lock_restore = true in hyprland.lua.
# Output goes to ~/.local/state/hyprlock.log for debugging crashes.

pidof hyprlock >/dev/null && exit 0

log="${XDG_STATE_HOME:-$HOME/.local/state}/hyprlock.log"
mkdir -p "$(dirname "$log")"
[ "$(stat -c %s "$log" 2>/dev/null || echo 0)" -gt 1000000 ] && : >"$log"

for attempt in 1 2 3 4 5; do
    echo "--- $(date -Is) start #$attempt" >>"$log"
    hyprlock >>"$log" 2>&1 && exit 0
    echo "--- $(date -Is) hyprlock exited with $?" >>"$log"
    sleep 1
done
