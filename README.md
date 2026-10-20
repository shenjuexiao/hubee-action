# hubee-action

## 🚀 项目

[shenjuexiao/hubee-action](https://github.com/shenjuexiao/hubee-action)

## 😀 简介

📦 GitHub -> Gitee 仓库自动镜像的复合 Action。支持组织/个人、公有/私有、仓库不存在时自动创建。

## 💎 特性

- 🔁 推送（`push` / `schedule` / `workflow_dispatch`）时自动同步
- 🏢 支持 GitHub 组织/个人 → Gitee 组织/个人 四种组合
- 🔒 可见性默认跟随 GitHub，个人目标仓库固定私有
- 🆕 目标仓库不存在时自动创建（`auto_init: false`）
- 📦 镜像所有分支与标签（`--prune --force`）

## 📥 输入

| 名称 | 必填 | 默认 | 说明 |
| --- | --- | --- | --- |
| `gitee_token` | ✅ | — | Gitee 私人令牌（需 `projects` 权限） |
| `gitee_org` | ❌ | `''` | Gitee 组织名，优先于 `gitee_username` |
| `gitee_username` | ❌ | `''` | Gitee 用户名 |
| `gitee_repo` | ❌ | GitHub 仓库名 | Gitee 目标仓库名 |
| `gitee_private` | ❌ | 跟随 GitHub | `true` / `false` |
| `gitee_api` | ❌ | `https://gitee.com/api/v5` | API 基地址 |
| `gitee_host` | ❌ | `gitee.com` | Git 推送主机 |
| `git_user_name` | ❌ | `github-actions[bot]` | 推送身份 |
| `git_user_email` | ❌ | `github-actions[bot]@users.noreply.github.com` | 推送邮箱 |

### 🚨 命名空间解析优先级

1. `gitee_org` -> 组织（组织名），优先于 `gitee_username`
2. `gitee_username` -> 个人（用户名）
3. 回退：GitHub 所有者名，按个人（用户名）处理

### 🔍 可见性规则

- 目标为组织：`gitee_private` 缺省则跟随 GitHub 仓库私有性
- 目标为个人（未指定 `gitee_org`）：固定私有，忽略 `gitee_private`

## 📤 输出

| 名称 | 说明 |
| --- | --- |
| `gitee_namespace` | 解析后的命名空间 |
| `gitee_target_type` | `org` / `user` |
| `gitee_repo` | 解析后的仓库名 |
| `gitee_private` | `true` / `false` |
| `gitee_url` | 仓库访问地址 |

## ⌨️ 用法

1. 新建 Gitee 私人令牌
`账号设置` -> `私人令牌`-> [`GITEE_TOKEN`](https://gitee.com/profile/personal_access_tokens)

![Gitee Profile Personal Access Tokens](https://cdn.jsdelivr.net/gh/shenjuexiao/shenjuexiao@main/releases_png/gitee_profile_personal_access_tokens.png)

2. 新建 GitHub 仓库 Repository Secrets
`Settings` -> `Secrets and variables` -> `Actions` -> `Repository secrets` -> `Repository secrets`

 - 最少设置：`GITEE_TOKEN`
 - 最多设置：`GITEE_TOKEN`、`GITEE_ORG` 或 `GITEE_USERNAME`、`GITEE_REPO`、`GITEE_PRIVATE`

![GitHub Settings Secrets Actions](https://cdn.jsdelivr.net/gh/shenjuexiao/shenjuexiao@main/releases_png/github_settings_secrets_actions.png)

3. 将 [`examples/workflow.yml`](examples/workflow.yml) （重命名）复制到 
`.github/workflows/`，或者将相应代码复制到原有的 `*.yml` 的 `steps: `内。

```yaml
- name: hubee-action
  uses: shenjuexiao/hubee-action@v1
  with:
    gitee_token:    ${{ secrets.GITEE_TOKEN }}
    gitee_org:      ${{ secrets.GITEE_ORG }}
    gitee_username: ${{ secrets.GITEE_USERNAME }}
    gitee_repo:     ${{ secrets.GITEE_REPO }}
    gitee_private:  ${{ secrets.GITEE_PRIVATE }}
```

## 许可证

[MIT](LICENSE)
