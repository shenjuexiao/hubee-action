#!/usr/bin/env bash
# resolve.sh — 解析 Gitee 命名空间、仓库名、可见性
set -euo pipefail

# ---------- 读取 GitHub 上下文 ----------
GH_OWNER="${GITHUB_REPOSITORY_OWNER:-}"
GH_REPO="${GITHUB_REPOSITORY#*/}"
GH_OWNER_TYPE="${GITHUB_REPOSITORY_OWNER_TYPE:-User}"
GH_PRIVATE="${GITHUB_REPOSITORY_PRIVATE:-false}"

if [ -z "$GH_OWNER" ] || [ -z "$GH_REPO" ]; then
  echo "::error::无法从 GITHUB_REPOSITORY / GITHUB_REPOSITORY_OWNER 获取仓库信息"
  exit 1
fi

echo "GitHub 仓库：${GH_OWNER}/${GH_REPO}（owner.type=${GH_OWNER_TYPE}, private=${GH_PRIVATE}）"

# ---------- 命名空间解析 ----------
# 优先级：gitee_org > gitee_username > GitHub 所有者
if [ -n "${INPUT_GITEE_ORG:-}" ]; then
  GITEE_NAMESPACE="$INPUT_GITEE_ORG"
  GITEE_TARGET_TYPE="org"
elif [ -n "${INPUT_GITEE_USERNAME:-}" ]; then
  GITEE_NAMESPACE="$INPUT_GITEE_USERNAME"
  GITEE_TARGET_TYPE="user"
else
  GITEE_NAMESPACE="$GH_OWNER"
  GITEE_TARGET_TYPE="user"
fi

# ---------- 仓库名 ----------
GITEE_REPO="${INPUT_GITEE_REPO:-$GH_REPO}"

# ---------- 可见性 ----------
if [ "$GITEE_TARGET_TYPE" = "user" ] && [ -z "${INPUT_GITEE_ORG:-}" ]; then
  # 个人仓库固定私有
  GITEE_PRIVATE="true"
else
  GITEE_PRIVATE="${INPUT_GITEE_PRIVATE:-}"
  if [ -z "$GITEE_PRIVATE" ]; then
    if [ "$GH_PRIVATE" = "true" ]; then
      GITEE_PRIVATE="true"
    else
      GITEE_PRIVATE="false"
    fi
  fi
fi

# 归一化
GITEE_PRIVATE="$(echo "$GITEE_PRIVATE" | tr '[:upper:]' '[:lower:]')"
case "$GITEE_PRIVATE" in
  true|1|yes)  GITEE_PRIVATE="true"  ;;
  false|0|no)  GITEE_PRIVATE="false" ;;
  *)
    echo "::warning::gitee_private='${GITEE_PRIVATE}' 无法识别，回退为 true"
    GITEE_PRIVATE="true"
    ;;
esac

# ---------- 输出 ----------
GITEE_URL="https://${INPUT_GITEE_HOST:-gitee.com}/${GITEE_NAMESPACE}/${GITEE_REPO}"

{
  echo "gitee_namespace=$GITEE_NAMESPACE"
  echo "gitee_target_type=$GITEE_TARGET_TYPE"
  echo "gitee_repo=$GITEE_REPO"
  echo "gitee_private=$GITEE_PRIVATE"
  echo "gitee_url=$GITEE_URL"
  echo "github_owner_type=$GH_OWNER_TYPE"
} >> "$GITHUB_OUTPUT"

# 供后续步骤使用
{
  echo "GITEE_NAMESPACE=$GITEE_NAMESPACE"
  echo "GITEE_TARGET_TYPE=$GITEE_TARGET_TYPE"
  echo "GITEE_REPO=$GITEE_REPO"
  echo "GITEE_PRIVATE=$GITEE_PRIVATE"
  echo "GITEE_URL=$GITEE_URL"
} >> "$GITHUB_ENV"

echo "::notice::GitHub(${GH_OWNER_TYPE}) → Gitee(${GITEE_TARGET_TYPE}): ${GITEE_NAMESPACE}/${GITEE_REPO} (private=${GITEE_PRIVATE})"