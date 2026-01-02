# Sway Configuration: Zellij-inspired Modal Workflow

This Sway configuration is designed with a **modal workflow** philosophy, heavily inspired by the [Zellij](https://zellij.dev/) terminal multiplexer. The goal is to minimize complex modifier combinations and provide a structured, discoverable, and keyboard-centric experience.

## 核心设计理念 / Design Philosophy

- **模式化操作 (Modal Design)**: 减少对长按组合键的依赖。进入特定模式后，可以使用单键执行复杂操作。
- **直觉导航 (Intuitive Navigation)**: 统一使用 `h`, `j`, `k`, `l` (Vim-style) 或方向键进行导航和管理。
- **单键掌控 (One-key Control)**: 在特定模式下，最常用的功能（如关闭窗口、切换全屏）触手可及。

---

## 常用全局快捷键 / Global Shortcuts

| 快捷键 | 功能 |
| :--- | :--- |
| `Win + Return` | 启动终端 (Kitty) |
| `Win + d` | 启动应用启动器 (Wofi) |
| `Win + w` | **窗口切换器 (带图标)** - 跨工作区显示所有窗口 |
| `Win + q` | 关闭当前窗口 |
| `Win + f` | 切换全屏 |
| `Win + h/j/k/l` | 切换焦点 (左/下/上/右) |
| `Win + Tab` | 切换到上一个/下一个工作区 |
| `Alt + Tab` | 在当前工作区的窗口间循环 |

---

## 操作模式 / Operation Modes

按 `Win + Key` 进入对应模式，按 `Esc` 或 `Enter` 返回默认模式。

### 1. 移动模式 / Move Mode (`Win + m`)
用于在工作区内移动当前窗口。
- `h`, `j`, `k`, `l` 或 `方向键`: 向对应方向移动窗口。

### 2. 调整大小模式 / Resize Mode (`Win + r`)
- `h`, `j`, `k`, `l`: 调整窗口尺寸（普通）。
- `Shift + h/j/k/l`: 大幅度调整尺寸。

### 3. 面板模式 / Panel Mode (`Win + p`)
类似于 Zellij 的 Pane 模式，专注于当前窗口和焦点的快速管理。
- `a`: 切换到下一个焦点 | `s`: 切换到上一个焦点
- `x`: 关闭窗口 (Kill)
- `f`: 切换全屏
- `Shift + f`: 切换浮动状态

### 4. 标签模式 / Tab Mode (`Win + t`)
管理 Tabbed/Stacked 布局。
- `h`, `l`: 在 Tab 间切换。
- `n`: 在当前 Tab 容器中新建终端。
- `x`: 关闭当前 Tab。
- `b`: (Break out) 将当前窗口移出 Tab 容器。
- `Tab`: 循环切换 Tabbed / Stacked / Split 布局。

### 5. 工作区模式 / Workspace Mode (`Win + a`)
最强大的模式，灵感来自 Zellij 的 Workspace 管理。支持数字和字母行双映射。

**切换工作区 (Jump):**
- `1` - `0`: 跳转到工作区 1 - 0。
- `q` - `p`: 对应键盘第一行，跳转到工作区 1 - 0。

**移动并跳转 (Move & Jump):**
- `Shift + (1-0)` 或 `Shift + (q-p)`: 将当前窗口移至目标工作区并跟随跳转。

**快速切换 (Cycle):**
- `n`: 上一个工作区 | `m`: 下一个工作区。
- `Shift + n/m`: 移动窗口到上一个/下一个工作区。

**其他:**
- `a`: 将窗口移至下一个工作区并跳转。
- `Shift + a`: 将窗口移至下一个工作区但不跳转。
- `x`, `f`: 模式内也支持关闭和全屏操作。

---

## 维护与自定义 / Maintenance
- 配置文件路径: `~/.config/sway/config`
- 窗口切换脚本: `~/.config/sway/scripts/window_switcher.sh` (Python)
