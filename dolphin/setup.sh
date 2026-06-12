#!/bin/bash
# Qt 暗色主题配置（Dolphin / KDE 应用适用）
# 还需要在 labwc/environment 中添加：
#   QT_QPA_PLATFORMTHEME=qt5ct
#   QT_STYLE_OVERRIDE=kvantum-dark

set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi

install_pkg() {
    local pkg=$1
    if [[ "$OS" =~ ^(fedora|rhel|centos)$ ]]; then
        sudo dnf install -y "$pkg"
    elif [[ "$OS" =~ ^(ubuntu|debian|linuxmint)$ ]]; then
        sudo apt-get install -y "$pkg"
    elif [[ "$OS" =~ ^(arch|manjaro)$ ]]; then
        sudo pacman -S --noconfirm --needed "$pkg"
    else
        echo "unknown distro, install manually: $pkg"
    fi
}

for pkg in qt5ct qt6ct qt5-style-kvantum papirus-icon-theme; do
    if ! command -v "${pkg%%-*}" &>/dev/null && ! dpkg -l "$pkg" &>/dev/null 2>&1; then
        echo "installing $pkg ..."
        install_pkg "$pkg"
    fi
done

echo "done. run init.sh to symlink configs, then make sure labwc/environment has:"
echo "  QT_QPA_PLATFORMTHEME=qt5ct"
echo "  QT_STYLE_OVERRIDE=kvantum-dark"
