#!/bin/bash
cd "$(dirname "$0")" || exit 1

echo "=== 根据 .gitignore 自动管理文件 ==="
echo ""

# 1. 找出应该被忽略但仍在 Git 中跟踪的文件，从 Git 中删除
echo "检查应该被忽略的文件..."
REMOVED_COUNT=0
while IFS= read -r file; do
    if [ -n "$file" ] && [ "$file" != ".gitignore" ]; then
        if git check-ignore -q "$file" 2>/dev/null; then
            if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
                echo "  删除: $file (被 .gitignore 忽略)"
                git rm --cached "$file" 2>/dev/null && REMOVED_COUNT=$((REMOVED_COUNT + 1))
            fi
        fi
    fi
done < <(git ls-files)

if [ "$REMOVED_COUNT" -gt 0 ]; then
    echo "✓ 已从 Git 中删除 $REMOVED_COUNT 个应该被忽略的文件"
else
    echo "✓ 没有需要删除的文件"
fi
echo ""

# 2. 添加所有文件（遵循 .gitignore 规则）
echo "添加文件..."
git add -A
echo "✓ 文件已添加"
echo ""

# 3. 显示最终状态
echo "=== 文件状态总结 ==="
TRACKED_COUNT=$(git ls-files | wc -l)
IGNORED_COUNT=$(git ls-files | xargs git check-ignore 2>/dev/null | wc -l)
echo "已跟踪文件: $TRACKED_COUNT"
echo "应该被忽略但仍跟踪的文件: $IGNORED_COUNT"
echo ""

# 使用时间戳作为 commit 消息（格式：YYYYMMDD_HHMMSS）
COMMIT_MSG="同步配置到仓库 [$(date +"%Y%m%d_%H%M%S")]"
git commit -m "$COMMIT_MSG"

# 推送到远程 (自动匹配当前分支)
echo "推送到远程..."
git push origin HEAD
