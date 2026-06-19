#!/bin/bash
# KDE/Qt 暗色主题配置（Dolphin / KDE 应用适用）
# labwc/environment 使用 KDE 的 platform theme，使 Dolphin 读取
# ~/.config/kdeglobals 里的 KDE/Breeze Dark 配置，而不是 qt6ct/Kvantum。

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_LIKE=${ID_LIKE:-}
else
    OS="unknown"
    OS_LIKE=""
fi

echo "=== Qt Dark Theme Setup (Dolphin) ==="
echo "系统: $OS"

install_pkg() {
    local pkg=$1
    echo -e "  安装: $pkg"
    set +e
    if [[ "$OS $OS_LIKE" =~ (fedora|rhel|centos) ]]; then
        sudo dnf install -y "$pkg"
    elif [[ "$OS $OS_LIKE" =~ (ubuntu|debian|linuxmint) ]]; then
        sudo apt-get install -y "$pkg"
    elif [[ "$OS $OS_LIKE" =~ (arch|manjaro) ]]; then
        sudo pacman -S --noconfirm --needed "$pkg"
    else
        echo -e "${RED}未知发行版，请手动安装: $pkg${NC}"
        return 1
    fi
    set -e
}

# 包名映射
resolve_pkg() {
    local pkg="$1"
    case "$pkg" in
        plasma-integration)
            if [[ "$OS $OS_LIKE" =~ (ubuntu|debian|linuxmint) ]]; then
                echo "plasma-integration"
            elif [[ "$OS $OS_LIKE" =~ (arch|manjaro) ]]; then
                echo "plasma-integration"
            else
                echo "plasma-integration"
            fi
            ;;
        qt6-qtwayland)
            if [[ "$OS $OS_LIKE" =~ (ubuntu|debian|linuxmint) ]]; then
                echo "qt6-wayland"
            elif [[ "$OS $OS_LIKE" =~ (arch|manjaro) ]]; then
                echo "qt6-wayland"
            else
                echo "qt6-qtwayland"
            fi
            ;;
        qt5-qtwayland)
            if [[ "$OS $OS_LIKE" =~ (ubuntu|debian|linuxmint) ]]; then
                echo "qtwayland5"
            elif [[ "$OS $OS_LIKE" =~ (arch|manjaro) ]]; then
                echo "qt5-wayland"
            else
                echo "qt5-qtwayland"
            fi
            ;;
        breeze-icon-theme)
            if [[ "$OS $OS_LIKE" =~ (arch|manjaro) ]]; then
                echo "breeze-icons"
            else
                echo "breeze-icon-theme"
            fi
            ;;
        breeze-gtk)
            echo "breeze-gtk"
            ;;
        papirus-icon-theme)
            echo "papirus-icon-theme"
            ;;
        *) echo "$pkg" ;;
    esac
}

# 需要的包
QT_DEPS="plasma-integration qt6-qtwayland qt5-qtwayland breeze-icon-theme breeze-gtk"

for pkg in $QT_DEPS; do
    resolved=$(resolve_pkg "$pkg")
    if command -v "${pkg%%-*}" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $pkg 已安装"
    elif rpm -q "$resolved" &>/dev/null 2>&1 || dpkg -l "$resolved" &>/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $pkg 已安装"
    else
        install_pkg "$resolved"
    fi
done

echo ""
if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
    plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
fi

echo -e "${GREEN}=== KDE/Qt Dark Theme Setup 完成 ===${NC}"
echo "确保 labwc/environment 中有："
echo "  QT_QPA_PLATFORMTHEME=kde"
echo "并且不要设置 QT_STYLE_OVERRIDE；KDE 程序会读取 kdeglobals 的 Breeze Dark 配色。"
