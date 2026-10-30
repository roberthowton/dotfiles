---
name: zotero-mcp-setup
description: "zotero-mcp-server MCP install details — install method, mode, and prereqs to relaunch it"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 71c88c9d-e659-4346-876a-030013c4eb09
  modified: 2026-08-03T16:29:48.714Z
---

`zotero` MCP server (github.com/54yyyu/zotero-mcp) registered in Claude Code user config (`~/.claude.json`), command `zotero-mcp`, mode `ZOTERO_LOCAL=true` (local read-only, no API key — user chose this over Web API/hybrid).

Installed via `uv tool install zotero-mcp-server` (system Python was 3.9, server needs 3.10+; uv fetched its own Python). `uv` itself installed via `brew install uv`. Binaries land in `~/.local/bin` (already on PATH via `.zshrc`).

Related: [[zotero-library-organization]] for how the actual library is structured.

**How to apply:** For this to work, Zotero desktop must be running AND "Allow other applications on this computer to communicate with Zotero" must be enabled in Zotero Settings → Advanced. If Zotero MCP tools fail/timeout, check that first before debugging the MCP config itself.
