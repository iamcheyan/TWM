https://github.com/kek/swayr#swayr-installation


cargo install swayr

你这个 `swayr --help` 已经把 swayr 的核心能力全列出来了。

可以归类理解，不然会感觉命令太多。

***

# 一、窗口切换（最核心）

这是 swayr 的主要用途。

## 1. Alt-Tab 风格

```bash
next-window
prev-window
```

用途：

* 最近使用窗口循环
* 类似：
  * Windows Alt-Tab
  * macOS Cmd-Tab

你刚刚配置的就是这个。

***

## 2. 智能切换

```bash
switch-to-urgent-or-lru-window
```

功能：

优先级：

1. urgent window
2. 最近使用窗口（LRU）

非常适合：

```ini
Alt+Tab
```

***

## 3. 按应用切换

```bash
switch-to-app-or-urgent-or-lru-window firefox
```

效果：

* 直接跳到 Firefox
* 如果已经在 Firefox：
  再切下一个最近窗口

非常像：

```text
Alfred / Raycast app switch
```

***

## 4. 按 mark 切换

```bash
switch-to-mark-or-urgent-or-lru-window
```

配合 sway marks。

***

## 5. 按 criteria 切换

```bash
switch-to-matching-or-urgent-or-lru-window
```

支持 sway criteria：

```bash
[class="Firefox"]
```

高级用户很爱。

***

# 二、菜单式切换器（launcher 风格）

这是 swayr 第二大功能。 [\[github.com\]](https://github.com/kek/swayr)

***

## 1. 窗口选择器

```bash
switch-window
```

功能：

* 显示所有窗口
* 模糊搜索
* 选择后 focus

类似：

```text
rofi window mode
```

***

## 2. workspace 选择器

```bash
switch-workspace
```

***

## 3. output 选择器

```bash
switch-output
```

多显示器切换。

***

## 4. 全局选择器

```bash
switch-to
```

超级入口。

能选择：

* output
* workspace
* container
* window

像：

```text
sway 全局导航器
```

***

# 三、“偷窗口”功能（超强）

这个是 swayr 很独特的功能。 [\[github.com\]](https://github.com/kek/swayr)

***

## 1. steal-window

```bash
steal-window
```

作用：

> 把别的 workspace 的窗口拉到当前 workspace

***

## 2. steal-window-or-container

```bash
steal-window-or-container
```

连 container 都能偷。

***

# 四、窗口序列导航

这是刚才 help 里最容易忽略但很强的。

***

## tiled container

```bash
next-tiled-window
prev-tiled-window
```

只在 tiled 窗口间循环。

***

## tabbed / stacked

```bash
next-tabbed-or-stacked-window
prev-tabbed-or-stacked-window
```

用于：

```text
layout tabbed
layout stacked
```

***

## floating

```bash
next-floating-window
prev-floating-window
```

只切 floating。

***

## 同 layout

```bash
next-window-of-same-layout
```

非常高级。

***

# 五、workspace 操作

***

## move-focused-to-workspace

```bash
move-focused-to-workspace
```

把当前窗口移动到 workspace。

带菜单。

***

## move-focused-to

```bash
move-focused-to
```

还能移动到：

* output
* container
* workspace

***

# 六、交换窗口

***

## swap-focused-with

```bash
swap-focused-with
```

功能：

```text
当前窗口 ↔ 另一个窗口
```

超级适合 tiling 用户。

***

# 七、自动布局（很强）

这个很像：

```text
tmux layout
```

***

## 1. tile-workspace

```bash
tile-workspace
```

自动平铺。

***

## 2. tab-workspace

```bash
tab-workspace
```

全部 tab 化。

***

## 3. shuffle-tile-workspace

```bash
shuffle-tile-workspace
```

重新排列后平铺。

***

## 4. toggle-tab-shuffle-tile-workspace

```bash
toggle-tab-shuffle-tile-workspace
```

布局切换。

***

# 八、关闭窗口

***

## quit-window

```bash
quit-window
```

菜单选窗口关闭。

***

## quit-workspace-or-window

```bash
quit-workspace-or-window
```

甚至能：

> 关闭整个 workspace 所有窗口

***

# 九、命令 launcher

***

## execute-swaymsg-command

```bash
execute-swaymsg-command
```

菜单式执行 swaymsg。

***

## execute-swayr-command

```bash
execute-swayr-command
```

菜单选择 swayr command。

***

# 十、输出配置

***

## configure-outputs

```bash
configure-outputs
```

多显示器配置。

***

# 十一、JSON / 脚本功能

高级用户用。 [\[github.com\]](https://github.com/kek/swayr)

***

## get-windows-as-json

```bash
get-windows-as-json
```

输出窗口 JSON。

适合：

* polybar
* waybar
* shell scripts

***

## for-each-window

```bash
for-each-window
```

批量操作窗口。

***

# 十二、配置相关

***

## print-config

```bash
print-config
```

查看当前配置。

***

## print-default-config

```bash
print-default-config
```

看默认配置。

***

## reload-config

```bash
reload-config
```

重载：

```bash
~/.config/swayr/config.toml
```

***

# 十三、你最该用的功能

我建议你先重点使用：

```ini
# Alt-Tab
bindsym Ctrl+Tab exec swayr next-window
bindsym Ctrl+Shift+Tab exec swayr prev-window

# 窗口搜索
bindsym $mod+d exec swayr switch-window

# workspace 搜索
bindsym $mod+w exec swayr switch-workspace

# 偷窗口
bindsym $mod+Shift+s exec swayr steal-window
```

这几个已经是：

```text
sway/i3 超级生产力套装
```

