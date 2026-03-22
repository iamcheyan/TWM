# Polkit Authentication Agents for Wayland (Sway/Niri)

If you find that entering your password in system settings (like Linux Mint's `cinnamon-settings`) has no effect or keeps asking for the password repeatedly, it's likely a Polkit agent environment issue.

## Recommended Fix

Ensure your Sway/Niri config imports the environment variables **before** starting the agent:

```bash
# In your sway config:
exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Then start/restart the agent
exec pkill polkit-mate-authentication-agent-1; /usr/libexec/polkit-mate-authentication-agent-1
```

## Available Agents and Paths

| Agent | Package | Common Path |
| :--- | :--- | :--- |
| **MATE (Default)** | `mate-polkit` | `/usr/libexec/polkit-mate-authentication-agent-1` |
| **LXQt (Very Stable)** | `lxqt-policykit` | `/usr/bin/lxqt-policykit-agent` |
| **GNOME** | `polkit-gnome` | `/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1` |
| **KDE** | `polkit-kde-agent-1` | `/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1` |

## Troubleshooting

1. **No window pops up**: Check if `xdg-desktop-portal-wlr` is installed and running.
2. **Password accepted but no action**: Usually means the target application (running as root) doesn't know which `WAYLAND_DISPLAY` to connect to. The `dbus-update-activation-environment` command above fixes this.
