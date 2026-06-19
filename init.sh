#!/bin/bash
# TWM 配置初始化脚本 (支持 i3, Sway, Niri, labwc)
# 支持 Fedora / Ubuntu / Debian / Arch

set -e

echo "=== TWM 配置初始化 ==="

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 获取脚本所在目录
TWM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${BLUE}TWM 配置目录: ${TWM_DIR}${NC}"

# ========== dotfiles 软链接 ==========
if [ -d "$HOME/dotfiles" ]; then
	DOTFILES_TWM="$HOME/dotfiles/TWM"
	TWM_CONFIG="$HOME/.config/TWM"

	# 已经是正确指向 dotfiles 的软链接，跳过
	if [ -L "$TWM_CONFIG" ] && [ "$(readlink -f "$TWM_CONFIG")" = "$(readlink -f "$DOTFILES_TWM")" ]; then
		echo -e "${GREEN}✓ $TWM_CONFIG 已指向 ~/dotfiles/TWM${NC}"
	else
		# 把现有真实目录移到 dotfiles
		if [ -d "$TWM_CONFIG" ] && [ ! -L "$TWM_CONFIG" ]; then
			mkdir -p "$(dirname "$DOTFILES_TWM")"
			mv "$TWM_CONFIG" "$DOTFILES_TWM"
			echo "已移动 $TWM_CONFIG → $DOTFILES_TWM"
		fi
		# 确保 dotfiles/TWM 存在后创建软链接
		mkdir -p "$DOTFILES_TWM"
		ln -snf "$DOTFILES_TWM" "$TWM_CONFIG"
		echo -e "${GREEN}✓ 已创建软链接: $TWM_CONFIG → $DOTFILES_TWM${NC}"
	fi

	# TWM_DIR 更新为真实路径（后续脚本使用）
	TWM_DIR="$(readlink -f "$TWM_CONFIG")"
fi

# ========== 系统检测 ==========
detect_os() {
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		OS=$ID
	else
		OS="unknown"
	fi
}

is_fedora()  { [[ "$OS" =~ (fedora|rhel|centos) ]]; }
is_ubuntu()  { [[ "$OS" =~ (ubuntu|debian|linuxmint) ]]; }
is_arch()    { [[ "$OS" =~ (arch|manjaro) ]]; }

detect_os
echo -e "${BLUE}检测到系统: ${OS}${NC}"

# ========== 包管理封装 ==========
pkg_install() {
	local pkg="$1"
	echo -e "  安装: $pkg"
	set +e
	if is_fedora; then
		sudo dnf install -y "$pkg"
	elif is_ubuntu; then
		sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
	elif is_arch; then
		sudo pacman -S --noconfirm --needed "$pkg"
	fi
	set -e
}

# 按命令名查找对应的发行版包名
resolve_pkg() {
	local cmd="$1"
	case "$cmd" in
		wl-copy|wl-paste)   echo "wl-clipboard" ;;
		notify-send)
			is_ubuntu && echo "libnotify-bin" || echo "libnotify"
			;;
		mako)
			is_ubuntu && echo "mako-notifier" || echo "mako"
			;;
		swaync|swaync-client)
			is_fedora && echo "SwayNotificationCenter" || echo "swaync"
			;;
		nwg-look)
			if is_fedora; then
				sudo dnf copr enable -y tofik/nwg-shell >&2 || true
			fi
			echo "nwg-look"
			;;
		Hyprland) echo "hyprland" ;;
		vim)
			is_ubuntu && echo "vim" || echo "vim-enhanced"
			;;
		*) echo "$cmd" ;;
	esac
}

# 检查命令是否存在，不存在则安装
ensure_cmd() {
	local cmd="$1"
	local desc="${2:-$cmd}"
	if command -v "$cmd" &>/dev/null; then
		echo -e "  ${GREEN}✓${NC} $cmd - $desc"
		return 0
	fi
	echo -e "  ${RED}✗${NC} $cmd - $desc (安装中...)"
	local pkg
	pkg=$(resolve_pkg "$cmd")
	pkg_install "$pkg"
}

# ========== 创建软链接 ==========
echo ""
echo "=== 创建配置软链接 ==="

CONFIG_DIRS=(
	"$TWM_DIR/niri:$HOME/.config/niri"
	"$TWM_DIR/hyprland:$HOME/.config/hypr"
	"$TWM_DIR/waybar:$HOME/.config/waybar"
	"$TWM_DIR/kitty:$HOME/.config/kitty"
	"$TWM_DIR/xterm:$HOME/.config/xterm"
	"$TWM_DIR/mako:$HOME/.config/mako"
	"$TWM_DIR/wofi:$HOME/.config/wofi"
	"$TWM_DIR/fuzzel:$HOME/.config/fuzzel"
	"$TWM_DIR/sway:$HOME/.config/sway"
	"$TWM_DIR/sfwbar:$HOME/.config/sfwbar"
	"$TWM_DIR/i3:$HOME/.config/i3"
	"$TWM_DIR/polybar:$HOME/.config/polybar"
	"$TWM_DIR/cliphist:$HOME/.config/cliphist"
	"$TWM_DIR/waybar/scripts:$HOME/.config/waybar/scripts"
	"$TWM_DIR/swaync:$HOME/.config/swaync"
	"$TWM_DIR/labwc/scripts/save-displays:$HOME/.local/bin/save-displays"
)

create_symlink() {
	local target="$1"
	local link_name="$2"
	local config_name="$3"

	# 如果真实路径已经指向同一个地方，直接跳过，防止产生自循环软链接
	if [ -e "$link_name" ] && [ "$(readlink -f "$link_name")" = "$(readlink -f "$target")" ]; then
		echo -e "${GREEN}✓ $config_name 软链接已同步 ($link_name -> $target)${NC}"
		return 0
	fi

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
	IFS=':' read -r src tgt <<<"$config"
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

# ========== 安装 Open Sans 字体 (COSMIC 默认 UI 字体) ==========
echo ""
echo "=== 安装 Open Sans 字体 ==="
if fc-list : family | grep -qi "Open Sans"; then
	echo "✓ Open Sans 字体已安装"
else
	echo "开始安装 Open Sans 字体..."
	set +e
	if is_fedora; then
		sudo dnf install -y google-open-sans-fonts
	elif is_ubuntu; then
		sudo apt-get install -y fonts-open-sans
	elif is_arch; then
		sudo pacman -S --noconfirm ttf-opensans
	fi
	set -e
	fc-cache -fv
	echo -e "${GREEN}✓ Open Sans 字体安装完成${NC}"
fi

# ========== 安装 Ubuntu 字体 ==========
echo ""
echo "=== 安装 Ubuntu 字体 ==="
if fc-list : family | grep -qi "^Ubuntu$"; then
	echo "✓ Ubuntu 字体已安装"
else
	echo "开始下载 Ubuntu 字体..."
	mkdir -p "$FONT_DIR"
	UBUNTU_FONT_URL="https://github.com/canonical/Ubuntu-font-family/raw/master/Ubuntu-R.ttf"
	for style_suffix in "-R" "-RI" "-B" "-BI"; do
		filename="Ubuntu${style_suffix}.ttf"
		[ -f "$FONT_DIR/$filename" ] || curl -fLo "$FONT_DIR/$filename" \
			"https://github.com/canonical/Ubuntu-font-family/raw/master/${filename}"
	done
	fc-cache -f "$FONT_DIR"
	echo -e "${GREEN}✓ Ubuntu 字体安装完成${NC}"
fi

# ========== 安装 Ubuntu Nerd Font ==========
echo ""
echo "=== 安装 Ubuntu Nerd Font ==="
if fc-list : family | grep -qi "Ubuntu Nerd Font"; then
	echo "✓ Ubuntu Nerd Font 已安装"
else
	echo "开始下载 Ubuntu Nerd Font..."
	mkdir -p "$FONT_DIR"
	NERD_FONT_VER="3.4.0"
	NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VER}/Ubuntu.zip"
	NERD_FONT_TMP=$(mktemp -d)
	curl -fLo "$NERD_FONT_TMP/Ubuntu.zip" "$NERD_FONT_URL"
	unzip -o "$NERD_FONT_TMP/Ubuntu.zip" -d "$FONT_DIR" >/dev/null 2>&1
	rm -rf "$NERD_FONT_TMP"
	fc-cache -f "$FONT_DIR"
	echo -e "${GREEN}✓ Ubuntu Nerd Font 安装完成${NC}"
fi

# ========== 询问 WM 选择 ==========
echo ""
echo "选择要安装的窗口管理器:"
echo "1) i3"
echo "2) sway"
echo "3) niri"
echo "4) labwc"
echo "5) hyprland"
echo "6) 全部"
read -p "请输入 (1-6): " wm_choice

# ========== 通用依赖 ==========
echo ""
echo "=== 检查依赖软件 ==="

COMMON_DEPS=(
	"kitty:终端模拟器"
	"swaync:通知中心"
	"wofi:应用启动器"
	"grim:截图工具"
	"slurp:区域选择工具"
	"wl-copy:剪贴板管理"
	"wtype:模拟键盘输入"
	"fcitx5:输入法"
	"pavucontrol:图形化音量控制"
	"blueman:蓝牙管理面板"
	"network-manager-applet:网络托盘图标"
	"nwg-look:外观主题管理器"
	"hyprpicker:屏幕取色器"
	"wdisplays:图形化显示器配置"
	"kanshi:多显示器自动配置"
	"wlr-randr:命令行显示器配置"
)

# ========== i3 专属依赖 ==========
I3_DEPS=(
	"i3:窗口管理器"
	"polybar:状态栏"
	"rofi:启动器"
	"feh:壁纸"
)

# 组装依赖列表
DEPS=("${COMMON_DEPS[@]}")

case $wm_choice in
	1) DEPS+=("${I3_DEPS[@]}") ;;
	2) DEPS+=("sway:窗口管理器") ;;
	3) DEPS+=("niri:窗口管理器") ;;
	4) ;; # labwc 依赖由 labwc/setup.sh 独立处理
	5) ;; # Hyprland 依赖由 hyprland/setup.sh 独立处理
	6) DEPS+=("sway:窗口管理器" "niri:窗口管理器" "${I3_DEPS[@]}") ;;
esac

for dep in "${DEPS[@]}"; do
	IFS=':' read -r cmd desc <<<"$dep"
	ensure_cmd "$cmd" "$desc"
done

# ========== labwc 初始化 ==========
if [[ "$wm_choice" =~ ^[46]$ ]]; then
	echo ""
	echo "=== 初始化 labwc ==="
	bash "$TWM_DIR/labwc/setup.sh"
fi

# ========== Hyprland 初始化 ==========
if [[ "$wm_choice" =~ ^[56]$ ]]; then
	echo ""
	echo "=== 初始化 Hyprland ==="
	bash "$TWM_DIR/hyprland/setup.sh"
fi

# ========== 完成 ==========
echo ""
echo -e "${GREEN}=== 初始化完成 ===${NC}"
echo "请注销并重新登录以使用新配置。"
