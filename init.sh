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

# ========== 系统检测 ==========
detect_os() {
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		OS=$ID
	else
		OS="unknown"
	fi
}

is_fedora()  { [[ "$OS" =~ ^(fedora|rhel|centos)$ ]]; }
is_ubuntu()  { [[ "$OS" =~ ^(ubuntu|debian|linuxmint)$ ]]; }
is_arch()    { [[ "$OS" =~ ^(arch|manjaro)$ ]]; }

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
		vim)
			is_ubuntu && echo "vim" || echo "vim-enhanced"
			;;
		qt5ct)
			is_ubuntu && echo "qt5ct" || echo "qt5ct"
			;;
		qt6ct)
			is_ubuntu && echo "qt6ct" || echo "qt6ct"
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
	"$TWM_DIR/waybar:$HOME/.config/waybar"
	"$TWM_DIR/kitty:$HOME/.config/kitty"
	"$TWM_DIR/xterm:$HOME/.config/xterm"
	"$TWM_DIR/mako:$HOME/.config/mako"
	"$TWM_DIR/wofi:$HOME/.config/wofi"
	"$TWM_DIR/sway:$HOME/.config/sway"
	"$TWM_DIR/labwc:$HOME/.config/labwc"
	"$TWM_DIR/sfwbar:$HOME/.config/sfwbar"
	"$TWM_DIR/i3:$HOME/.config/i3"
	"$TWM_DIR/polybar:$HOME/.config/polybar"
	"$TWM_DIR/cliphist:$HOME/.config/cliphist"
	"$TWM_DIR/dolphin/qt5ct.conf:$HOME/.config/qt5ct/qt5ct.conf"
	"$TWM_DIR/dolphin/qt6ct.conf:$HOME/.config/qt6ct/qt6ct.conf"
	"$TWM_DIR/labwc/scripts:$HOME/.config/labwc/scripts"
	"$TWM_DIR/waybar/scripts:$HOME/.config/waybar/scripts"
)

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
	IFS=':' read -r src tgt <<<"$config"
	name=$(basename "$tgt")
	create_symlink "$src" "$tgt" "$name"
done

mkdir -p "$HOME/.local/share/themes" "$HOME/.themes"
for theme_dir in "$TWM_DIR/labwc/themes"/*; do
	[ -d "$theme_dir" ] || continue
	create_symlink "$theme_dir" "$HOME/.local/share/themes/$(basename "$theme_dir")" "$(basename "$theme_dir") theme"
	create_symlink "$theme_dir" "$HOME/.themes/$(basename "$theme_dir")" "$(basename "$theme_dir") theme (~/.themes)"
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

# ========== 询问 WM 选择 ==========
echo ""
echo "选择要安装的窗口管理器:"
echo "1) i3"
echo "2) sway"
echo "3) niri"
echo "4) labwc"
echo "5) 全部"
read -p "请输入 (1-5): " wm_choice

# ========== 通用依赖 ==========
echo ""
echo "=== 检查依赖软件 ==="

COMMON_DEPS=(
	"kitty:终端模拟器"
	"mako:通知守护进程"
	"wofi:应用启动器"
	"grim:截图工具"
	"slurp:区域选择工具"
	"wl-copy:剪贴板管理"
	"wtype:模拟键盘输入"
	"fcitx5:输入法"
)

# ========== labwc 专属依赖 ==========
LABWC_DEPS=(
	"waybar:状态栏"
	"brightnessctl:亮度控制"
	"wlr-randr:输出缩放"
	"qutebrowser:Web 浏览器"
	"dolphin:文件管理器"
	"vim:文本编辑器"
	"swaybg:壁纸管理器"
	"qt5ct:Qt5 主题"
	"qt6ct:Qt6 主题"
	"kvantum:Qt 主题引擎"
	"pavucontrol:音量控制"
	"blueman:蓝牙管理"
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
	4) DEPS+=("${LABWC_DEPS[@]}") ;;
	5) DEPS+=("sway:窗口管理器" "niri:窗口管理器" "${LABWC_DEPS[@]}" "${I3_DEPS[@]}") ;;
esac

for dep in "${DEPS[@]}"; do
	IFS=':' read -r cmd desc <<<"$dep"
	ensure_cmd "$cmd" "$desc"
done

# ========== cliphist (Go 工具，优先 dnf/apt，fallback go install) ==========
if [[ "$wm_choice" =~ ^[45]$ ]]; then
	echo ""
	echo "=== 安装 cliphist ==="
	if command -v cliphist &>/dev/null; then
		echo "  ${GREEN}✓${NC} cliphist 已安装"
	else
		# 尝试系统包
		set +e
		pkg_install cliphist 2>/dev/null
		set -e
		if ! command -v cliphist &>/dev/null; then
			# fallback: go install
			if command -v go &>/dev/null; then
				echo "  通过 go install 安装 cliphist..."
				go install go.senan.xyz/cliphist@latest
				# 确保 GOPATH/bin 在 PATH 中
				GOPATH_BIN="$(go env GOPATH)/bin"
				if ! echo "$PATH" | grep -q "$GOPATH_BIN"; then
					echo "export PATH=\"\$PATH:$GOPATH_BIN\"" >> "$HOME/.bashrc"
					echo "export PATH=\"\$PATH:$GOPATH_BIN\"" >> "$HOME/.zshrc" 2>/dev/null || true
					export PATH="$PATH:$GOPATH_BIN"
				fi
				echo -e "  ${GREEN}✓${NC} cliphist 已通过 go install 安装"
			else
				echo -e "  ${YELLOW}⚠${NC} cliphist 安装失败：无 dnf/apt 包且 go 未安装"
				echo "    请先安装 Go: https://go.dev/dl/"
			fi
		fi
	fi
fi

# ========== labwc 会话文件 ==========
if [[ "$wm_choice" == "4" || "$wm_choice" == "5" ]]; then
	echo ""
	echo "=== 创建 labwc 会话文件 ==="
	LABWC_DESKTOP="/usr/share/wayland-sessions/labwc.desktop"
	if [ ! -f "$LABWC_DESKTOP" ]; then
		sudo tee "$LABWC_DESKTOP" > /dev/null << 'DESKTOP'
[Desktop Entry]
Name=labwc
Comment=A Wayland compositor based on wlroots
Exec=labwc
Type=Application
DesktopNames=labwc
DESKTOP
		echo -e "${GREEN}✓ labwc 会话文件已创建${NC}"
	else
		echo "✓ labwc 会话文件已存在"
	fi

	# Qt dark theme for Dolphin
	echo ""
	echo "=== Qt Dark Theme (Dolphin) ==="
	bash "$TWM_DIR/dolphin/setup.sh"
fi

# ========== 完成 ==========
echo ""
echo -e "${GREEN}=== 初始化完成 ===${NC}"
echo "请注销并重新登录以使用新配置。"
