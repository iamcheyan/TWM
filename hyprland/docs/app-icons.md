# App Icon Resolution in TWM Quickshell

This document describes how icons for applications and windows are resolved, the problems we encountered, the solution, and the fallback pattern.

It serves as a reference for future fixes or when adding new UI components that display app/window icons (e.g., new switchers, panels, menus).

## The Problem

Different parts of the shell were using inconsistent methods to get icons:

- **App Launcher (`qs/AppLauncher.qml`)**: Used `DesktopEntries.applications` → each entry has a reliable `.icon` field (the correct icon name or path registered for that desktop entry). This always worked well.

- **Window switcher** (Alt+Tab / Super+Tab in `qs/shell.qml`): Used raw data from `hyprctl clients -j` (`class`, `initialClass`, `appid`, `appId`). Then called `themedIconSource(name.toLowerCase())` → `Quickshell.iconPath(...)`.

- **Workspace Overview** (`qs/WorkspaceOverview.qml`): Similar raw extraction from clients + custom `iconSource()` using `Quickshell.iconPath`.

- **Top bar current window** (`qs/shell.qml`): Used `ToplevelManager.toplevels` → `activeWindow.appId.toLowerCase()`.

**Result**: Many apps showed missing icons in switcher/overview/bar, while launcher was complete. Common reasons:
- WM_CLASS / app_id (e.g. "Alacritty", "code", "org.mozilla.firefox") does not always match the icon theme name exactly.
- Casing differences.
- Desktop ID vs executable name mismatches (e.g. "Google Chrome" vs "google-chrome").
- Some apps only register icon under their .desktop file ID.

Direct `iconPath(className)` often fails silently for these.

## The Solution

### 1. Unified `appIconSource(appId)` function (in `qs/shell.qml`)

Added a robust resolver that mirrors the launcher's reliability:

```qml
function appIconSource(appId) {
    if (!appId) return "";
    let name = appId.toString().trim();
    if (name.length === 0) return "";

    // 1. Try direct (handles full paths and exact matches)
    let res = Quickshell.iconPath(name, true);
    if (res) return res.startsWith("/") ? "file://" + res : res;

    let lname = name.toLowerCase();

    // 2. Try lowercased
    if (lname !== name) {
        res = Quickshell.iconPath(lname, true);
        if (res) return ...;
    }

    // 3. DesktopEntries lookup (the key fix)
    // Scan for matching id / name / execString
    const entries = DesktopEntries.applications.values;
    for (...) {
        if (match) {
            // use e.icon with iconPath
            return ...;
        }
    }

    return lname; // last resort
}
```

This ensures we prefer the **canonical icon** declared in the .desktop file.

### 2. Improved `iconSource()` in `qs/WorkspaceOverview.qml`

Ported the same logic (direct + lower + DesktopEntries scan) so it is self-contained.

### 3. Updated call sites

- `root.appIconSource(...)` instead of raw `themedIconSource(....toLowerCase())`
- Removed manual `.toLowerCase()` before lookup (function handles normalization).
- Same for workspace overview windows.

### 4. Fallback Letter Tiles (for when even the lookup fails)

When `IconImage.status !== Image.Ready`, show a colored square with the first uppercase letter of the app ID or title.

Pattern (copied from AppLauncher):

```qml
IconImage { id: theIcon; source: appIconSource(...) }

Rectangle {
    visible: theIcon.status !== Image.Ready
    color: "#1e3a5f"
    radius: ...
    Text {
        text: appFallbackLetter(appId, title)
        ...
    }
}
```

Added helper:

```qml
function appFallbackLetter(appId, title) {
    let source = appId || title || "?";
    return source.toString().trim().charAt(0).toUpperCase() || "?";
}
```

Applied to:
- Top bar current window (16px)
- Window switcher cards (36px)
- Workspace overview window rows (16px)

This guarantees **something** always shows, matching the launcher experience.

## How to Use in New Components

1. Import nothing extra (DesktopEntries is available via Quickshell).
2. Call `root.appIconSource(someAppId)` (if inside shell root) or copy the function.
3. For a component like `WorkspaceOverview`, implement a local `iconSource` with the full logic for independence.
4. Always wrap IconImage with a visible fallback Rectangle when `status !== Image.Ready`.
5. Prefer passing the raw `appId` / `class` without pre-lowercasing.
6. For titles as fallback: pass both appId and title to `appFallbackLetter`.

Example for a new window list:

```qml
IconImage {
    id: icon
    source: ...iconSource(appId)
}
Rectangle {
    visible: icon.status !== Image.Ready
    ...
    Text { text: fallbackLetter(appId, title) }
}
```

## Debugging Tips

- Add temporary logs:
  ```qml
  console.log("appId:", appId, "resolved:", root.appIconSource(appId));
  ```
- Check `/tmp/qs-debug.log` (if using the existing debug helper).
- Use `quickshell` with verbose output or inspect `Quickshell.iconPath("firefox", true)`.
- Test specific apps:
  - Run `hyprctl clients | grep -A20 "class:"` for raw class.
  - Look up in `~/.local/share/applications/` or `/usr/share/applications/` for the .desktop file and its `Icon=` line.
- If still missing: the app may not have a proper desktop entry, or icon theme is incomplete. Add explicit mapping in `appIconSource` as last resort.

## Files Involved (as of latest fix)

- `qs/shell.qml` — `appIconSource`, `appFallbackLetter`, bar + window switcher UI
- `qs/WorkspaceOverview.qml` — local `iconSource` + fallback in window rows
- `qs/AppLauncher.qml` — reference implementation (DesktopEntries + fallback tile)
- `hyprland/docs/app-icons.md` — this document

## Future Improvements

- Centralize icon logic into a shared `IconResolver.qml` component or singleton.
- Cache resolved icons.
- Support more matching heuristics (e.g., fuzzy, known aliases like "code" → "visual-studio-code").
- Add async icon loading with better error states.
- Expose `appIconSource` via IpcHandler for scripts if needed.

Reference this document whenever icons are inconsistent after adding new UI or updating data sources (hyprctl, ToplevelManager, etc.).

---

Written as reference for future maintenance. The core principle: **DesktopEntries is the source of truth for app icons. Raw WM class/appId is only a lookup key.**