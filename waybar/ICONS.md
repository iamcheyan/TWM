# Waybar 高清矢量 SVG 图标配置文档

为了解决传统字符/字体图标（如 Nerd Fonts）在大屏或不同 DPI 下大小不一、样式不协调的问题，本项目已将 Waybar 状态栏图标以及系统全局图标全部切换为基于 **System76 Cosmic** 的高清 SVG 矢量图方案。

---

## 📂 文件结构与路径

1. **SVG 图标存放目录：** `~/.config/waybar/icons/`
   所有的 SVG 图标均被提取并存放于此，已转换并优化为适合深色主题的白色填充。
   * `volume-high.svg` / `volume-muted.svg` - 声音状态
   * `bluetooth-active.svg` / `bluetooth-disabled.svg` - 蓝牙状态
   * `cpu.svg` / `memory.svg` - CPU & 内存状态
   * `cliphist.svg` - 剪贴板历史
   * `screenshot.svg` - 截图
   * `kazamo.svg` - 录像
   * `power.svg` - 电源/关机

2. **样式控制文件：** `~/.config/waybar/labwc/style.css`
   通过 CSS 属性控制背景图的高清显示、精确间距和 Hover 状态尺寸锁定。

---

## 🎨 关键渲染机制（防发虚 & 悬停尺寸锁定）

### 1. 防发虚原理 (HiDPI Sharpness Fix)
GTK 的 CSS 渲染器默认会以 SVG 文件的 `width` 和 `height` 属性（通常是 `16px`）在内存中将其栅格化为位图，然后拉伸显示在屏幕上，导致高分屏下图标变虚。
* **解决方式**：图标的 SVG 源码中，画布尺寸已被强制定义为 `width="64"` 和 `height="64"`（而 `viewBox` 依然为 `0 0 16 16`）。这样 GTK 会以高分辨率栅格化它，再通过 CSS 的 `background-size: 16px 16px;` 进行下采样缩小，在 2K/4K 屏幕上也能保持完美的锐利度。

### 2. 悬停尺寸与透明度锁定 (Hover Fix)
主样式表 `style.css` 中的 `button:hover` 等选择器使用了 `background: transparent;` 等复合属性，会无意中将模块的 `background-image` 重置，导致悬停时图标消失。此外还会改变 `padding`。
* **解决方式**：在 `labwc/style.css` 中，为所有带图标模块的 `:hover` 状态显式重写了 `background-image`、`padding` 和 `margin`。无论鼠标是否指针悬停，空间分布和大小都会被完全锁定。

---

## 🔄 自动化部署 (`init.sh`)

修改已无缝整合进入系统的初始化脚本 `init.sh`。执行该脚本时，将会自动完成以下步骤：

1. **自动安装/下载**：
   * 优先尝试通过系统的包管理器（如 `dnf`、`apt` 或 `pacman`）安装 `cosmic-icon-theme`。
   * 若发行版软件源中没有打包，脚本会自动从 System76 官方 GitHub 仓库下载这 10 个高清 SVG 源文件到本地。
2. **自动图像优化**：
   * 自动用 `sed` 命令将黑灰底色 `#232323` 全量替换为白色 `#ffffff`。
   * 自动将画布拉伸为 `64x64`。
3. **配置全局图标主题**：
   * 自动在 `~/.config/gtk-3.0/settings.ini` 和 `~/.config/gtk-4.0/settings.ini` 中追加 `gtk-icon-theme-name=Cosmic`。
   * 自动执行 `gsettings set org.gnome.desktop.interface icon-theme "Cosmic"` 刷新系统托盘。

---

## 🛠 自定义修改指南

如果您需要自己更换某个模块的图标：
1. 准备好您想要的 SVG 图标文件。
2. 打开该 SVG 源码，确保最外层的 `<svg>` 标签中含有 `width="64" height="64"`，且 `fill`（填充色）为 `#ffffff`。
3. 将图标放入 `~/.config/waybar/icons/`。
4. 修改 `~/.config/waybar/labwc/style.css` 中对应模块的 `background-image` 路径指向您的新图标。
5. 重新加载状态栏：
   ```bash
   ~/.config/labwc/scripts/reload
   ```
