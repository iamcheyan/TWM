# Sway Configuration: Zellij-inspired Modal Workflow

本文档详细介绍了当前 Sway 的快捷键配置。本配置采用了类似 **Zellij** 的“模式化操作”理念，旨在通过减少复杂的组合键来提高效率。

## 1. 全局快捷键 (常用)

这些快捷键在任何时候都可以直接触发：

| 快捷键 | 功能 |
| :--- | :--- |
| `Win + Return` | 启动终端 (Kitty) |
| `Win + d` | 启动应用启动器 (Wofi) |
| `Win + x` | **关闭当前窗口** |
| `Win + f` | 切换 浮动 / 平铺 状态 |
| `Win + g` | 切换 标签 (Tabbed) / 平铺 布局 |
| `Win + s` | **搜索窗口** (使用 Wofi 搜索并跳转到指定窗口) |
| `Win + v` | 剪贴板历史 (Cliphist + Wofi) |
| `Alt + Tab` | 当前工作区内：切换下一个窗口焦点 |
| `Alt + Shift + Tab` | 当前工作区内：切换上一个窗口焦点 |
| `Win + Tab` | 切换到下一个工作区 |
| `Win + Shift + Tab` | 切换到上一个工作区 |
| `Win + Shift + c` | 重新加载 Sway 配置 |

---

## 2. 核心：移动窗口 (How to Move Windows)

移动窗口在本项目中有多种方式，取决于你是想在“工作区内”移动，还是“跨工作区”移动。

### A. 工作区内移动 (Move Mode)
按下 **`Win + h`** 进入 **MOVE** 模式：
- `h`, `j`, `k`, `l` 或 `方向键`: 向左、下、上、右移动当前窗口。
- `Enter` 或 `Esc`: 退出模式。

### B. 跨工作区移动 (Workspace Mode)
按下 **`Win + z`** 进入 **WORKSPACE** 模式：
- **移动并跳转**: `Shift + q/w/e/r/t/y/u/i/o/p` 将窗口移至对应工作区并**跟随**过去。
- **快速拨动**: `h` 或 `l` 键将窗口快速移动到上一个/下一个编号的工作区。

### C. 跨显示器移动 (Output Mode)
按下 **`Win + Shift + m`** 进入 **OUTPUT** 模式：
- `h`, `j`, `k`, `l`: 将当前窗口移动到左、下、上、右侧的显示器。

---

## 3. 操作模式详解

进入模式后，顶部状态栏（通常）会显示当前模式提示，按 `Esc` 或 `Enter` 返回默认。

### 调整大小模式 / Resize Mode (`Win + n`)
- `h`, `j`, `k`, `l`: 基础调整（20px）。
- `+` / `-` 或 `=` / `_`: **大幅度**调整尺寸（50px）。

### 面板模式 / Panel Mode (`Win + a`)
类似于 Zellij 的 Pane 管理，侧重于当前布局控制：
- `h`, `j`, `k`, `l`: 切换窗口焦点。
- `Shift + h` / `Shift + l`: 切换工作区。
- `x`: 关闭窗口 | `f`: 切换浮动 | `Shift + f`: 切换全屏。
- `t`: 切换标签布局 | `s`: 切换平铺布局。
- `n`: **新建工作区** (自动寻找下一个可用的空编号)。

### 工作区模式 / Workspace Mode (`Win + z`)
- `q, w, e, r, t, y, u, i, o, p`: 分别对应工作区 1 - 10 的快速跳转。
- `n` / `m`: 跳转到上一个/下一个工作区。

---

## 4. 系统与截图

### 截图 (Screenshot)
- `Print`: 全屏截图并存入剪贴板。
- `Alt + Print`: 全屏截图并保存到 `~/Downloads`。
- `Shift + Print`: **区域截图**并保存到 `~/Downloads`。
- `Alt + a`: **区域截图**并存入剪贴板。

### 电源管理
- `Ctrl + Alt + BackSpace`: 弹出电源菜单（关机、重启、挂起、退出 Sway）。
- `Win + Ctrl + Alt + Shift + q`: 直接退出 Sway 确认确认。

---

## 5. 维护信息
- 配置文件: `~/.config/sway/config`
- 自定义脚本:
    - `~/.config/sway/scripts/move_ws.sh`: 处理跨工作区移动的逻辑。
