# 多显示器管理

## 概述

labwc 的 `rc.xml` 支持 `<output>` 标签来配置显示器，但手写 XML 既不直观也不灵活。推荐使用以下两个工具组合管理多显示器：

| 工具 | 用途 | 适用场景 |
|------|------|----------|
| **wdisplays** | GUI 拖拽式即时调整 | 临时调整、初次排版 |
| **kanshi** | 自动切换预设配置 | 笔记本插拔、多场景切换 |

## 安装

```bash
# Fedora
sudo dnf install wdisplays kanshi

# Arch
sudo pacman -S wdisplays kanshi

# Debian/Ubuntu
sudo apt install wdisplays kanshi
```

---

## wdisplays — 可视化拖拽工具

打开终端运行：

```bash
wdisplays
```

### 使用方法

1. 窗口中会显示当前所有显示器的布局（带名称和分辨率）
2. **拖拽** 显示器方块来调整相对位置
3. 点击某个显示器可以修改：
   - 分辨率（Resolution）
   - 缩放比例（Scale）
   - 刷新率
   - 旋转方向
4. 点击 **Apply** 即时生效

### 特点

- **即时生效**：通过 wlr-output-management 协议直接控制 labwc，点击 Apply 后立刻改变
- **无需写配置**：不修改 `rc.xml`，纯粹通过 Wayland 协议通信
- **临时性质**：重启 labwc 后会恢复到配置文件中的状态

---

## kanshi — 多场景自动切换

kanshi 可以根据当前连接的显示器自动应用预设配置，非常适合笔记本电脑用户。

### 配置文件位置

```
~/.config/kanshi/config
```

### 配置格式

```
# 场景A：只用笔记本内屏
profile laptop {
    output eDP-1 mode 1920x1080@60Hz scale 1 position 0,0
}

# 场景B：笔记本 + 外接4K显示器（扩展）
profile docked {
    output eDP-1 mode 1920x1080@60Hz scale 1 position 0,0
    output HDMI-A-1 mode 3840x2160@60Hz scale 2 position 1920,0
}

# 场景C：合盖只用外接显示器
profile external-only {
    output eDP-1 disable
    output HDMI-A-1 mode 3840x2160@60Hz scale 2 position 0,0
}
```

### 查看显示器名称

```bash
wlr-randr
```

输出中的第一列即为显示器名称（如 `eDP-1`、`HDMI-A-1`、`DP-1` 等）。

### 设置开机自启

在 `~/.config/labwc/autostart` 中添加：

```bash
kanshi &
```

### 使用方法

1. 用 `wdisplays` 拖拽出你想要的布局
2. 记下每个显示器的名称、分辨率、缩放、位置
3. 写入 `~/.config/kanshi/config`
4. 之后插拔显示器，kanshi 会自动匹配并应用配置

---

## 工作流建议

```
初次排版
   │
   ▼
wdisplays 拖拽调整 ──→ 满意后记下参数
                           │
                           ▼
                    写入 kanshi config
                           │
                           ▼
                    autostart 加入 kanshi &
                           │
                           ▼
                    以后插拔显示器全自动切换
```

## 常见问题

### wdisplays 打开后没有显示任何显示器？

确认 labwc 正在运行，并且使用的是 Wayland 会话（不是 X11）。

### kanshi 的配置文件语法？

kanshi 使用 scfg 格式（不是 JSON 也不是 INI）。旧版本曾使用 JSON 格式，1.0+ 版本已改为 scfg。

### 怎么临时禁用某个显示器？

```bash
# 禁用
wlr-randr --output HDMI-A-1 off

# 重新启用
wlr-randr --output HDMI-A-1 on
```

## 参考

- [wdisplays - GitHub](https://github.com/cyclopsian/wdisplays)
- [kanshi - GitHub](https://github.com/emersion/kanshi)
- [wlr-randr - GitHub](https://github.com/emersion/wlr-randr)
