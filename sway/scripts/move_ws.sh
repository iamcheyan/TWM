#!/bin/bash
action=$1 # "next" 或 "prev"
cur=$(swaymsg -t get_workspaces | jq '.[] | select(.focused==true).num')

if [ "$action" == "next" ]; then
    target=$((cur + 1))
elif [ "$action" == "prev" ] && [ "$cur" -gt 1 ]; then
    target=$((cur - 1))
else
    exit 0
fi

# 核心移动逻辑：将窗口发送到目标工作区并跳转过去
swaymsg "move container to workspace number $target"
swaymsg "workspace number $target"
