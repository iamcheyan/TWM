# Hyprland Quickshell Window Switcher

This document records the current `Win+Tab` window switcher implementation.

## Goal

The desired behavior (now implemented):

- Hold `Super+Tab` → switcher appears (selects the "next" window like classic Alt-Tab).
- While holding, press `Tab` (Shift+Tab for reverse) to cycle the selection/focus live.
- Release `Super` (or press Escape) → overlay hides immediately, focus stays on the chosen window.

The implementation avoids per-key spawns and timer races. Only Super+Tab / Super+Shift+Tab are used.

## Files

- `hyprland/hyprland.conf`
  Defines the global shortcuts for activation.
- `hyprland/scripts/window-switcher`
  Thin wrapper, mainly used for the Escape fallback + native fallback.
- `qs/shell.qml`
  Contains almost all the logic: GlobalShortcut registrations, data fetching, state, keyboard handling, and the overlay UI.

## Hyprland Keybind Flow (updated)

The implementation now uses Hyprland `global` shortcuts for low-latency delivery
directly to Quickshell (no process spawn per key), plus exclusive keyboard grab
inside the overlay for handling repeats and release detection.

```ini
bind = $mod, Tab, global, twm:switcher-next
bind = $mod SHIFT, Tab, global, twm:switcher-prev

# Fallback commit when Super is released
bindr = $mod, Super_L, global, twm:switcher-commit
bindr = $mod, Super_R, global, twm:switcher-commit

# Escape fallback (local handler wins when the overlay has grabbed the keyboard)
bind = , Escape, exec, ~/.config/hypr/scripts/window-switcher hide
```

While the switcher overlay is visible it sets `WlrKeyboardFocus.Exclusive` and
an internal `Keys` handler consumes:
- `Tab` (forward), `Shift+Tab` (backward)
- `Escape` (cancel, restores original focus if possible)
- Release of Super_L / Super_R (commit / hide)

This gives the classic hold-to-show, cycle-while-held, release-to-apply behavior.

## Script Behavior

The script is now used mainly for the Escape fallback path (and debugging).

It accepts `next | prev | show | hide` and does `quickshell ipc ... call window-switcher <action>`.

Fallback native cycling is still present in the script for when IPC is unavailable.
Hide path still does `submap reset` (harmless when no submap is active).

## Quickshell Behavior

`qs/shell.qml` now implements the switcher with in-process key handling:

- Uses `GlobalShortcut` (Quickshell.Hyprland) to receive `twm:switcher-*` events with very low latency.
- On activation: fetches `hyprctl clients -j` (once), sorts by focusHistoryID, shows the PanelWindow.
- Sets `WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive` + internal focusable Item with `Keys.onPressed/onReleased`.
- Cycles update the index + live `focuswindow` preview.
- On Super release (via Keys or global commit) or Escape: immediately hide and (for cancel) restore original focus if tracked.
- No more per-cycle timers or auto-hide after 180ms.

The overlay:

```qml
WlrLayershell.layer: WlrLayer.Overlay
WlrLayershell.keyboardFocus: root.windowSwitcherGrabbed ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
```

This is the robust approach suggested in the previous "Current Limitation" section.

## Core Implementation Pattern (Recommended for similar HUDs)

The window switcher is a good reference for building other "hold or toggle + keyboard driven overlay" features (e.g. workspace overview).

### 1. Activation (low latency)
- Hyprland side uses `global` keyword:
  ```ini
  bind = $mod, Tab, global, twm:switcher-next
  bind = $mod SHIFT, Tab, global, twm:switcher-prev
  ```
- Quickshell side registers matching `GlobalShortcut` (from `Quickshell.Hyprland`):
  ```qml
  import Quickshell.Hyprland

  GlobalShortcut {
      appid: "twm"
      name: "switcher-next"
      onPressed: root.activateSwitcher(1)
  }
  ```
- This delivers the event directly into the already-running QML process — no shell script spawn.

Fallback path (Escape, manual calls) still goes through the small `window-switcher` script + `quickshell ipc call ...`.

### 2. Taking control of input
When we decide to show the overlay:

```qml
windowSwitcherVisible = true
windowSwitcherGrabbed = true
```

The `PanelWindow` reacts:

```qml
WlrLayershell.keyboardFocus: root.windowSwitcherGrabbed
    ? WlrKeyboardFocus.Exclusive
    : WlrKeyboardFocus.None
```

Inside the PanelWindow we place a focusable item:

```qml
Item {
    focus: root.windowSwitcherGrabbed
    Keys.onPressed: (ev) => root.handleSwitcherKeyPressed(ev)
    Keys.onReleased: (ev) => root.handleSwitcherKeyReleased(ev)

    Connections {
        target: root
        function onRequestFocus() { forceActiveFocus() }
    }
}
```

This lets us receive Tab, Shift+Tab, Escape, and modifier release events locally with zero latency.

### 3. State & data flow (in shell.qml)
Relevant root properties:
- `windowSwitcherVisible`
- `windowSwitcherGrabbed`
- `windowSwitcherWindows` (array)
- `windowSwitcherIndex`
- `windowSwitcherOriginalAddress` (for cancel)

Key functions:
- `activateSwitcher(dir)` — if already visible → `cycleWindow`, else kick off `hyprctl clients -j`
- `consumeWindowClients()` (called from `Process` stdout) — parse, filter hidden, sort by `focusHistoryID`, pick target index, set visible + grabbed, live `focuswindow`
- `cycleWindow(dir)` + `applyFocusToCurrent()` — update index + `hyprctl dispatch focuswindow`
- `commitSwitcher()` / `cancelSwitcher()` / `hideSwitcherNow()`
- `handleSwitcherKeyPressed` / `Released` — only Tab (+Shift) for cycle, Escape, Super release

Data collection happens **only once** on activation. All subsequent cycling is pure in-memory + one `focuswindow`.

### 4. Reliable hide on release
- Primary: `Keys.onReleased` for `Super_L` / `Super_R` / `Meta`
- Fallback: `bindr = $mod, Super_L, global, twm:switcher-commit`
- The grabbed surface usually delivers the release key event reliably when the user is holding the modifier.

No 180ms timers anymore. Hide is explicit and instant.

### 5. Styling & UI
The same `PanelWindow` + `Rectangle` card + `ListView` (horizontal) pattern is used.
Selection is driven by `currentIndex` on the ListView.

### Why this pattern wins over the old submap + script approach
- Zero process spawn cost during rapid cycling
- No timer races
- Proper "I own the keyboard now" semantics
- Easy to extend (add more keys, different navigation, etc.)

The same skeleton (GlobalShortcut → show + grab → Keys handlers → explicit hide on release/escape) is highly reusable.

See the dedicated design document:
- `hyprland/docs/workspace-overview.md` — detailed UX + technical plan for workspace previews, real window screenshots, and drag-and-drop window management.

## Hide Timing

Hiding is now explicit and immediate:

- Modifier release (detected via `Keys.onReleased` on the exclusive grab, or the `bindr` global).
- Escape key (handled locally when grabbed).
- Safety 60s timer (only as last resort).

No more fighting timers on every Tab press. Release should feel instant.

## Implementation Notes

See the "Core Implementation Pattern" section above for the full recommended approach.

The key wins:
- One data fetch on activation
- All interaction handled inside the grabbed QML surface
- Explicit commit on modifier release
- Works reliably with the current Hyprland + Quickshell (0.2.x) stack

## Reloading

After editing `hyprland/hyprland.conf`:

```sh
hyprctl reload
```

After editing `qs/shell.qml`:

```sh
pkill -f 'quickshell.*hyprland'
~/.config/hypr/scripts/quickshell &
```
