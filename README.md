# TWM：Niri / Sway / i3 三套窗口管理器配置

这是一套支持 **Niri / Sway / i3** 的桌面配置。Niri 与 Sway 共享同一套模块（Waybar/Kitty/Mako/Wofi/壁纸/脚本），只在窗口管理器配置上分开；加入 i3 是为了让用户在 X11 下也能有一个可用的兼容环境。项目提供一键初始化脚本，完成软链接与字体准备，省去繁琐的逐项拷贝与排查。

## 一键配置

首次使用只需执行一次脚本，即可创建软链接并安装字体：

```bash
mkdir -p ~/.config/TWM
git clone https://github.com/iamcheyan/TWM.git ~/.config/TWM
cd ~/.config/TWM
chmod +x init.sh
./init.sh
```

脚本会自动备份已有配置并创建链接，Waybar 会根据 WM 自动加载对应配置：
- `~/.config/waybar/niri/config.jsonc`
- `~/.config/waybar/sway/config.jsonc`

## 依赖安装（按 WM 分开）

Wayland（Niri/Sway）使用 `mako`，i3（X11）使用 `dunst`。

### Sway

Debian/Ubuntu：

```bash
sudo apt update
sudo apt install -y sway waybar kitty swaybg mako wofi fcitx5 \
  brightnessctl grim slurp wl-clipboard libnotify-bin
```

Fedora：

```bash
sudo dnf install -y sway waybar kitty swaybg mako wofi fcitx5 \
  brightnessctl grim slurp wl-clipboard libnotify
```

Arch：

```bash
sudo pacman -S --needed sway waybar kitty swaybg mako wofi fcitx5 \
  brightnessctl grim slurp wl-clipboard libnotify
```

### i3

Debian/Ubuntu：

```bash
sudo apt update
sudo apt install -y i3 polybar rofi feh xterm dunst fcitx5 \
  maim xclip libnotify-bin x11-xserver-utils x11-xkb-utils
```

Fedora：

```bash
sudo dnf install -y i3 rofi feh xterm dunst fcitx5 \
  maim xclip libnotify polybar xrandr xorg-x11-xkb-utils
```

Arch：

```bash
sudo pacman -S --needed i3 rofi feh xterm dunst fcitx5 \
  maim xclip libnotify polybar xorg-xrandr xorg-setxkbmap
```

## 界面截图

![TWM Desktop Screenshot 1](https://pbs.twimg.com/media/G9fnjRUaEAEIPwl?format=png&name=4096x4096)

![TWM Desktop Screenshot 2](https://pbs.twimg.com/media/G9fnG6MaUAAZ356?format=jpg&name=4096x4096)

## 目录结构

```
~/.config/TWM/
├── niri/                  # Niri 配置
│   └── config.kdl
├── sway/                  # Sway 配置
│   ├── config
│   └── README.md
├── i3/                    # i3 配置
│   └── config
├── polybar/               # Polybar 配置（i3 可选）
│   ├── config.ini
│   ├── launch.sh
│   └── scripts/
├── waybar/                # Waybar 配置（按 WM 区分）
│   ├── niri/config.jsonc
│   ├── sway/config.jsonc
│   └── style.css
├── kitty/                 # Kitty 终端配置
├── mako/                  # Mako 通知配置
├── wofi/                  # Wofi 启动器配置
├── background.png         # 壁纸
├── init.sh                # 一键初始化脚本（软链接 + 字体）
└── push.sh
```

## 通用模块（Niri / Sway 共用）

- Waybar
- Kitty
- Mako
- Wofi
- 背景图片 `background.png`
- 初始化脚本 `init.sh`

## 软链接清单

脚本会在目标目录已有文件时自动备份，然后创建链接：
- `~/.config/niri` → `~/.config/TWM/niri`
- `~/.config/sway` → `~/.config/TWM/sway`
- `~/.config/i3` → `~/.config/TWM/i3`
- `~/.config/waybar` → `~/.config/TWM/waybar`
- `~/.config/kitty` → `~/.config/TWM/kitty`
- `~/.config/mako` → `~/.config/TWM/mako`
- `~/.config/wofi` → `~/.config/TWM/wofi`

---

## Niri 使用方法

启动 Niri 后会自动拉起：
- Waybar（`~/.config/waybar/niri/config.jsonc`）
- swaybg（壁纸）
- fcitx5
- mako

### Niri 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Super + Enter` | 打开 Kitty |
| `Super + D` | 打开 Wofi |
| `Super + Q` | 关闭窗口 |
| `Super + Ctrl + Alt + Shift + Q` | 退出 Niri |
| `Super + Left/Right` | 焦点左/右列 |
| `Super + Shift + Left/Right` | 移动列到左/右（或显示器） |
| `Super + F` | 全屏切换 |
| `Super + A` | Overview 模式 |
| `Super + Shift + H/L/K/J` | 调整窗口宽高 (-/+10%) |
| `Super + 1..5` | 切换工作区 1..5 |
| `Super + Tab` | 下一个工作区 |
| `Super + Shift + Tab` | 上一个工作区 |
| `Alt + Tab` | 当前工作区窗口切换 |
| `Alt + Shift + Tab` | 反向切换 |
| `Alt + \`` | 当前应用窗口切换 |
| `PrtSc` | 全屏截图到剪贴板 |
| `Alt + PrtSc` | 全屏截图保存到 Downloads |
| `Shift + PrtSc` | 选区截图保存到 Downloads |
| `Alt + A` | 选区截图到剪贴板 |

---

## Sway 使用方法

启动 Sway 后会自动拉起：
- Waybar（`~/.config/waybar/sway/config.jsonc`）
- swaybg（壁纸）
- fcitx5

窗口切换器脚本：`sway/scripts/window_switcher.sh`（`Super + W`）

### Sway 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Super + Enter` | 打开 Kitty |
| `Super + D` | 打开 Wofi |
| `Super + W` | 窗口切换器 |
| `Super + Q` | 关闭窗口 |
| `Super + F` | 全屏切换 |
| `Alt + Tab` | 当前工作区窗口切换 |
| `Alt + Shift + Tab` | 反向切换 |
| `Super + Tab` | 下一个工作区 |
| `Super + Shift + Tab` | 上一个工作区 |
| `Super + H/J/K/L` | 焦点左/下/上/右 |
| `Super + ←/→/↑/↓` | 移动窗口 |
| `Super + 1..0` | 切换工作区 1..0 |
| `Super + Shift + 1..0` | 移动窗口到工作区 |
| `PrtSc` | 全屏截图到剪贴板 |
| `Alt + PrtSc` | 全屏截图保存到 Downloads |
| `Shift + PrtSc` | 选区截图保存到 Downloads |
| `Alt + A` | 选区截图到剪贴板 |

### Sway 模式快捷键

| 快捷键 | 功能 |
|--------|------|
| `Super + M` | 进入移动模式（h/j/k/l 或方向键移动） |
| `Super + R` | 进入调整大小模式（h/j/k/l，Shift 为大步） |
| `Super + P` | 进入 Panel 模式（a/s 切换，x 关闭，f 全屏） |
| `Super + T` | Tab 模式（h/l 切换，x 关闭，Tab 布局切换） |
| `Super + A` | Workspace 模式（数字/字母切换，n/m 前后） |

---

## i3 使用方法

启动 i3 后会自动拉起：
- polybar（替代 i3bar）
- feh（壁纸）
- fcitx5
- dunst
注：i3 使用 xrandr 做缩放，数值是对 sway fractional scale 的近似，可按需微调。
首次使用可运行脚本自动选择输出与缩放，并写入本地配置：

```bash
~/.config/TWM/i3/scripts/setup-xrandr-scale.sh
```

### i3 快捷键（与 Sway 尽量一致）

| 快捷键 | 功能 |
|--------|------|
| `Super + Enter` | 打开 Kitty |
| `Super + D` | 打开 rofi |
| `Super + Q` | 关闭窗口 |
| `Super + F` | 全屏切换 |
| `Alt + Tab` | 当前工作区窗口切换 |
| `Alt + Shift + Tab` | 反向切换 |
| `Super + Tab` | 下一个工作区 |
| `Super + Shift + Tab` | 上一个工作区 |
| `Super + H/J/K/L` | 焦点左/下/上/右 |
| `Super + ←/→/↑/↓` | 移动窗口 |
| `Super + 1..0` | 切换工作区 1..0 |
| `Super + Shift + 1..0` | 移动窗口到工作区 |
| `PrtSc` | 全屏截图到剪贴板 |
| `Alt + PrtSc` | 全屏截图保存到 Downloads |
| `Shift + PrtSc` | 选区截图保存到 Downloads |
| `Alt + A` | 选区截图到剪贴板 |

### Polybar（尽量对齐 Waybar）

配置文件：`~/.config/TWM/polybar/config.ini`

启动示例：

```bash
polybar -c ~/.config/TWM/polybar/config.ini main
```
