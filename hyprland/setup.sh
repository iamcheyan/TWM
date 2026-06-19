#!/usr/bin/env bash
# Hyprland standalone setup for TWM.

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

TWM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info() { printf '%b%s%b\n' "$BLUE" "$*" "$NC"; }
ok() { printf '%b[OK]%b %s\n' "$GREEN" "$NC" "$*"; }
warn() { printf '%b[WARN]%b %s\n' "$YELLOW" "$NC" "$*"; }
err() { printf '%b[ERR]%b %s\n' "$RED" "$NC" "$*" >&2; }

if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS="$ID"
    OS_LIKE="${ID_LIKE:-}"
else
    OS="unknown"
    OS_LIKE=""
fi

is_fedora() { [[ "$OS $OS_LIKE" =~ (fedora|rhel|centos) ]]; }
is_ubuntu() { [[ "$OS $OS_LIKE" =~ (ubuntu|debian|linuxmint) ]]; }
is_arch() { [[ "$OS $OS_LIKE" =~ (arch|manjaro) ]]; }

pkg_install() {
    local pkg="$1"
    [ -n "$pkg" ] || return 0

    printf '  Installing: %s\n' "$pkg"
    if is_fedora; then
        sudo dnf install -y --setopt=allow_vendor_change=true "$pkg"
    elif is_ubuntu; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
    elif is_arch; then
        sudo pacman -S --noconfirm --needed "$pkg"
    else
        warn "Unsupported distribution; install manually: $pkg"
        return 1
    fi
}

enable_hyprland_repo() {
    is_fedora || return 0
    command -v dnf >/dev/null 2>&1 || return 0

    if dnf repo list --enabled 2>/dev/null | grep -q 'nett00n.*hyprland'; then
        ok "nett00n/hyprland COPR already enabled"
        return 0
    fi

    warn "Fedora repository does not ship Hyprland here; enabling nett00n/hyprland COPR"
    sudo dnf copr enable -y nett00n/hyprland
}

resolve_pkg() {
    local name="$1"
    case "$name" in
        Hyprland) echo "hyprland" ;;
        wl-copy|wl-paste) echo "wl-clipboard" ;;
        notify-send)
            is_ubuntu && echo "libnotify-bin" || echo "libnotify"
            ;;
        swaync|swaync-client)
            is_fedora && echo "SwayNotificationCenter" || echo "swaync"
            ;;
        pactl)
            is_fedora && echo "pipewire-pulseaudio" || echo "pipewire-pulse"
            ;;
        nm-applet) echo "network-manager-applet" ;;
        blueman-manager) echo "blueman" ;;
        bluetoothctl) echo "bluez" ;;
        fc-list|fc-cache) echo "fontconfig" ;;
        qt6-qtwayland)
            is_fedora && echo "qt6-qtwayland" && return
            echo "qt6-wayland"
            ;;
        qt5-qtwayland)
            is_ubuntu && echo "qtwayland5" && return
            is_arch && echo "qt5-wayland" && return
            echo "qt5-qtwayland"
            ;;
        breeze-icon-theme)
            is_arch && echo "breeze-icons" || echo "breeze-icon-theme"
            ;;
        google-open-sans-fonts)
            is_fedora && echo "google-open-sans-fonts" && return
            is_ubuntu && echo "fonts-open-sans" && return
            echo "ttf-opensans"
            ;;
        *) echo "$name" ;;
    esac
}

ensure_cmd() {
    local cmd="$1"
    local desc="${2:-$cmd}"
    local pkg

    if command -v "$cmd" >/dev/null 2>&1; then
        ok "$cmd - $desc"
        return 0
    fi

    warn "$cmd missing - $desc"
    if [ "$cmd" = "Hyprland" ]; then
        enable_hyprland_repo || true
    fi
    pkg="$(resolve_pkg "$cmd")"
    pkg_install "$pkg" || return 1
}

ensure_pkg() {
    pkg_install "$(resolve_pkg "$1")" || true
}

create_symlink() {
    local target="$1"
    local link_name="$2"
    local label="$3"

    mkdir -p "$(dirname "$link_name")"

    if [ -e "$link_name" ] && [ "$(readlink -f "$link_name")" = "$(readlink -f "$target")" ]; then
        ok "$label already linked"
        return 0
    fi

    if [ -e "$link_name" ] && [ ! -L "$link_name" ]; then
        local backup
        backup="$link_name.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$link_name" "$backup"
        warn "$label existed as a real path; moved to $backup"
    fi

    ln -snf "$target" "$link_name"
    ok "$label linked: $link_name -> $target"
}

info "=== TWM Hyprland setup ==="
info "TWM directory: $TWM_DIR"
info "Detected OS: $OS"

info "=== Linking configs ==="
create_symlink "$TWM_DIR" "${XDG_CONFIG_HOME:-$HOME/.config}/TWM" "TWM"
create_symlink "$TWM_DIR/hyprland" "${XDG_CONFIG_HOME:-$HOME/.config}/hypr" "Hyprland"
create_symlink "$TWM_DIR/qs" "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/hyprland" "Quickshell"
create_symlink "$TWM_DIR/wofi" "${XDG_CONFIG_HOME:-$HOME/.config}/wofi" "wofi"
create_symlink "$TWM_DIR/fuzzel" "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel" "fuzzel"
create_symlink "$TWM_DIR/cliphist" "${XDG_CONFIG_HOME:-$HOME/.config}/cliphist" "cliphist"
create_symlink "$TWM_DIR/swaync" "${XDG_CONFIG_HOME:-$HOME/.config}/swaync" "swaync"
create_symlink "$TWM_DIR/mako" "${XDG_CONFIG_HOME:-$HOME/.config}/mako" "mako"
create_symlink "$TWM_DIR/kitty" "${XDG_CONFIG_HOME:-$HOME/.config}/kitty" "kitty"

info "=== Installing Hyprland runtime dependencies ==="
deps=(
    "Hyprland:compositor"
    "hyprctl:Hyprland IPC tool"
    "quickshell:QtQuick shell"
    "alacritty:terminal"
    "wofi:application launcher fallback"
    "fuzzel:dmenu menus"
    "swaybg:wallpaper"
    "swaync-client:notification center"
    "grim:screenshot capture"
    "slurp:region selection"
    "wl-copy:Wayland clipboard"
    "wl-paste:Wayland clipboard read"
    "wtype:keyboard event helper"
    "notify-send:desktop notifications"
    "pactl:PipeWire/PulseAudio control"
    "pavucontrol:volume UI"
    "blueman-manager:Bluetooth UI"
    "bluetoothctl:Bluetooth state"
    "upower:battery state"
    "brightnessctl:brightness control"
    "cliphist:clipboard history"
    "nm-applet:network tray applet"
    "fcitx5:input method"
    "hyprpicker:color picker"
    "curl:downloads"
    "git:source downloads"
    "unzip:font archives"
    "fc-cache:font cache"
)

for dep in "${deps[@]}"; do
    IFS=':' read -r cmd desc <<<"$dep"
    ensure_cmd "$cmd" "$desc" || true
done

if command -v Hyprland >/dev/null 2>&1; then
    for pkg in xdg-desktop-portal-hyprland hyprland-plugins hyprland-qt-support hyprland-guiutils; do
        ensure_pkg "$pkg"
    done
fi

info "=== Installing Qt/GTK theme packages ==="
for pkg in plasma-integration qt6-qtwayland qt5-qtwayland breeze-icon-theme breeze-gtk; do
    ensure_pkg "$pkg"
done

info "=== Installing Quickshell fonts/icons/theme assets ==="
if [ -x "$TWM_DIR/qs/install" ]; then
    "$TWM_DIR/qs/install" --no-deps --no-link
else
    warn "$TWM_DIR/qs/install is missing; skipping shared Quickshell assets"
fi

info "=== Configuring KDE apps ==="
if [ -x "$TWM_DIR/dolphin/setup.sh" ]; then
    bash "$TWM_DIR/dolphin/setup.sh"
fi

info "=== Creating Hyprland session entry ==="
if command -v Hyprland >/dev/null 2>&1 && [ ! -f /usr/share/wayland-sessions/twm-hyprland.desktop ]; then
    sudo tee /usr/share/wayland-sessions/twm-hyprland.desktop >/dev/null <<'DESKTOP'
[Desktop Entry]
Name=TWM Hyprland
Comment=TWM Hyprland session with Quickshell
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
DESKTOP
    ok "Session entry created"
else
    ok "Session entry already exists or Hyprland is not installed yet"
fi

info "=== Done ==="
printf 'Login session: TWM Hyprland\n'
printf 'Manual start: Hyprland\n'
printf 'Quickshell log: ${XDG_RUNTIME_DIR:-/tmp}/quickshell-hyprland.log\n'
