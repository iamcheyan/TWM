#!/bin/bash
# Qt 暗色主题配置（Dolphin / KDE 应用适用）
# 配合 labwc/environment 中的：
#   QT_QPA_PLATFORMTHEME=qt6ct
#   QT_STYLE_OVERRIDE=kvantum-dark

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS="unknown"
fi

echo "=== Qt Dark Theme Setup (Dolphin) ==="
echo "系统: $OS"

install_pkg() {
    local pkg=$1
    echo -e "  安装: $pkg"
    set +e
    if [[ "$OS" =~ ^(fedora|rhel|centos)$ ]]; then
        sudo dnf install -y "$pkg"
    elif [[ "$OS" =~ ^(ubuntu|debian|linuxmint)$ ]]; then
        sudo apt-get install -y "$pkg"
    elif [[ "$OS" =~ ^(arch|manjaro)$ ]]; then
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
        kvantum)
            if [[ "$OS" =~ ^(ubuntu|debian|linuxmint)$ ]]; then
                echo "qt5-style-kvantum"
            else
                echo "kvantum"
            fi
            ;;
        papirus-icon-theme)
            if [[ "$OS" =~ ^(ubuntu|debian|linuxmint)$ ]]; then
                echo "papirus-icon-theme"
            else
                echo "papirus-icon-theme"
            fi
            ;;
        *) echo "$pkg" ;;
    esac
}

# 需要的包
QT_DEPS="qt5ct qt6ct kvantum"

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
echo -e "${GREEN}=== Qt Dark Theme Setup 完成 ===${NC}"
echo "确保 labwc/environment 中有："
echo "  QT_QPA_PLATFORMTHEME=qt6ct"
echo "  QT_STYLE_OVERRIDE=kvantum-dark"
