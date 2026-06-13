# labwc keyboard profiles

## Menu and shortcuts

Open the desktop context menu:

```text
Settings -> Keyboard
```

Profiles:

- `Mac JIS - Command shortcuts`
- `PC Japanese`
- `PC English (US)`

Keyboard shortcuts:

- `Alt+K`: open the Keyboard menu
- `Alt+Shift+K`: cycle to the next profile

With the Mac JIS profile, Command and Option are swapped at the XKB level.
Therefore the physical shortcuts are:

- `Command+K`: open the Keyboard menu
- `Command+Shift+K`: cycle to the next profile
- Existing labwc `Alt+...` bindings are pressed with physical Command.

Control remains Control in every profile.

## Profile definitions

### Mac JIS

```text
XKB_DEFAULT_LAYOUT=jp
XKB_DEFAULT_MODEL=applealu_jis
XKB_DEFAULT_OPTIONS=altwin:swap_alt_win,apple:jp_pc106
```

This profile uses the Japanese Apple keyboard model. It swaps physical
Command/Super with Option/Alt so that Command operates the existing labwc
`Alt` shortcuts. The Apple Japanese compatibility option fixes the PC106-style
backslash key behavior.

### PC Japanese

```text
XKB_DEFAULT_LAYOUT=jp
XKB_DEFAULT_MODEL=pc105
XKB_DEFAULT_OPTIONS=
```

Use this for a normal Japanese PC keyboard. Alt, Super, and Control keep their
standard Linux meanings.

### PC English (US)

```text
XKB_DEFAULT_LAYOUT=us
XKB_DEFAULT_MODEL=pc105
XKB_DEFAULT_OPTIONS=
```

Use this for a normal ANSI US keyboard.

## Implementation

Relevant files:

- `~/.config/labwc/scripts/keyboard-profile`
- `~/.config/labwc/scripts/keyboard-menu`
- `~/.config/labwc/environment.d/90-keyboard.env`
- `~/.config/labwc/.keyboard-profile`
- `~/.config/labwc/menu.xml`
- `~/.config/labwc/rc.xml`

`keyboard-profile` writes the selected XKB settings to
`environment.d/90-keyboard.env`, records the active profile, and sends SIGHUP
to labwc. Labwc 0.9.6 reloads environment files and rebuilds the keyboard
layout during reconfigure, so logout is not required.

The separate environment file intentionally overrides the older
`XKB_DEFAULT_LAYOUT` value in `~/.config/labwc/environment`.

## Manual commands

Show the current profile:

```sh
~/.config/labwc/scripts/keyboard-profile status
```

Select profiles:

```sh
~/.config/labwc/scripts/keyboard-profile mac-jis
~/.config/labwc/scripts/keyboard-profile pc-jp
~/.config/labwc/scripts/keyboard-profile pc-us
```

Cycle profiles:

```sh
~/.config/labwc/scripts/keyboard-profile next
```

Inspect the generated menu:

```sh
~/.config/labwc/scripts/keyboard-menu
```

## Recovery

If modifier behavior is confusing, switch to the standard PC Japanese profile
from a terminal:

```sh
~/.config/labwc/scripts/keyboard-profile pc-jp
```

If the script cannot be used, replace
`~/.config/labwc/environment.d/90-keyboard.env` with:

```text
XKB_DEFAULT_LAYOUT=jp
XKB_DEFAULT_MODEL=pc105
XKB_DEFAULT_OPTIONS=
```

Then reload labwc:

```sh
kill -HUP "$(pgrep -n -x labwc)"
```

## Adding another keyboard

Add a new case to `keyboard-profile` with its layout, model, and options. Add
the profile to `keyboard-menu` and to the `next` cycle. Available values are
listed in:

```text
/usr/share/X11/xkb/rules/evdev.lst
```

Always keep one standard PC profile without modifier remapping as a recovery
option.
