#!/usr/bin/env python3
import json
import subprocess
import sys

# 图标映射表
ICON_MAP = {
    "kitty": "",
    "firefox": "",
    "google-chrome": "",
    "chromium": "",
    "code": "󰨞",
    "code-url-handler": "󰨞",
    "visual-studio-code-bin": "󰨞",
    "thunar": "",
    "pcmanfm": "",
    "nautilus": "",
    "pavucontrol": "󰓃",
    "telegram-desktop": "",
    "discord": "󰙯",
    "spotify": "",
    "libreoffice": "󰈙",
    "wps": "󰈙",
    "wpp": "󰈙",
    "et": "󰈙",
    "vlc": "󰕼",
    "mpv": "󰕼",
    "imv": "󰄄",
    "viewnior": "󰄄",
    "default": ""
}

# 工作区原始字母映射 (1-10 -> Q-P)
NAME_MAP = {
    "1": "Q", "2": "W", "3": "E", "4": "R", "5": "T",
    "6": "Y", "7": "U", "8": "I", "9": "O", "10": "P"
}

def get_tree():
    res = subprocess.run(["swaymsg", "-t", "get_tree"], capture_output=True, text=True)
    return json.loads(res.stdout)

def get_workspaces_from_tree(node):
    workspaces = []
    if node.get("type") == "workspace":
        workspaces.append(node)
    else:
        for child in node.get("nodes", []) + node.get("floating_nodes", []):
            workspaces.extend(get_workspaces_from_tree(child))
    return workspaces

def get_app_icon(node):
    # 递归查找所有 leaf 节点（窗口）
    icons = set()
    stack = [node]
    while stack:
        curr = stack.pop()
        # 这是一个具体的窗口
        if curr.get("type") == "con" and (curr.get("window") or curr.get("app_id")):
            app_id = (curr.get("app_id") or curr.get("window_properties", {}).get("class") or "").lower()
            icons.add(ICON_MAP.get(app_id, ICON_MAP["default"]))
        
        stack.extend(curr.get("nodes", []) + curr.get("floating_nodes", []))
    
    return " ".join(sorted(list(icons)))

def update_workspaces():
    tree = get_tree()
    # 递归查找所有工作区
    def find_workspaces(node):
        res = []
        if node.get("type") == "workspace":
            res.append(node)
        for child in node.get("nodes", []) + node.get("floating_nodes", []):
            res.extend(find_workspaces(child))
        return res

    workspaces = find_workspaces(tree)
    
    for ws in workspaces:
        ws_num = ws.get("num")
        if ws_num is None:
            continue
        
        # 查找该工作区下的所有窗口
        def find_windows(node):
            res = []
            if node.get("type") == "con" and (node.get("app_id") or node.get("window_properties")):
                res.append(node)
            for child in node.get("nodes", []) + node.get("floating_nodes", []):
                res.extend(find_windows(child))
            return res
        
        windows = find_windows(ws)
        icons = []
        seen_apps = set()
        
        for win in windows:
            # 提取 app_id 或 class
            app_id = win.get("app_id")
            if not app_id:
                app_id = (win.get("window_properties") or {}).get("class")
            
            app_id = (app_id or "").lower()
            icon = ICON_MAP.get(app_id, ICON_MAP["default"])
            
            # 按照图标去重
            if icon not in seen_apps:
                icons.append(icon)
                seen_apps.add(icon)
        
        # 构建新名字: "1:图标1 图标2" 或 "1"
        if icons:
            new_name = f"{ws_num}:{' '.join(icons)}"
        else:
            new_name = str(ws_num)
            
        if ws.get("name") != new_name:
            subprocess.run(["swaymsg", f"rename workspace '{ws['name']}' to '{new_name}'"], capture_output=True)

def main():
    # 初始运行一次
    update_workspaces()
    
    # 监听窗口事件
    # 注意：为了保持通用性，我们直接定期运行或通过 subscribe
    # 这里使用 subscribe '["window", "workspace"]'
    proc = subprocess.Popen(
        ["swaymsg", "-t", "subscribe", '["window", "workspace"]'],
        stdout=subprocess.PIPE,
        text=True
    )
    
    try:
        while True:
            # 只要有任何事件发生，就重新扫描一次
            proc.stdout.readline()
            update_workspaces()
    except KeyboardInterrupt:
        proc.terminate()

if __name__ == "__main__":
    main()
