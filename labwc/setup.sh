#!/bin/bash
# labwc 独立初始化脚本
# 可从 init.sh 调用，也可单独执行: ./labwc/setup.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

TWM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo -e "${BLUE}TWM 配置目录: ${TWM_DIR}${NC}"

# ========== 系统检测 ==========
detect_os() {
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		OS=$ID
		OS_LIKE=${ID_LIKE:-}
	else
		OS="unknown"
		OS_LIKE=""
	fi
}

is_fedora()  { [[ "$OS $OS_LIKE" =~ (fedora|rhel|centos) ]]; }
is_ubuntu()  { [[ "$OS $OS_LIKE" =~ (ubuntu|debian|linuxmint) ]]; }
is_arch()    { [[ "$OS $OS_LIKE" =~ (arch|manjaro) ]]; }

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
		plasma-integration)
			echo "plasma-integration"
			;;
		quickshell)
			echo "quickshell"
			;;
		qt6-qtwayland)
			is_ubuntu && echo "qt6-wayland" && return
			is_arch && echo "qt6-wayland" && return
			echo "qt6-qtwayland"
			;;
		qt5-qtwayland)
			is_ubuntu && echo "qtwayland5" && return
			is_arch && echo "qt5-wayland" && return
			echo "qt5-qtwayland"
			;;
		breeze-icon-theme)
			is_arch && echo "breeze-icons" || echo "breeze-icon-theme"
			;;
		breeze-gtk)
			echo "breeze-gtk"
			;;
		go)
			is_arch && echo "go" || echo "golang"
			;;
		pactl)
			is_fedora && echo "pipewire-pulseaudio" || echo "pipewire-pulse"
			;;
		*) echo "$cmd" ;;
	esac
}

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
echo "=== 创建 labwc 配置软链接 ==="

create_symlink() {
	local target="$1"
	local link_name="$2"
	local config_name="$3"

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

LABWC_SYMLINKS=(
	"$TWM_DIR/labwc:$HOME/.config/labwc"
	"$TWM_DIR/labwc/scripts:$HOME/.config/labwc/scripts"
	"$TWM_DIR/qs:$HOME/.config/quickshell/labwc"
)

for config in "${LABWC_SYMLINKS[@]}"; do
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

# ========== 配置 Waybar 高清图标与系统图标主题 ==========
echo ""
echo "=== 配置 Waybar 图标与 GTK 图标主题 ==="

echo "尝试通过系统包管理器安装 cosmic-icon-theme..."
set +e
pkg_install cosmic-icon-theme
set -e

COSMIC_LOCAL="/usr/share/icons/Cosmic/scalable"
COSMIC_USER_THEME="$HOME/.local/share/icons/Cosmic"

if [ ! -d "$COSMIC_LOCAL" ]; then
    if [ ! -d "$COSMIC_USER_THEME" ]; then
        echo "包管理器未成功安装且本地未检测到主题，正在从 GitHub 克隆完整 Cosmic 图标主题..."
        mkdir -p "$HOME/.local/share/icons"
        git clone --depth 1 https://github.com/pop-os/cosmic-icons.git "$COSMIC_USER_THEME"
    else
        echo "✓ 本地用户目录已存在 Cosmic 图标主题"
    fi
    if [ -d "$COSMIC_USER_THEME/freedesktop/scalable" ]; then
        COSMIC_LOCAL="$COSMIC_USER_THEME/freedesktop/scalable"
    else
        COSMIC_LOCAL="$COSMIC_USER_THEME/scalable"
    fi
fi

ICONS_DIR="$TWM_DIR/waybar/icons"
mkdir -p "$ICONS_DIR"

ICON_LIST=(
    "status/audio-volume-high-symbolic.svg:volume-high.svg"
    "status/audio-volume-muted-symbolic.svg:volume-muted.svg"
    "status/bluetooth-active-symbolic.svg:bluetooth-active.svg"
    "status/bluetooth-disabled-symbolic.svg:bluetooth-disabled.svg"
    "apps/utilities-system-monitor-symbolic.svg:cpu.svg"
    "apps/utilities-system-monitor-symbolic.svg:memory.svg"
    "actions/edit-paste-symbolic.svg:cliphist.svg"
    "apps/accessories-screenshot-symbolic.svg:screenshot.svg"
    "devices/camera-video-symbolic.svg:kazamo.svg"
    "actions/system-shutdown-symbolic.svg:power.svg"
)

for item in "${ICON_LIST[@]}"; do
    IFS=':' read -r src_rel dest_name <<< "$item"
    dest_path="$ICONS_DIR/$dest_name"
    
    if [ -f "$COSMIC_LOCAL/$src_rel" ]; then
        cp "$COSMIC_LOCAL/$src_rel" "$dest_path"
    else
        echo "本地未找到该图标，从 GitHub 下载: $dest_name..."
        COSMIC_REMOTE="https://raw.githubusercontent.com/pop-os/cosmic-icons/master/freedesktop/scalable"
        curl -fLo "$dest_path" "$COSMIC_REMOTE/$src_rel" || echo -e "${RED}下载 $dest_name 失败${NC}"
    fi
    
    if [ -f "$dest_path" ]; then
        sed -i 's/fill="#232323"/fill="#ffffff"/g' "$dest_path"
        sed -i 's/<svg width="[0-9][0-9]*" height="[0-9][0-9]*"/<svg width="64" height="64"/g' "$dest_path"
    fi
done

echo "设置 GTK 图标主题为 breeze-dark..."
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
for version in 3.0 4.0; do
    SETTINGS_FILE="$HOME/.config/gtk-$version/settings.ini"
    if [ -f "$SETTINGS_FILE" ]; then
        if grep -q "gtk-icon-theme-name" "$SETTINGS_FILE"; then
            sed -i 's/gtk-icon-theme-name=.*/gtk-icon-theme-name=breeze-dark/g' "$SETTINGS_FILE"
        else
            echo -e "\n[Settings]\ngtk-icon-theme-name=breeze-dark" >> "$SETTINGS_FILE"
        fi
    else
        echo -e "[Settings]\ngtk-icon-theme-name=breeze-dark" > "$SETTINGS_FILE"
    fi
done

if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface icon-theme "breeze-dark" 2>/dev/null || true
fi
echo -e "${GREEN}✓ 图标主题与状态栏图标配置完成${NC}"

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

# ========== 安装 Open Sans 字体 ==========
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

# ========== labwc 依赖安装 ==========
echo ""
echo "=== 安装 labwc 依赖 ==="

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

LABWC_DEPS=(
	"brightnessctl:亮度控制"
	"wlr-randr:输出缩放"
	"qutebrowser:Web 浏览器"
	"firefox:Firefox 浏览器 (HiDPI)"
	"dolphin:文件管理器"
	"vim:文本编辑器 (vim)"
	"gvim:文本编辑器 (gVim GUI)"
	"alacritty:终端模拟器 (menu)"
	"btop:资源监控器"
	"htop:进程监控器"
	"fuzzel:应用启动器 (脚本依赖)"
	"bc:计算器 (firefox-hidpi)"
	"swaybg:壁纸管理器"
	"quickshell:QtQuick 桌面 Shell / 状态栏"
	"plasma-integration:KDE/Qt 平台主题集成"
	"qt6-qtwayland:Qt6 Wayland 支持"
	"qt5-qtwayland:Qt5 Wayland 支持"
	"breeze-icon-theme:KDE Breeze 图标主题"
	"breeze-gtk:Breeze GTK 主题 (GNOME/GTK 兼容)"
	"pavucontrol:音量控制"
	"pactl:音频控制 (pipewire-pulse)"
	"blueman:蓝牙管理"
)

DEPS=("${COMMON_DEPS[@]}" "${LABWC_DEPS[@]}")

for dep in "${DEPS[@]}"; do
	IFS=':' read -r cmd desc <<<"$dep"
	ensure_cmd "$cmd" "$desc"
done

# ========== hyprpicker (取色器，需从源码编译) ==========
echo ""
echo "=== 安装 hyprpicker ==="
if command -v hyprpicker &>/dev/null; then
	echo "  ${GREEN}✓${NC} hyprpicker 已安装"
else
	echo "  安装编译依赖..."
	if is_fedora; then
		HYPRPICKER_BUILD_DEPS=(
			cmake gcc-c++ hyprutils-devel hyprwayland-scanner-devel
			wayland-devel wayland-protocols-devel libxkbcommon-devel
			cairo-devel pango-devel libjpeg-turbo-devel
		)
	elif is_ubuntu; then
		HYPRPICKER_BUILD_DEPS=(
			cmake g++ hyprutils-dev hyprwayland-scanner
			libwayland-dev wayland-protocols libxkbcommon-dev
			libcairo2-dev libpango1.0-dev libjpeg-dev
		)
	elif is_arch; then
		HYPRPICKER_BUILD_DEPS=(
			cmake gcc hyprutils hyprwayland-scanner
			wayland wayland-protocols libxkbcommon
			cairo pango libjpeg-turbo
		)
	fi
	for pkg in "${HYPRPICKER_BUILD_DEPS[@]}"; do
		set +e
		pkg_install "$pkg"
		set -e
	done
	echo "  克隆 hyprpicker 源码..."
	HYPRPICKER_TMP=$(mktemp -d)
	git clone --depth 1 https://github.com/hyprwm/hyprpicker.git "$HYPRPICKER_TMP"
	echo "  编译 hyprpicker..."
	cd "$HYPRPICKER_TMP"
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -B build
	cmake --build build -j"$(nproc)"
	sudo cmake --install build
	cd "$TWM_DIR"
	rm -rf "$HYPRPICKER_TMP"
	if command -v hyprpicker &>/dev/null; then
		echo -e "  ${GREEN}✓${NC} hyprpicker 编译安装完成"
	else
		echo -e "  ${YELLOW}⚠${NC} hyprpicker 安装失败，请手动编译: https://github.com/hyprwm/hyprpicker"
	fi
fi

# ========== cliphist ==========
echo ""
echo "=== 安装 cliphist ==="
if command -v cliphist &>/dev/null; then
	echo "  ${GREEN}✓${NC} cliphist 已安装"
else
	set +e
	pkg_install cliphist 2>/dev/null
	set -e
	if ! command -v cliphist &>/dev/null; then
		if ! command -v go &>/dev/null; then
			echo "  检测到 go 未安装，尝试自动安装 go..."
			go_pkg=$(resolve_pkg go)
			pkg_install "$go_pkg"
		fi
		if command -v go &>/dev/null; then
			echo "  通过 go install 安装 cliphist..."
			go install go.senan.xyz/cliphist@latest
			GOPATH_BIN="$(go env GOPATH)/bin"
			if ! echo "$PATH" | grep -q "$GOPATH_BIN"; then
				echo "export PATH=\"\$PATH:$GOPATH_BIN\"" >> "$HOME/.bashrc"
				echo "export PATH=\"\$PATH:$GOPATH_BIN\"" >> "$HOME/.zshrc" 2>/dev/null || true
				export PATH="$PATH:$GOPATH_BIN"
			fi
			echo -e "  ${GREEN}✓${NC} cliphist 已通过 go install 安装"
		else
			echo -e "  ${YELLOW}⚠${NC} cliphist 安装失败：无 dnf/apt 包且无法安装 go"
			echo "    请手动安装 cliphist 或 Go: https://go.dev/dl/"
		fi
	fi
fi

# ========== labwc 会话文件 ==========
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

# ========== Qt Dark Theme (Dolphin) ==========
echo ""
echo "=== Qt Dark Theme (Dolphin) ==="
bash "$TWM_DIR/dolphin/setup.sh"

# ========== 完成 ==========
echo ""
echo -e "${GREEN}=== labwc 初始化完成 ===${NC}"
echo "请注销并重新登录以使用新配置。"
