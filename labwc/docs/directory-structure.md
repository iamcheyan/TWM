# Labwc 配置目录结构说明

本目录是 Labwc 窗口管理器的核心配置目录（通过软链接 `~/.config/labwc` 链接至 `/home/tetsuya/.config/TWM/labwc/`）。

为了保持环境的整洁与可维护性，所有自定义脚本、配置文件和快捷键均已分类整理。

---

## 目录结构树

```
~/.config/labwc/
├── rc.xml                    # 主配置文件（由 scripts/keybind-profile 自动生成，请勿直接编辑）
├── menu.xml                  # 右键上下文菜单与系统面板菜单定义
├── autostart                 # 启动脚本（管理壁纸、输入法、Waybar 及屏幕缩放检测）
├── environment               # 环境变设置量（声明主题、光标、Wayland 支持等）
│
├── scripts/                  # 状态栏、菜单及快捷键调用的核心脚本目录
│   ├── keybind-profile       # 核心拼装脚本：根据键盘布局拼装 rc.xml
│   ├── keyboard-profile      # 物理键盘布局配置（Mac JIS / 标准 PC）
│   ├── keyboard-menu         # 生成键盘切换管道菜单 (Pipe Menu)
│   ├── launcher              # 呼出/隐藏应用启动器 (wofi)
│   ├── waybar                # 检查并启动 Waybar 顶栏
│   ├── workspace-overview    # 模拟按键呼出工作区总览 (W-Space)
│   ├── output-info           # 在 wofi 弹窗中显示屏幕输出信息
│   │
│   ├── screenshot-keybind    # 快捷键调用的后台截图脚本 ( grim + slurp )
│   ├── screenshot-menu       # 托盘菜单调用的前端截图选择器 ( fuzzel )
│   ├── brightness-control    # 快捷键调用的后台亮度调整 ( brightnessctl )
│   ├── brightness            # 菜单调用的亮度滑块/选择器 ( wofi )
│   ├── audio                 # 菜单调用的音量控制器 ( pactl + wofi )
│   ├── clipboard             # 菜单调用的剪贴板历史选择器 ( cliphist + wofi )
│   │
│   ├── wallpaper             # 菜单调用的壁纸选择器 ( wofi )
│   ├── font-size             # 菜单调用的窗口标题字号微调 ( wofi )
│   ├── gaps                  # 菜单调用的窗口外间距微调 ( wofi )
│   ├── scale                 # 应用屏幕缩放比例 ( wlr-randr )
│   ├── scale-menu            # 生成屏幕缩放选项管道菜单 ( Pipe Menu )
│   ├── theme-switch          # 菜单调用的窗口装饰主题切换器 ( wofi )
│   ├── reload                # 重载合成器配置，并重置壁纸和 Waybar
│   ├── system-menu           # 托盘或快捷键调用的系统关机/重载菜单 ( fuzzel )
│   ├── power-restart         # 快速重启 labwc/waybar 的微型菜单 ( fuzzel )
│   └── wsl-boot              # 专门用于 WSL 下嵌套启动 labwc 的脚本
│
├── keybinds/                 # 供拼装脚本读取的快捷键 XML 片段
│   ├── README.md             # 快捷键详细配置指南
│   ├── mac-jis.xml           # 适配 Apple 键盘的 macOS 风格快捷键（Win 键作为 Cmd）
│   ├── linux.xml             # 标准 Linux 物理键盘的快捷键
│   └── wsl.xml               # 适配 WSLg 环境的快捷键
│
├── environment.d/            # 键盘硬件相关的环境配置目录
│   └── 90-keyboard.env
│
├── themes/                   # 窗口边框与主题资源
│   ├── BL-Lithium-dark/      # 当前激活的窗口修饰与 GTK 混合主题
│   └── Adwaita-Labwc-dark/   # 备用暗色主题
│
└── docs/                     # 针对各项子系统的开发与维护文档
    ├── keybinds/             # 快捷键系统架构文档
    ├── display-scale.md      # 屏幕缩放实现与调试文档
    ├── keyboard-profiles.md  # 键盘配置文件切换原理文档
    ├── hot-corner.md         # 热角配置与行为说明书
    ├── waybar-style-customization.md # Waybar 样式与图标微调文档
    └── directory-structure.md# 本目录结构说明文档 (本文档)
```

---

## 维护原则

1. **修改快捷键**：请勿直接修改 `rc.xml`。应去 `keybinds/` 修改对应的 `.xml` 文件，完成后运行 `scripts/keybind-profile` 重建主配置。
2. **新增脚本**：如果有任何新编写的辅助或系统脚本，请统一放入 `scripts/` 目录中，并在 `rc.xml` 或 `menu.xml` 中以 `~/.config/labwc/scripts/` 路径进行引用。
