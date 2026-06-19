# Hyprland Quickshell Workspace Overview Design

This document captures the design, UX goals, and technical implementation plan for a custom Quickshell-based Workspace Overview.

## Goals

- Clicking the "Workspaces" button (or pressing `Super + Space`) opens a visual overview showing **all workspaces**.
- Each workspace displays **real screenshots/thumbnails** of the windows it contains (mini exposé style).
- **Drag and drop** support to move windows between workspaces directly in the UI.
- Excellent keyboard support (arrows, numbers, hjkl, Enter, Escape).
- Consistent look and feel with the rest of the TWM Quickshell shell (dark theme, cosmic icons, same card styling as the window switcher).
- No hard dependency on the `hyprexpo` plugin (optional fallback or complement).
- Fast to open/close, responsive navigation.
- Works well on multi-monitor setups.

### Nice-to-haves (v2+)
- Live-updating thumbnails while the overview is open.
- Filtering/search.
- Dragging to specific positions within a workspace.
- Visual "empty workspace" placeholders that still allow drops.

## Current State (as of 2026)

- `Super + Space` and the top bar "Workspaces" button call `hyprland/scripts/workspace-overview`.
- The script tries `hyprctl dispatch hyprexpo:expo toggle`.
- If the plugin is missing, it just shows a notification.
- The qs version of the script uses `wtype` to simulate a keypress (for labwc compatibility).
- No custom thumbnails or drag-and-drop today.

`hyprexpo` gives nice live thumbnails but:
- Requires extra plugin.
- Limited customization and keyboard integration.
- Style doesn't match our Quickshell UI.

## Proposed User Experience

### Trigger
- Top bar button click → toggle.
- `Super + Space` → toggle (preferred binding).
- Global shortcut registration for direct low-latency activation (same as window switcher).

### Visual Layout
- Full or near-full screen semi-transparent dimmed background.
- Centered or full-width grid of workspace cards.
- Example grid (responsive):
  ```
  [ 1          ]  [ 2          ]  [ 3          ]
     [thumb1]      [thumbA]
     [thumb2]

  [ 4 (empty)  ]  [ 5          ]
  ```
- Each card shows:
  - Large workspace number + name.
  - Monitor name or icon (if multi-monitor).
  - Inside the card: a mini layout of windows with actual scaled screenshots.
  - Current workspace has stronger highlight + border.
  - Focused window inside a workspace has an extra ring or label.

### Interactions

**Mouse**
- Click a workspace card → switch to that workspace and close overview.
- Click a window thumbnail → focus that specific window + switch workspace + close.
- **Drag** a window thumbnail → drop onto another workspace card (or empty area) to move the window.
- Hover effects and drop target highlighting.

**Keyboard** (while overlay has exclusive focus)
- `Arrow keys` / `hjkl`: Navigate between workspace cards (and between windows inside a card).
- `1`–`0`: Jump directly to workspace N.
- `Enter`: Activate the current selection (workspace or window).
- `Escape`: Close without changing anything.
- `Tab` / `Shift+Tab`: Move between cards or windows.
- While dragging with mouse, keyboard still works for other things or cancel with Esc.

**Close behavior**
- Click outside / background.
- Escape.
- Selecting a workspace/window.
- Explicit "close" action.

## Technical Architecture

We will follow the **exact same robust pattern** successfully used for the window switcher (see `hyprland/docs/window-switcher.md` → "Core Implementation Pattern").

### High-Level Components

1. **Activation layer**
   - `GlobalShortcut` (Quickshell.Hyprland) for `twm:workspace-overview-toggle`.
   - IPC handler for the bar button and script fallback: `quickshell ipc call workspace-overview toggle`.

2. **UI Container**
   - One or more `PanelWindow` (per screen or main screen) on `WlrLayer.Overlay`.
   - `WlrLayershell.keyboardFocus: Exclusive` when open.
   - Semi-transparent background + centered content card.

3. **State Management** (in `shell.qml` or a dedicated root object)
   - `workspaceOverviewVisible`
   - `workspaceOverviewGrabbed`
   - `workspacesModel`: array of grouped data.

4. **Dedicated Components** (recommended)
   - `qs/WorkspaceOverview.qml` — main container + logic.
   - `qs/WorkspaceCard.qml` — one workspace tile.
   - `qs/WindowThumbnail.qml` — the critical component that renders a live-ish screenshot + acts as drag source.

5. **Data Source**
   - On open (and on changes): `hyprctl workspaces -j` + `hyprctl clients -j`.
   - Group clients by workspace.
   - Correlate with `ToplevelManager.toplevels` for extra info.
   - Use `import Quickshell.Hyprland` for `Hyprland.workspaces` / `Hyprland.focusedWorkspace` where live reactivity is useful.

### Window Thumbnails (Screenshots)

This is the most important and technically interesting part.

**Recommended approach (Quickshell native):**

Quickshell has first-class screencopy support (including Hyprland-specific protocols):

```qml
import Quickshell.Wayland

// Inside WindowThumbnail.qml
Screencopy {
    id: screencopy
    // Source can be a Toplevel obtained via foreign toplevel management
    // or HyprlandToplevelExport when available
    source: targetToplevel
    live: overviewVisible          // or false for snapshot
    onFrame: (frame) => {
        // frame can be turned into an Image source or texture
        thumbnailImage.source = frame; // or custom image provider
    }
}
```

- Hyprland exposes `hyprland-toplevel-export-v1`, which Quickshell can use to capture **individual windows** without capturing the whole output.
- When the overview opens:
  1. Fetch clients.
  2. For each client, resolve the corresponding `Toplevel`.
  3. Create a small `Screencopy` request (e.g. 1/3 or 1/4 scale).
  4. Store the resulting image data keyed by window address.
- Display using `Image { source: thumbnailForAddress }` inside the card, arranged in a small grid or layout that mimics the actual window positions (approximate is fine).
- Capture **on demand** when overview opens. Cache while visible. Invalidate on close or when windows change significantly.

**Fallbacks (if screencopy per-window is hard initially):**
- Capture full output with `Screencopy` on the current output and crop using window geometry from `hyprctl`.
- Use `grim` + geometry for a v0.5 prototype (slow but works for testing).

Target thumbnail size: ~180–240 px wide, high enough quality to recognize content.

**Live vs Snapshot**
- v1: Snapshot when opening the overview (fast, predictable).
- v2: Set `live: true` on the Screencopy sources so thumbnails update while the overview is open.

### Drag and Drop

Quickshell / QtQuick has excellent built-in support.

**In WindowThumbnail.qml:**

```qml
Item {
    id: thumb

    Drag.active: dragHandler.active
    Drag.source: modelData.address
    Drag.mimeData: {
        "application/x-window-address": modelData.address,
        "text/plain": modelData.address
    }

    DragHandler {
        id: dragHandler
        // optional: visual feedback
    }

    // Optional: start drag on long press or modifier
    MouseArea {
        anchors.fill: parent
        onPressed: if (mouse.modifiers & Qt.ControlModifier) thumb.grabToImage(...)
    }
}
```

**In WorkspaceCard.qml:**

```qml
DropArea {
    anchors.fill: parent

    onEntered: highlight = true
    onExited: highlight = false

    onDropped: (drop) => {
        const address = drop.getDataAsString("application/x-window-address")
                       || drop.source;
        if (address) {
            root.moveWindowToWorkspace(address, workspaceId);
            drop.accept();
        }
    }
}
```

Implementation of move:

```sh
hyprctl dispatch movetoworkspace "name:${workspaceName}" address:${address}
# or by id
```

Visual feedback is important (scale the thumbnail while dragging, highlight target cards).

### Keyboard + Focus Handling

Exactly like the window switcher:

```qml
Item {
    focus: root.workspaceOverviewGrabbed
    Keys.onPressed: (event) => root.handleOverviewKeyPressed(event)
    ...
}
```

In `handleOverviewKeyPressed`:
- Arrow keys change current card / current window inside card.
- Numbers directly activate workspace.
- Enter activates selection.
- Escape closes.

We can keep a flat or hierarchical selection model (`currentWorkspaceIndex`, `currentWindowIndexInWs`).

### IPC & Activation

Add in `shell.qml`:

```qml
IpcHandler {
    target: "workspace-overview"

    function toggle() { root.toggleWorkspaceOverview(); }
    function show()   { root.showWorkspaceOverview(); }
    function hide()   { root.hideWorkspaceOverview(); }
}
```

Update `qs/scripts/workspace-overview` to:

```sh
quickshell ipc -p ... call workspace-overview toggle
```

Optionally register a global shortcut:

```ini
bind = $mod, Space, global, twm:workspace-overview-toggle
```

### Multi-Monitor

Options:
- Show the overview only on the currently focused monitor (simplest).
- Show a synchronized view on all monitors.
- Show workspaces belonging to each monitor grouped.

Start with "show on all monitors" (like the window switcher) or focused monitor only.

## Implementation Phases

### Phase 1 — Skeleton (fast feedback)
- Create `WorkspaceOverview.qml`
- Basic grid of cards using `hyprctl` data (no images yet, just titles + list of window names).
- Toggle via IPC + bar button.
- Exclusive focus + Escape to close.
- Click a card switches workspace.

### Phase 2 — Keyboard & Polish
- Full arrow / number / Enter navigation.
- Consistent styling with window switcher cards.
- GlobalShortcut support.
- Multi-monitor handling.

### Phase 3 — Real Thumbnails (the hard & fun part)
- Implement `WindowThumbnail.qml` using `Screencopy`.
- Capture on open.
- Arrange thumbnails inside each workspace card (grid or approximate layout).
- Performance tuning (scale, cache, limit concurrent captures).

### Phase 4 — Drag & Drop
- Make thumbnails draggable.
- Make workspace cards (and optionally empty areas) droppable.
- Call `hyprctl` on successful drop.
- Visual drag image + target highlighting.

### Phase 5 — Extras
- Live capture mode.
- Click thumbnail focuses specific window.
- Empty workspace support + creation on drop.
- Search/filter.
- Nice enter/exit animations.

## File Changes Planned

- New:
  - `hyprland/docs/workspace-overview.md` (this doc)
  - `qs/WorkspaceOverview.qml`
  - `qs/WorkspaceCard.qml`
  - `qs/WindowThumbnail.qml`
- Modify:
  - `qs/shell.qml` — add component, IpcHandler, properties, key handlers, integration with bar button.
  - `qs/scripts/workspace-overview` — make it call IPC.
  - `hyprland/hyprland.conf` — optional global bind + comment.
  - `hyprland/scripts/workspace-overview` (optional cleanup).

## Challenges & Mitigations

| Challenge                      | Mitigation |
|--------------------------------|----------|
| Capturing many window thumbnails quickly | Small resolution + limit concurrent Screencopy + snapshot on open only |
| Protocol support varies        | Feature-detect or provide graceful fallback (text only + icons) |
| Performance on weak hardware   | Capture only workspaces that are visible in the grid viewport |
| Drag & drop MIME / cross-process | Use simple string (window address) + `hyprctl` |
| Keeping thumbnails up-to-date  | Invalidate on client/workspace events; refresh button for v1 |
| Multi-monitor geometry         | Use `hyprctl monitors -j` + client `monitor` field |

## References

- Window switcher implementation (`hyprland/docs/window-switcher.md`)
- Quickshell screencopy & Wayland module documentation
- Hyprland foreign-toplevel-management + hyprland-toplevel-export protocols
- Current `qs/shell.qml` (AppLauncher and window switcher patterns)

---

This design deliberately reuses every hard-won lesson from the window switcher rewrite.

When you're ready, say the word and we can start implementing Phase 1 (or jump straight into thumbnail component if you want to tackle the hard part first).