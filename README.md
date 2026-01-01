# Niri 配置文件

这是我的 Niri 窗口管理器配置，包含了完整的桌面环境设置。

## 📁 目录结构

```
~/.config/niri/
├── config.kdl          # Niri 主配置文件
├── init.sh             # 初始化脚本（创建软链接、安装字体）
├── background.png      # 桌面壁纸
├── waybar/             # Waybar 状态栏配置
├── kitty/              # Kitty 终端配置
└── mako/               # Mako 通知守护进程配置
```

## 🚀 快速开始

### 初始化配置

运行初始化脚本来设置软链接和安装字体：

```bash
cd ~/.config/niri
chmod +x init.sh
./init.sh
```

初始化脚本会：
- 创建 Waybar、Kitty、Mako 配置的软链接
- 安装 MesloLGS Nerd Font 字体
- 备份已存在的配置文件

### 添加新配置

要添加新的配置目录（如 rofi、wofi 等），编辑 `init.sh` 中的 `CONFIG_DIRS` 数组：

```bash
CONFIG_DIRS=(
    "Waybar:waybar"
    "Kitty:kitty"
    "Mako:mako"
    "Rofi:rofi"      # 添加新配置
)
```

## ⌨️ 快捷键

### 窗口管理

| 快捷键 | 功能 |
|--------|------|
| `Super + Enter` | 打开 Kitty 终端 |
| `Super + D` | 打开 Wofi 应用启动器 |
| `Super + Q` | 关闭当前窗口 |
| `Super + Shift + E` | 退出 Niri |
| `Super + Shift + F` | 全屏切换 |
| `Super + Tab` | 显示窗口概览 |
| `Super + Shift + L` | 锁定会话 |

### 窗口焦点

| 快捷键 | 功能 |
|--------|------|
| `Super + ←` | 焦点移到左侧窗口 |
| `Super + →` | 焦点移到右侧窗口 |

### 窗口移动

| 快捷键 | 功能 |
|--------|------|
| `Super + Shift + ←` | 移动窗口到左侧/左侧显示器 |
| `Super + Shift + →` | 移动窗口到右侧/右侧显示器 |

### 窗口大小调整（Vim 风格）

| 快捷键 | 功能 |
|--------|------|
| `Super + Ctrl + H` | 减少窗口宽度 (-10%) |
| `Super + Ctrl + L` | 增加窗口宽度 (+10%) |
| `Super + Ctrl + K` | 减少窗口高度 (-10%) |
| `Super + Ctrl + J` | 增加窗口高度 (+10%) |

### 截图

| 快捷键 | 功能 | 保存位置 |
|--------|------|----------|
| `PrtSc` | 全屏截图 | 剪贴板 |
| `Alt + PrtSc` | 全屏截图 | ~/Downloads/ |
| `Shift + PrtSc` | 区域截图 | ~/Downloads/ |
| `Alt + A` | 区域截图 | 剪贴板 |

> 截图后会通过 Mako 发送通知

## 🎨 自动启动程序

- **Waybar** - 顶部状态栏
- **swaybg** - 壁纸管理器
- **fcitx5** - 输入法框架
- **Mako** - 通知守护进程

## 🖥️ 显示器配置

配置了双显示器设置：
- **DP-1** (外接显示器): 2x 缩放，位于上方
- **eDP-1** (笔记本屏幕): 1.5x 缩放，位于下方

## 📦 依赖软件

### 必需
- `niri` - 窗口管理器
- `waybar` - 状态栏
- `kitty` - 终端模拟器
- `swaybg` - 壁纸管理器
- `fcitx5` - 输入法

### 可选
- `wofi` - 应用启动器
- `mako` - 通知守护进程
- `grim` - 截图工具
- `slurp` - 区域选择工具
- `wl-clipboard` - 剪贴板工具
- `libnotify` - 通知库（提供 `notify-send`）

## 🔧 配置说明

### 键盘布局
默认使用日语键盘布局。要切换到中英文布局，在 `config.kdl` 中取消注释：

```kdl
layout "us,cn"
options "grp:win_space_toggle"
```

### 动画
动画已关闭以提高性能。要启用动画，修改 `config.kdl`：

```kdl
animations {
    // 根据需要配置动画
}
```

## 📝 维护

### 更新配置
修改配置后，重新加载 Niri：
```bash
# Niri 会自动检测配置文件变化并重新加载
```

### 重启组件
```bash
# 重启 Waybar
pkill waybar && waybar &

# 重启 Mako
pkill mako && mako &

# 重启壁纸
pkill swaybg && swaybg -i ~/.config/niri/background.png -m fill &
```

## 🔗 相关链接

- [Niri 官方文档](https://github.com/YaLTeR/niri)
- [Waybar 文档](https://github.com/Alexays/Waybar)
- [Kitty 文档](https://sw.kovidgoyal.net/kitty/)
- [Mako 文档](https://github.com/emersion/mako)
