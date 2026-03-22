#!/bin/bash
# TWM 配置初始化脚本 (支持 i3, Sway, Niri)

set -e

echo "=== TWM 配置初始化 ==="

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 获取脚本所在目录
TWM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo -e "${BLUE}TWM 配置目录: ${TWM_DIR}${NC}"

# ========== 创建软链接 ==========
echo ""
echo "=== 创建配置软链接 ==="

# 配置目录列表
CONFIG_DIRS=(
    "$TWM_DIR/niri:$HOME/.config/niri"
    "$TWM_DIR/waybar:$HOME/.config/waybar"
    "$TWM_DIR/kitty:$HOME/.config/kitty"
    "$TWM_DIR/xterm:$HOME/.config/xterm"
    "$TWM_DIR/mako:$HOME/.config/mako"
    "$TWM_DIR/wofi:$HOME/.config/wofi"
    "$TWM_DIR/sway:$HOME/.config/sway"
    "$TWM_DIR/i3:$HOME/.config/i3"
    "$TWM_DIR/polybar:$HOME/.config/polybar"
)

# 配置文件列表
CONFIG_FILES=(
    "$TWM_DIR/background.png:$HOME/.config/niri/background.png"
    "$TWM_DIR/background.png:$HOME/.config/sway/background.png"
)

# 函数：创建软链接（如果存在则备份）
create_symlink() {
    local target="$1"
    local link_name="$2"
    local config_name="$3"

    mkdir -p "$(dirname "$link_name")"
    
    if [ -e "$link_name" ] && [ ! -L "$link_name" ]; then
        backup_name="${link_name}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "⚠ $config_name 已存在真实路径，备份到: $backup_name"
        mv "$link_name" "$backup_name"
    fi
    
    ln -snf "$target" "$link_name"
    echo -e "${GREEN}✓ $config_name 软链接已同步 ($link_name -> $target)${NC}"
}

for config in "${CONFIG_DIRS[@]}"; do
    IFS=':' read -r src tgt <<< "$config"
    name=$(basename "$tgt")
    create_symlink "$src" "$tgt" "$name"
done

for config in "${CONFIG_FILES[@]}"; do
    IFS=':' read -r src tgt <<< "$config"
    name=$(basename "$tgt")
    create_symlink "$src" "$tgt" "$name"
done

# ========== 安装 Nerd Font ==========
echo ""
echo "=== 安装 Nerd Font ==="

FONT_DIR="$HOME/.local/share/fonts"
if fc-list | grep -qi "MesloLGS"; then
    echo "✓ MesloLGS Nerd Font 已安装"
else
    echo "开始下载 MesloLGS Nerd Font..."
    mkdir -p "$FONT_DIR"
    FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
    cd "$FONT_DIR"
    for style in Regular Bold Italic "Bold Italic"; do
        filename="MesloLGS NF ${style}.ttf"
        url_filename=$(echo "$filename" | sed 's/ /%20/g')
        [ -f "$filename" ] || curl -fLo "$filename" "${FONT_BASE_URL}/${url_filename}"
    done
    fc-cache -f "$FONT_DIR"
    echo -e "${GREEN}✓ MesloLGS Nerd Font 安装完成${NC}"
fi

# ========== 系统检测与安装 ==========
echo ""
echo "=== 检查依赖软件 ==="

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        OS="unknown"
    fi
}

install_package() {
    local cmd="$1"
    local pkg=""

    case "$cmd" in
        wl-copy) pkg="wl-clipboard" ;;
        notify-send)
            [[ "$OS" =~ ^(ubuntu|debian|linuxmint)$ ]] && pkg="libnotify-bin" || pkg="libnotify"
            ;;
        xrandr)
            [[ "$OS" =~ ^(arch|manjaro)$ ]] && pkg="xorg-xrandr" || pkg="xrandr"
            ;;
        cliphist) pkg="cliphist" ;;
        wtype) pkg="wtype" ;;
        *) pkg="$cmd" ;;
    esac

    echo -e "  正在安装: $pkg ($OS)"
    set +e
    if [[ "$OS" =~ ^(fedora|rhel|centos)$ ]]; then
        sudo dnf install -y "$pkg"
    elif [[ "$OS" =~ ^(arch|manjaro)$ ]]; then
        sudo pacman -S --noconfirm --needed "$pkg"
    elif [[ "$OS" =~ ^(ubuntu|debian|linuxmint)$ ]]; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
    fi
    set -e
}

detect_os
echo "检测到系统: $OS"

# 基础依赖 + 剪贴板管理
DEPS=(
    "waybar:状态栏"
    "kitty:终端模拟器"
    "swaybg:壁纸管理器"
    "mako:通知守护进程"
    "wofi:应用启动器"
    "grim:截图工具"
    "slurp:区域选择工具"
    "wl-copy:剪贴板管理"
    "cliphist:剪贴板历史"
    "wtype:模拟键盘输入(自动粘贴)"
    "fcitx5:输入法"
)

# 询问 WM 选择
echo ""
echo "选择要安装的窗口管理器:"
echo "1) i3"
echo "2) sway"
echo "3) niri"
echo "4) 全部"
read -p "请输入 (1-4): " wm_choice

case $wm_choice in
    1) DEPS+=("i3:窗口管理器" "polybar:状态栏" "rofi:启动器" "feh:壁纸") ;;
    2) DEPS+=("sway:窗口管理器") ;;
    3) DEPS+=("niri:窗口管理器") ;;
    4) DEPS+=("i3" "sway" "niri" "polybar" "rofi" "feh") ;;
esac

for dep in "${DEPS[@]}"; do
    IFS=':' read -r cmd desc <<< "$dep"
    if command -v "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $cmd - $desc"
    else
        echo -e "  ${RED}✗${NC} $cmd - $desc"
        install_package "$cmd"
    fi
done

echo ""
echo -e "${GREEN}=== 初始化完成 ===${NC}"
echo "请注销并重新登录以使用新配置。"
