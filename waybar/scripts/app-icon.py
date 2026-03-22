import json
import subprocess

# 图标映射表 (可以根据需要自行添加)
ICON_MAP = {
    "firefox": "",
    "firefox-esr": "",
    "kitty": "",
    "foot": "󰽒",
    "code": "󰨞",
    "code-url-handler": "󰨞",
    "thunar": "󰉋",
    "nemo": "󰉋",
    "org.keepassxc.KeePassXC": "",
    "pavucontrol": "󰓃",
    "spotify": "",
    "discord": "󰙯",
    "google-chrome": "",
    "chromium": "",
    "vlc": "󰕼",
    "mpv": "󰕼",
    "cinnamon-settings": "",
}

def get_focused_window():
    try:
        # 获取当前窗口信息
        tree = subprocess.check_output(["swaymsg", "-t", "get_tree"]).decode("utf-8")
        data = json.loads(tree)
        
        def find_focused(node):
            if node.get("focused"):
                return node
            for child in node.get("nodes", []) + node.get("floating_nodes", []):
                res = find_focused(child)
                if res:
                    return res
            return None

        focused = find_focused(data)
        if not focused:
            return "󰣆" # 默认图标

        app_id = focused.get("app_id") or focused.get("window_properties", {}).get("class", "unknown")
        return ICON_MAP.get(app_id.lower(), "󰣆")
    except:
        return "󰣆"

if __name__ == "__main__":
    print(get_focused_window())
