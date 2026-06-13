# labwc display scaling

## Overview

The desktop context menu uses a dynamic labwc pipe menu:

```text
Display -> Scale -> output -> scale value
```

Relevant files:

- `~/.config/labwc/menu.xml`
- `~/.config/labwc/scripts/scale-menu`
- `~/.config/labwc/scripts/scale`

`scale-menu` reads the live output list from `wlr-randr` and generates one
submenu of scale choices for every output. Each generated command contains
both the scale value and output name:

```text
~/.config/labwc/scripts/scale 1.5 HDMI-A-1
```

`scale` validates the output and value before applying:

```text
wlr-randr --output HDMI-A-1 --scale 1.5
```

## Important menu requirement

Keep the Scale entry in `menu.xml` as a pipe menu:

```xml
<menu id="scale-menu" label="Scale"
  execute="/home/tetsuya/.config/labwc/scripts/scale-menu" />
```

Do not replace it with static scale items that call only:

```text
scale 1.5
```

Without the output argument, the script falls back to the first output
reported by `wlr-randr`. That makes multi-monitor selection incorrect.

Also avoid `$HOME` in labwc `command` or `execute` attributes. These values are
not guaranteed to be expanded by a shell. Use an absolute path for the pipe
menu command. The generated scale commands also use an absolute path.

## Reload after editing

Reload labwc so it reads the updated menu:

```sh
kill -HUP "$(pgrep -n -x labwc)"
```

Opening the context menu again should execute `scale-menu` and show the live
output name, resolution, and current scale.

## Diagnostics

Check current outputs:

```sh
wlr-randr
```

Inspect the generated menu directly:

```sh
~/.config/labwc/scripts/scale-menu
```

Expected generated structure:

```xml
<menu id="scale-HDMI-A-1"
  label="HDMI-A-1  3840x2160  (current: 2.000000)">
  <item label="1.5">
    <action name="Execute"
      command="/home/tetsuya/.config/labwc/scripts/scale 1.5 HDMI-A-1" />
  </item>
</menu>
```

Test one output directly:

```sh
~/.config/labwc/scripts/scale 1.5 HDMI-A-1
wlr-randr
```

Failures and successful applications are recorded in:

```text
${XDG_RUNTIME_DIR}/labwc-scale.log
```

If `XDG_RUNTIME_DIR` is unavailable or unwritable, the fallback is:

```text
/tmp/labwc-scale-UID.log
```

## Regression checklist

1. `scale-menu` prints valid `<openbox_pipe_menu>` XML.
2. Every generated action includes a scale and an output name.
3. Selecting a value changes the intended output immediately.
4. `wlr-randr` reports the selected scale.
5. Reopen the menu and confirm its `current:` value is updated.
6. Test each connected output when more than one monitor is present.
