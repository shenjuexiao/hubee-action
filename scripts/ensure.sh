#!/usr/bin/env bash
# ensure.sh — 保证 Gitee 目标仓库存在，不存在则创建
set -euo pipefail

: "${GITEE_NAMESPACE:?缺少 GITEE_NAMESPACE（resolve.sh 未执行？）}"
: "${GITEE_REPO:?缺少 GITEE_REPO}"
: "${GITEE_TARGET_TYPE:?缺少 GITEE_TARGET_TYPE}"
: "${GITEE_PRIVATE:?缺少 GITEE_PRIVATE}"

TOKEN="${INPUT_GITEE_TOKEN:-}"
API="${INPUT_GITEE_API:-https://gitee.com/api/v5}"

if [ -z "$TOKEN" ]; then
  echo "::error::缺少 gitee_token 输入"
  exit 1
fi

REPO_API="${API}/repos/${GITEE_NAMESPACE}/${GITEE_REPO}"
TMP_REPO="$(mktemp)"
trap 'rm -f "$TMP_REPO" /tmp/hubee_create.json' EXIT

HTTP_CODE=$(curl -s -o "$TMP_REPO" -w "%{http_code}" \
  "${REPO_API}?access_token=${TOKEN}")

case "$HTTP_CODE" in
  200)
    echo "::notice::Gitee 仓库已存在：${GITEE_NAMESPACE}/${GITEE_REPO}"
    ;;
  404)
    echo "::notice::Gitee 仓库不存在，正在创建：${GITEE_NAMESPACE}/${GITEE_REPO}"

    if [ "$GITEE_TARGET_TYPE" = "org" ]; then
      CREATE_URL="${API}/orgs/${GITEE_NAMESPACE}/repos"
    else
      CREATE_URL="${API}/user/repos"
    fi

    CREATE_CODE=$(curl -s -o /tmp/hubee_create.json -w "%{http_code}" \
      -X POST "${CREATE_URL}" \
      -H "Content-Type: application/json" \
      -d "{
        \"access_token\": \"${TOKEN}\",
        \"name\": \"${GITEE_REPO}\",
        \"private\": ${GITEE_PRIVATE},
        \"auto_init\": false,
        \"has_issues\": true,
        \"has_wiki\": false
      }")

    if [ "$CREATE_CODE" = "201" ] || [ "$CREATE_CODE" = "200" ]; then
      echo "::notice::Gitee 仓库创建成功"
    else
      echo "::error::创建 Gitee 仓库失败（HTTP ${CREATE_CODE}）"
      cat /tmp/hubee_create.json || true
      exit 1
    fi
    ;;
  *)
    echo "::error::查询 Gitee 仓库失败（HTTP ${HTTP_CODE}）"
    cat "$TMP_REPO" || true
    exit 1
    ;;
esac