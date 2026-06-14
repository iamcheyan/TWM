# Waybar 样式与图标大小自定义指南

本指南记录了如何自定义 Waybar 右侧状态栏模块的图标大小、间距以及系统托盘样式的具体方法和文件位置。

---

## 1. 单独调整图标大小

Waybar 状态栏中的图标（如 CPU、内存、剪贴板等）是使用 **Nerd Font 字体图标** 渲染的文本字符。为了在不影响其旁边数字百分比的情况下单独控制图标尺寸，我们使用了 **Pango Markup** 进行包裹。

### 配置文件位置
*   **文件**：`~/.config/waybar/labwc/config.jsonc`

### 调整方法
在配置文件中找到对应模块的 `"format"` 行，修改 `<span font_size='XXXXX'>` 中的数值：
*   `font_size` 的单位是 Pango 字体单位（1pt ≈ 1024）。
*   **常用大小参考**：
    *   `12000` (约 12pt) —— 偏小
    *   `14000` (约 14pt) —— 默认大小
    *   `16000` (约 16pt) —— 偏大
    *   `18000` (约 18pt) —— 特大

### 可调整的模块示例
*   **音量** (`pulseaudio`): 修改第 68、69 行的 `font_size`。
*   **蓝牙** (`bluetooth`): 修改第 82、83、84 行的 `font_size`。
*   **处理器** (`cpu`): 修改第 89 行的 `font_size`。
*   **内存** (`memory`): 修改第 93 行的 `font_size`。
*   **剪贴板** (`custom/cliphist`): 修改第 96 行的 `font_size`。
*   **截图** (`custom/screenshot`): 修改第 102 行的 `font_size`。
*   **语音** (`custom/kazamo`): 修改第 108 行的 `font_size`。
*   **电源** (`custom/power`): 修改第 113 行的 `font_size`。

---

## 2. 调整模块间距与外边距

Waybar 的模块间距和 hover 背景通过 CSS 文件控制。

### 样式文件位置
*   **文件**：`~/.config/waybar/style.css`

### 调整方法

#### A. 自定义功能图标间距 (剪贴板, 截图, 语音, 电源)
在 `style.css` 约第 134 行：
```css
#custom-launcher,
#custom-workspace,
#custom-cliphist,
#custom-screenshot,
#custom-kazamo,
#custom-colorpicker,
#custom-power {
    padding: 0 8px;   /* 左右内边距：增加此值会扩大 hover 时的背景响应区域 */
    margin: 0 4px;    /* 左右外边距：增加此值会直接拉开图标之间的间距 */
    color: #ffffff;
}
```

#### B. 系统状态模块间距 (音量, 蓝牙, CPU, 内存)
在 `style.css` 约第 185 行：
```css
#modules-right>widget>* {
    padding: 0 6px;   /* 左右内边距 */
    margin: 0 3px;    /* 左右外边距 */
}
```

---

## 3. 调整系统托盘 (Tray)

系统托盘显示的是第三方运行应用的图标（如输入法、网盘等），其尺寸与间距需要配合设置。

### 调整位置
1.  **托盘图标大小与间距**（`config.jsonc` 约第 26 行）：
    ```jsonc
    "tray": {
        "spacing": 8,      // 托盘内图标之间的间距（单位：像素）
        "icon-size": 18    // 托盘图标的物理渲染大小
    }
    ```
2.  **托盘在状态栏的边距**（`style.css` 约第 193 行）：
    ```css
    #tray {
        padding: 0 4px;    /* 托盘组件左右内边距 */
        margin: 0 2px;     /* 托盘组件左右外边距 */
        background: transparent;
    }
    ```

---

## 4. 应用更改

完成 `config.jsonc` 或 `style.css` 的修改后，在终端执行以下命令重新加载 Waybar：

```bash
pkill waybar && ~/.config/labwc/scripts/waybar &
```
