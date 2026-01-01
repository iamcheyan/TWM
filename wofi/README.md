# Wofi 配置说明

这个目录包含了从 [elifouts/Dotfiles](https://github.com/elifouts/Dotfiles) 下载的 wofi 配置文件。

## 📁 文件说明

### 主配置
- **config** - 默认配置（单列布局，500px 宽）
- **style.css** - 默认样式

### 可选配置
- **config-wallpaper** - 壁纸选择器布局（4列网格，800px 宽）
- **style-wallpaper.css** - 壁纸选择器样式

- **config-waybar** - Waybar 风格布局（单列，1200px 宽，大图标）
- **style-waybar.css** - Waybar 风格样式

## 🎨 如何切换样式

### 方法 1: 修改配置文件名
```bash
cd ~/.config/wofi
mv config config.bak
mv config-wallpaper config  # 使用壁纸布局
```

### 方法 2: 在命令行指定
```bash
wofi --conf ~/.config/wofi/config-wallpaper --style ~/.config/wofi/style-wallpaper.css
```

### 方法 3: 修改 Niri 快捷键
在 `~/.config/niri/config.kdl` 中修改：
```kdl
Mod+D { spawn "wofi" "--conf" "~/.config/wofi/config-waybar" "--style" "~/.config/wofi/style-waybar.css"; }
```

## 📐 配置对比

| 配置 | 宽度 | 高度 | 列数 | 图标大小 | 用途 |
|------|------|------|------|----------|------|
| config | 500px | 400px | 1 | 默认 | 应用启动器 |
| config-wallpaper | 800px | 600px | 4 | 150px | 壁纸/图片选择 |
| config-waybar | 1200px | 600px | 1 | 1050px | 大图标显示 |

## 🎨 颜色主题

所有样式文件都使用 Catppuccin 配色方案：
- **mauve** (#cba6f7) - 选中项颜色
- **red** (#f38ba8) - 强调色
- **lavender** (#b4befe) - 箭头颜色
- **text** (#cdd6f4) - 文字颜色
- **background** (#1e1e2e) - 背景色

## 💡 提示

- 默认配置已经通过软链接设置好了
- CSS lint 警告可以忽略（GTK CSS 特殊语法）
- 所有配置都使用 MesloLGS Nerd Font 字体
