# Labwc 快捷键配置说明

## 重要：不要直接编辑 rc.xml

`~/.config/labwc/rc.xml` 是由脚本自动生成的，直接修改会在下次生成时被覆盖。

## 目录结构

```
~/.config/labwc/
├── rc.xml                          ← 自动生成，勿手动编辑
├── keybinds/
│   ├── README.md                   ← 本文档
│   ├── mac-jis.xml                 ← Mac JIS 键盘布局的快捷键
│   ├── linux.xml                   ← 标准 Linux PC 键盘布局
│   ├── wsl.xml                     ← WSL 环境的快捷键
│   └── ...
├── .keybind-profile                ← 当前使用的键盘布局名称
├── .keyboard-profile               ← 键盘硬件类型（mac-jis / linux）
└── scripts/
    └── keybind-profile             ← 生成 rc.xml 的脚本
```

## 如何修改快捷键

### 步骤 1：编辑对应的 keybind 文件

根据你当前使用的键盘布局，编辑对应的 xml 文件：

```bash
# 查看当前使用的布局
cat ~/.config/labwc/.keybind-profile

# 编辑对应的文件（例如 mac-jis）
nvim ~/.config/labwc/keybinds/mac-jis.xml
```

### 步骤 2：重新生成 rc.xml

```bash
~/.config/labwc/scripts/keybind-profile
```

### 步骤 3：让 labwc-dev 重新加载配置

```bash
/usr/local/bin/labwc-dev -r
```

**注意：必须用 `labwc-dev -r`，不要用 `kill -HUP`，labwc-dev 版本不支持 HUP 信号重载。**

### 一行搞定

```bash
~/.config/labwc/scripts/keybind-profile && /usr/local/bin/labwc-dev -r
```

## 键位命名规则

| 符号 | 含义 |
|------|------|
| `W-` | Windows/Super 键（Mac 键盘上是 Command） |
| `A-` | Alt 键（Mac 键盘上是 Option） |
| `C-` | Ctrl 键 |
| `S-` | Shift 键 |
| `Return` | 回车键 |
| `Space` | 空格键 |
| `Tab` | Tab 键 |
| `F1`~`F12` | 功能键 |

组合键用 `-` 连接，例如：
- `W-a` = Super+A（Mac 上是 Cmd+A）
- `A-S-k` = Alt+Shift+K
- `C-Tab` = Ctrl+Tab

## 常用快捷键示例

### 执行命令

```xml
<keybind key="W-a">
  <action name="Execute" command="your-command" />
</keybind>
```

### 通过 shell 执行（需要设置环境变量时）

```xml
<keybind key="W-a">
  <action name="Execute" command="sh -c 'PATH=$HOME/.local/bin:$PATH your-command'" />
</keybind>
```

### 模拟按键（用 wtype）

```xml
<!-- 模拟 Ctrl+A（全选） -->
<keybind key="W-a">
  <action name="Execute" command="wtype -M Ctrl a -m Ctrl" />
</keybind>
```

### 窗口管理

```xml
<keybind key="W-q">
  <action name="Close" />
</keybind>
<keybind key="W-f">
  <action name="ToggleFullscreen" />
</keybind>
<keybind key="W-m">
  <action name="ToggleMaximize" />
</keybind>
<keybind key="W-Tab">
  <action name="NextWindow" />
</keybind>
```

### 工作区切换

```xml
<keybind key="A-Left">
  <action name="GoToDesktop" to="left" wrap="yes" />
</keybind>
<keybind key="A-1">
  <action name="GoToDesktop" to="1" />
</keybind>
```

### 弹出菜单

```xml
<keybind key="A-space">
  <action name="ShowMenu" menu="root-menu" />
</keybind>
```

### 工作区总览

```xml
<keybind key="W-Space">
  <action name="ToggleWorkspaceOverview" />
</keybind>
```

注意：`ToggleWorkspaceOverview` 是 labwc 的内置动作，无法通过命令行直接调用。Waybar 的 `custom/workspace` 模块通过 `wtype -M logo -P space -m logo` 模拟 Win+Space 按键来触发此动作。

## Apple 键盘 Fn 键行为（Asahi Linux）

Mac 键盘的 F1～F12 默认是媒体/功能键（亮度、音量等），需要按 Fn 才能触发标准 F 键。

如果你希望 F1～F12 直接作为标准功能键使用（配合 labwc 快捷键），需要修改 `hid_apple` 内核模块参数。

### 查看当前状态

```bash
cat /sys/module/hid_apple/parameters/fnmode
```

| 值 | 行为 |
| - | - |
| 0 | F1～F12 直接是标准功能键 |
| 1 | 默认苹果行为（亮度、音量等） |
| 2 | Fn 键反转 |
| 3 | 新版内核默认，类似 1 但更激进 |

### 临时修改（重启后失效）

```bash
echo 0 | sudo tee /sys/module/hid_apple/parameters/fnmode
```

### 永久修改

```bash
echo "options hid_apple fnmode=0" | sudo tee /etc/modprobe.d/hid_apple.conf
sudo dracut --force
```

重启生效。

### 如果找不到 hid_apple 模块

```bash
lsmod | grep apple
```

如果没有输出，说明你的系统可能使用了新版 Asahi 键盘驱动，需要根据具体发行版和机型另外处理。

---

## 踩坑记录

### 1. 改了 rc.xml 但没生效

**原因**：rc.xml 是自动生成的，你改的是临时文件。
**解决**：改 keybinds/ 下的 xml 文件，然后运行 keybind-profile 脚本。

### 2. 改了文件也跑了脚本但快捷键还是旧的

**原因**：labwc-dev 没有重新加载配置。
**解决**：运行 `/usr/local/bin/labwc-dev -r`，不要用 `kill -HUP`。

### 3. 快捷键在终端能用但快捷键触发不了

**原因 1**：PATH 问题。labwc 的 Execute 用最小化 shell，不加载 ~/.bashrc。
**解决**：用 `sh -c 'PATH=$HOME/.local/bin:$PATH your-command'`。

**原因 2**：嵌套运行 labwc。如果 labwc 嵌套在其他合成器里，外层会截获键盘。
**解决**：确保 labwc 是主合成器（直接通过 GDM 登录）。

**原因 3**：按键被其他程序拦截（如 fcitx5、GNOME 快捷键）。
**解决**：检查其他程序的快捷键配置。

### 4. 想加新的快捷键

1. 在 `keybinds/你的布局.xml` 里加 keybind 条目
2. 运行 `~/.config/labwc/scripts/keybind-profile`
3. 运行 `/usr/local/bin/labwc-dev -r`
4. 测试

### 5. 切换键盘布局

```bash
# 切换到 linux 布局
~/.config/labwc/scripts/keybind-profile linux

# 切换到 mac-jis 布局
~/.config/labwc/scripts/keybind-profile mac-jis

# 自动检测（根据 .keyboard-profile 文件）
~/.config/labwc/scripts/keybind-profile
```

## Kazamo（语音输入法）快捷键

Kazamo 的快捷键配置在 `mac-jis.xml` 的底部：

```xml
<!-- Kazamo (语音输入法) - 请在此文件修改，勿直接改 rc.xml -->
<keybind key="W-a">
  <action name="Execute" command="sh -c 'PATH=$HOME/.local/bin:$PATH kazamo toggle'" />
</keybind>
```

修改后记得运行：
```bash
~/.config/labwc/scripts/keybind-profile && /usr/local/bin/labwc-dev -r
```
