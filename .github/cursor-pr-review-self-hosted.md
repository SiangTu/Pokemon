# Cursor PR Review（自架 Runner）

對應 workflow：`.github/workflows/cursor-pr-review-self-hosted.yml`

## Repository 設定

| 類型 | 名稱 | 說明 |
|------|------|------|
| Secret | `CURSOR_API_KEY` | [Cursor 後台](https://cursor.com/docs/cli/reference/authentication) 建立 API Key |
| Variable（選填） | `CURSOR_MODEL` | 指定模型；不設則使用 CLI 預設 |

## Runner 主機需求

- **Labels**：workflow 使用 `runs-on: self-hosted`，若有多台 runner，請改成例如 `runs-on: [self-hosted, linux, cursor-review]` 並在該機註冊對應 label。
- **必備**：`curl`、`python3`、**Docker**（daemon 運行中，使用者可執行 `docker`）。
- **Cursor CLI**：若 PATH 中尚無 `agent`，第一次執行會自動執行官方安裝腳本（`~/.cursor/bin`）。

## 行為摘要

1. 檢查 `curl` / `python3` / Docker；MCP 映像僅在本地沒有時才 `docker pull`。
2. 動態寫入 `.cursor/mcp.json`（含本次 `GITHUB_TOKEN`），**請勿**把此檔提交進 Git。
3. **每次執行**會合併 **`~/.cursor/cli-config.json`**（依 `.github/cursor-runner-cli-config.min.json`），換新 runner 也會自動帶上 MCP / `gh` 權限；並移除會觸發 schema 錯誤的專案 `.cursor/cli.json`。
4. Cursor Agent 透過 **GitHub MCP** 讀取 PR diff，審查後在 PR 留言。

## 疑難排解

### MCP / `gh` 工具呼叫「被拒絕」

確認 log 裡「Merge Cursor CLI permissions」已成功；**`agent update`**；必要時在 runner 安裝 **`gh`**。詳見 **[`cursor-runner-one-time-setup.md`](cursor-runner-one-time-setup.md)**。

### 其他

- Agent 未呼叫 MCP：確認 Docker 可執行，且 log 中無 MCP 連線錯誤。
- 無法留言：確認 workflow `permissions` 含 `pull-requests: write` / `issues: write`，且非 fork PR 權限受限情境。
- 提示詞過長導致 shell 參數過長：可縮短 `.github/prompts/cursor-pr-review.md`。
