# Hot Corner (热角) 配置说明

鼠标移到屏幕四个角落时，延迟触发指定动作。类似 GNOME 的 Hot Corner。

## 当前配置

| 角落 | 触发区域 | 延迟 | 动作 | 说明 |
|------|---------|------|------|------|
| 左上 (topLeft) | 2×2px | 300ms | ToggleWorkspaceOverview | 打开/关闭工作区总览 |
| 右上 (topRight) | 2×2px | 300ms | ToggleShowDesktop | 显示/隐藏桌面 |
| 左下 (bottomLeft) | 2×2px | 300ms | Execute cliphist-fuzzel | 弹出剪贴板历史 |
| 右下 (bottomRight) | 2×2px | 300ms | ShowMenu root-menu | 弹出系统右键菜单 |

## 配置格式 (rc.xml)

```xml
<hotCorner>
  <enabled>yes</enabled>        <!-- 总开关 -->
  <delay>300</delay>            <!-- 触发延迟 (毫秒) -->

  <topLeft>
    <action name="..." />
  </topLeft>
  <topRight>
    <action name="..." />
  </topRight>
  <bottomLeft>
    <action name="..." />
  </bottomLeft>
  <bottomRight>
    <action name="..." />
  </bottomRight>
</hotCorner>
```

- 放在 `<labwc_config>` 内任意位置
- 每个角落独立配置，可单独启用/禁用
- 不配置的角落不会触发
- `<delay>` 为 0 表示立即触发

## 可用动作示例

```xml
<!-- 工作区总览 -->
<action name="ToggleWorkspaceOverview" />

<!-- 显示桌面 -->
<action name="ToggleShowDesktop" />

<!-- 执行命令 -->
<action name="Execute" command="~/.config/cliphist/cliphist-fuzzel" />

<!-- 弹出菜单 -->
<action name="ShowMenu" menu="root-menu" />

<!-- 切换工作区 -->
<action name="GoToDesktop" to="left" wrap="yes" />
```

## 行为规则

1. 光标进入角落 2×2px 区域后开始计时
2. 在延迟时间内光标离开角落 → 取消触发
3. 光标停留在角落超过延迟时间 → 触发动作
4. 每次进入角落只触发一次，离开后重置
5. 非 Passthrough 状态（拖拽、调整大小等）不会触发
