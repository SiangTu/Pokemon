# Gemini CLI PR Review（自架 Runner）

對應 workflow：`.github/workflows/pr-review.yml`

## 如何觸發

| 方式 | 做法 |
|------|------|
| **PR 開啟／重新開啟** | 新建 PR 或 Reopen 時會自動跑。**往 PR 再 push 新 commit 不會觸發**（未使用 `synchronize`）。 |
| **PR 留言** | 內文含 **`/gemini-review`**；僅 **OWNER / MEMBER / COLLABORATOR**。 |

## Repository 設定

| 類型 | 名稱 | 說明 |
|------|------|------|
| Secret | `GEMINI_API_KEY` | 從 [Google AI Studio](https://aistudio.google.com/apikey) 取得 API Key |
| Variable（選填） | `GEMINI_MODEL` | 指定模型（如 `gemini-2.5-flash`）；不設則預設 `gemini-2.5-pro` |

## Runner 主機需求

- **Labels**：workflow 使用 `runs-on: self-hosted`，若有多台 runner，請改成例如 `runs-on: [self-hosted, linux, gemini-review]` 並在該機註冊對應 label。
- **必備**：`python3`、**Node.js 18+**（含 `npm`）、**Docker**（daemon 運行中，使用者可執行 `docker`）。
- **Gemini CLI**：若 PATH 中尚無 `gemini`，第一次執行會自動執行 `npm install -g @google/gemini-cli`。

## 行為摘要

1. 檢查 `python3` / Node.js / Docker；MCP 映像僅在本地沒有時才 `docker pull`。
2. 動態寫入 `.gemini/settings.json`（含本次 `GITHUB_TOKEN`），**請勿**把此檔提交進 Git。
3. Gemini CLI 使用 `--yolo` 自動核准工具呼叫，透過 **GitHub MCP** 的 **`pull_request_review_write`**（`create` / `submit_pending`）、**`add_comment_to_pending_review`**（含 **suggestion**）、**`pull_request_read`** 進行審查；🔴/🟠 → **REQUEST_CHANGES**，否則 **APPROVE**。
