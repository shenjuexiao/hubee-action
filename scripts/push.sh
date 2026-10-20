#!/usr/bin/env bash
# push.sh — 镜像推送 GitHub 仓库到 Gitee
set -euo pipefail

: "${GITEE_NAMESPACE:?缺少 GITEE_NAMESPACE}"
: "${GITEE_REPO:?缺少 GITEE_REPO}"

TOKEN="${INPUT_GITEE_TOKEN:-}"
HOST="${INPUT_GITEE_HOST:-gitee.com}"

if [ -z "$TOKEN" ]; then
  echo "::error::缺少 gitee_token 输入"
  exit 1
fi

# ---------- Git 身份 ----------
git config --global user.name  "${INPUT_GIT_USER_NAME:-github-actions[bot]}"
git config --global user.email "${INPUT_GIT_USER_EMAIL:-github-actions[bot]@users.noreply.github.com}"

# ---------- 远端地址（oauth2 固定用户名，个人/组织通用） ----------
REMOTE_URL="https://oauth2:${TOKEN}@${HOST}/${GITEE_NAMESPACE}/${GITEE_REPO}.git"

if git remote | grep -qx gitee; then
  git remote set-url gitee "$REMOTE_URL"
else
  git remote add gitee "$REMOTE_URL"
fi

# ---------- 镜像推送所有分支与标签 ----------
git push --prune --force gitee \
  "refs/remotes/origin/*:refs/heads/*" \
  "refs/tags/*:refs/tags/*"

echo "::notice::已成功同步到 https://${HOST}/${GITEE_NAMESPACE}/${GITEE_REPO}"