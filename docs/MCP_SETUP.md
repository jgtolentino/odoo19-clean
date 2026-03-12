# MCP Server Setup Guide

Project-scoped MCP configuration for Claude Code.
The `.mcp.json` file in the repo root is committed and covers **Phase 0** and **Phase 1** servers.
Machine-specific secrets live in `.mcp.local.json` (gitignored).

---

## Quick start

```bash
# 1. Export your GitHub PAT (add to ~/.zshrc or ~/.bashrc for persistence)
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_..."

# 2. Ensure runtime dependencies are installed
node --version   # >= 18
npm --version
python3 --version  # >= 3.10
pip install uv   # or: brew install uv

# 3. Install Playwright browsers (first time only)
npx playwright install --with-deps chromium

# 4. Open the project in VS Code / Claude Code — MCPs are auto-discovered from .mcp.json
```

---

## Approved server list

### Phase 0 — install now

| Name | Package | Auth required |
|------|---------|---------------|
| GitHub | `@modelcontextprotocol/server-github` | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| Desktop Commander | `@wonderwhy-er/desktop-commander` | none |
| Context7 | `@upstash/context7-mcp` | none |
| Serena | `mcp-server-serena` (uvx) | none |

### Phase 1 — install next

| Name | Package | Auth required |
|------|---------|---------------|
| Playwright | `@playwright/mcp` | none (browsers required) |
| Chrome DevTools MCP | `@modelcontextprotocol/server-chrome-devtools` | none |
| Markitdown | `markitdown-mcp` (uvx) | none |

### Phase 2 — conditional (Azure prerequisites)

| Name | Prerequisite |
|------|-------------|
| Microsoft Learn | Azure CLI + tenant auth |
| Azure MCP Server | `az login` completed |
| Azure DevOps | `AZURE_DEVOPS_ORG_URL` + PAT |
| Azure AI Foundry | Azure subscription + resource group |

Install Phase 2 only after running `az login` and confirming `az account show` returns a valid subscription.

---

## Config file locations

| File | Scope | Committed |
|------|-------|-----------|
| `.mcp.json` | Project (this repo) | ✅ yes |
| `.mcp.local.json` | Local machine only | ❌ gitignored |
| `~/.claude/mcp.json` | User-global (all projects) | ❌ local only |

### `.mcp.local.json` example

Create this file locally to override or extend `.mcp.json` without committing secrets:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_actual_token_here"
      }
    }
  }
}
```

---

## Validation checklist

Run these commands to confirm each server is functional before relying on it in Claude Code.

```bash
# GitHub
npx -y @modelcontextprotocol/server-github --help

# Desktop Commander
npx -y @wonderwhy-er/desktop-commander --help

# Context7
npx -y @upstash/context7-mcp --help

# Serena
uvx mcp-server-serena --help

# Playwright (also verify browsers)
npx -y @playwright/mcp --help
npx playwright install chromium

# Chrome DevTools MCP
npx -y @modelcontextprotocol/server-chrome-devtools --help

# Markitdown
uvx markitdown-mcp --help
```

---

## Phase 2 prerequisites check

```bash
# Is Azure CLI installed?
az version

# Is the user signed in?
az account show

# Required env vars for Azure DevOps
echo $AZURE_DEVOPS_ORG_URL
echo $AZURE_DEVOPS_TOKEN   # never hardcode; set in shell env only
```

If any of these fail, skip Phase 2 and record the missing items here.

---

## Installed server report

| Server | Phase | Status | Notes |
|--------|-------|--------|-------|
| GitHub | 0 | ⚠️ needs auth | Set `GITHUB_PERSONAL_ACCESS_TOKEN` in shell env |
| Desktop Commander | 0 | ✅ ready | No auth required |
| Context7 | 0 | ✅ ready | No auth required |
| Serena | 0 | ✅ ready | Requires `uv` / `uvx` on PATH |
| Playwright | 1 | ✅ ready | Run `npx playwright install chromium` once |
| Chrome DevTools MCP | 1 | ✅ ready | No auth required |
| Markitdown | 1 | ✅ ready | Requires `uv` / `uvx` on PATH |
| Microsoft Learn | 2 | ⏭️ skipped | Azure CLI auth not confirmed |
| Azure MCP Server | 2 | ⏭️ skipped | Azure CLI auth not confirmed |
| Azure DevOps | 2 | ⏭️ skipped | `AZURE_DEVOPS_ORG_URL` unknown |
| Azure AI Foundry | 2 | ⏭️ skipped | Subscription/resource identifiers unknown |

---

## Follow-up actions

1. **GitHub auth** — export `GITHUB_PERSONAL_ACCESS_TOKEN` in your shell profile.
2. **Playwright browsers** — run `npx playwright install --with-deps chromium` once after cloning.
3. **Phase 2** — run `az login`, confirm `az account show`, then add Azure server entries to `.mcp.local.json` with actual org URLs and tokens (never commit).
