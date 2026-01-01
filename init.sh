#!/bin/bash
# Niri 配置初始化脚本

set -e

echo "=== Niri 配置初始化 ==="

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 获取脚本所在目录（niri 配置目录）
TWM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "TWM_DIR: $TWM_DIR"

echo -e "${BLUE}Niri 配置目录: ${TWM_DIR}${NC}"

# ========== 创建软链接 ==========
echo ""
echo "=== 创建配置软链接 ==="

# 配置目录列表（方便维护）
# 格式：源路径:目标路径
CONFIG_DIRS=(
    "$TWM_DIR/niri:$HOME/.config/niri"
    "$TWM_DIR/waybar:$HOME/.config/waybar"
    "$TWM_DIR/kitty:$HOME/.config/kitty"
    "$TWM_DIR/mako:$HOME/.config/mako"           # 通知守护进程
    "$TWM_DIR/wofi:$HOME/.config/wofi"           # Wayland 应用启动器
    "$TWM_DIR/sway:$HOME/.config/sway"           # Sway 配置
)

# 函数：创建软链接（如果存在则备份）
create_symlink() {
    local target="$1"
    local link_name="$2"
    local config_name="$3"
    
    if [ -e "$link_name" ] && [ ! -L "$link_name" ]; then
        # 存在但不是软链接，进行备份
        backup_name="${link_name}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "⚠ $config_name 已存在真实路径，备份到: $backup_name"
        mv "$link_name" "$backup_name"
    fi
    
    # 使用 -snf 强制创建或更新软链接
    # -s: 软链接
    # -n: 如果目标已是目录链接，视为文件处理（防止在目录下创建子链接）
    # -f: 强制覆盖
    ln -snf "$target" "$link_name"
    echo -e "${GREEN}✓ $config_name 软链接已同步 ($link_name -> $target)${NC}"
}

# 遍历配置列表创建软链接
for config in "${CONFIG_DIRS[@]}"; do
    # 分割源路径和目标路径
    IFS=':' read -r src tgt <<< "$config"
    name=$(basename "$tgt")
    create_symlink "$src" "$tgt" "$name"
done

# ========== 安装 MesloLGS Nerd Font ==========
echo ""
echo "=== 安装 MesloLGS Nerd Font ==="

FONT_DIR="$HOME/.local/share/fonts"
FONT_NAME="MesloLGS NF"

# 检查字体是否已安装
if fc-list | grep -qi "MesloLGS"; then
    echo "✓ MesloLGS Nerd Font 已安装"
else
    echo "开始下载 MesloLGS Nerd Font..."
    
    # 创建字体目录
    mkdir -p "$FONT_DIR"
    
    # 下载字体文件
    FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
    
    cd "$FONT_DIR"
    
    for style in Regular Bold Italic "Bold Italic"; do
        filename="MesloLGS NF ${style}.ttf"
        url_filename=$(echo "$filename" | sed 's/ /%20/g')
        
        if [ -f "$filename" ]; then
            echo "  ✓ $filename 已存在"
        else
            echo "  下载 $filename..."
            curl -fLo "$filename" "${FONT_BASE_URL}/${url_filename}" || {
                echo "  ⚠ 下载 $filename 失败，跳过"
                continue
            }
        fi
    done
    
    # 刷新字体缓存
    echo "刷新字体缓存..."
    fc-cache -f "$FONT_DIR"
    
    echo -e "${GREEN}✓ MesloLGS Nerd Font 安装完成${NC}"
fi

# ========== 检查依赖软件 ==========
echo ""
echo "=== 检查依赖软件 ==="

# 必需软件列表
REQUIRED_DEPS=(
    "niri:窗口管理器"
    "waybar:状态栏"
    "kitty:终端模拟器"
    "swaybg:壁纸管理器"
    "mako:通知守护进程"
    "wofi:应用启动器"
)

# 截图相关软件
SCREENSHOT_DEPS=(
    "grim:截图工具"
    "slurp:区域选择工具"
    "wl-copy:剪贴板工具 (wl-clipboard)"
    "notify-send:通知工具 (libnotify)"
)

echo ""
echo "必需软件："
for dep in "${REQUIRED_DEPS[@]}"; do
    IFS=':' read -r cmd desc <<< "$dep"
    if command -v "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $cmd - $desc"
    else
        echo -e "  ${RED}✗${NC} $cmd - $desc (未安装)"
    fi
done

echo ""
echo "截图功能依赖："
for dep in "${SCREENSHOT_DEPS[@]}"; do
    IFS=':' read -r cmd desc <<< "$dep"
    if command -v "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $cmd - $desc"
    else
        echo -e "  ${RED}✗${NC} $cmd - $desc (未安装)"
    fi
done

# ========== 完成 ==========
echo ""
echo -e "${GREEN}=== 初始化完成 ===${NC}"
echo ""
echo "配置说明："
echo "  - Waybar 配置: ~/.config/waybar -> $TWM_DIR/waybar"
echo "  - Kitty 配置:  ~/.config/kitty -> $TWM_DIR/kitty"
echo "  - 字体已安装: MesloLGS Nerd Font"
echo ""
echo "提示："
echo "  - 重启 Waybar: pkill waybar && waybar &"
echo "  - 重启 Kitty: 关闭所有窗口后重新打开"
echo "  - 在 Kitty 配置中使用字体: font_family MesloLGS Nerd Font Mono"
