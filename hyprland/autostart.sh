#!/bin/sh
set -eu

export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORMTHEME=kde
export GTK_THEME=BL-Lithium-dark
export XCURSOR_SIZE="${XCURSOR_SIZE:-24}"
export QS_COMPOSITOR=hyprland
export QS_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/ii"

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd \
        WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP \
        XDG_SESSION_DESKTOP XDG_SESSION_TYPE QT_QPA_PLATFORMTHEME GTK_THEME \
        XCURSOR_SIZE QS_COMPOSITOR QS_CONFIG_DIR \
        >/dev/null 2>&1 || true
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment \
        WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP \
        XDG_SESSION_DESKTOP XDG_SESSION_TYPE QT_QPA_PLATFORMTHEME GTK_THEME \
        XCURSOR_SIZE QS_COMPOSITOR QS_CONFIG_DIR \
        >/dev/null 2>&1 || true
fi

pkill -x waybar 2>/dev/null || true
pkill -x swaybg 2>/dev/null || true

"${XDG_CONFIG_HOME:-$HOME/.config}/TWM/set-wallpaper" wayland >/dev/null 2>&1 &
swaync >/dev/null 2>&1 &
nm-applet --indicator >/dev/null 2>&1 &
fcitx5 >/dev/null 2>&1 &

pkill -x qs 2>/dev/null || true
pkill -x quickshell 2>/dev/null || true
"${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/quickshell" \
    >"${XDG_RUNTIME_DIR:-/tmp}/quickshell-hyprland.log" 2>&1 &

if command -v cliphist >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
    pkill -f 'wl-paste.*--watch.*cliphist.*store' 2>/dev/null || true
    sleep 0.2
    wl-paste --type text --watch cliphist store >/dev/null 2>&1 &
    wl-paste --type image --watch cliphist store >/dev/null 2>&1 &
fi

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Breeze-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'breeze-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
fi
