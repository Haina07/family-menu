#!/bin/bash
set -e

REPO_URL="https://github.com/haina07/family-menu.git"
WORKDIR="$HOME/Documents/family-menu"
DOWNLOADS="$HOME/Downloads"

echo "家庭菜单 GitHub 一键同步"
echo "--------------------------------"

# 1. 检查 git
if ! command -v git >/dev/null 2>&1; then
  echo "未检测到 git。请先安装 Xcode Command Line Tools。"
  xcode-select --install || true
  read -p "安装完成后重新双击本脚本。按回车退出。"
  exit 1
fi

# 2. 克隆或更新仓库
if [ ! -d "$WORKDIR/.git" ]; then
  echo "首次使用，正在克隆仓库..."
  mkdir -p "$(dirname "$WORKDIR")"
  git clone "$REPO_URL" "$WORKDIR"
else
  echo "正在更新本地仓库..."
  cd "$WORKDIR"
  git pull --rebase origin main || git pull origin main
fi

# 3. 找 Downloads 中最新的 Final 版 index.html
LATEST_FILE=$(find "$DOWNLOADS" -maxdepth 2 -type f \
  \( -name "index.html" -o -name "家庭菜单*.html" -o -name "*Final*.html" \) \
  -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -n 1)

if [ -z "$LATEST_FILE" ]; then
  echo ""
  echo "没有在 Downloads 文件夹找到新版网页。"
  echo "请先从 ChatGPT 下载最新的 index.html，再重新双击本脚本。"
  read -p "按回车退出。"
  exit 1
fi

echo "找到最新文件：$LATEST_FILE"

# 4. 备份并替换
cd "$WORKDIR"
if [ -f "index.html" ]; then
  cp "index.html" "index.backup.$(date +%Y%m%d_%H%M%S).html"
fi
cp "$LATEST_FILE" "$WORKDIR/index.html"

# 5. 提交并推送
git add index.html

if git diff --cached --quiet; then
  echo "网页内容没有变化，无需同步。"
else
  git commit -m "Update family menu $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo ""
  echo "同步完成。GitHub Pages 通常在 1-10 分钟内更新。"
  echo "网站：https://haina07.github.io/family-menu/?v=$(date +%s)"
fi

echo ""
read -p "按回车关闭窗口。"
