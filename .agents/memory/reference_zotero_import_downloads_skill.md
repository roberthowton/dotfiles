---
name: zotero-import-downloads-skill
description: "The import-downloads Zotero skill — what it does, where it lives, and the write-mode blocker it depends on"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 71c88c9d-e659-4346-876a-030013c4eb09
  modified: 2026-08-05T15:30:30.858Z
---

Built a `zotero` plugin at `/Users/rfh/dotfiles/.claude/local-marketplace/plugins/zotero/` with one skill, `import-downloads` (invoke as `/zotero:import-downloads`). Registered in `dotfiles/.claude/settings.json` (`enabledPlugins["zotero@local"]`) and `dotfiles/.claude/local-marketplace/.claude-plugin/marketplace.json`. See [[zotero-library-organization]] and [[zotero-mcp-setup]] for the underlying Zotero setup this builds on.

**What it does:** scans top-level `*.pdf` in `~/Downloads` (not subfolders, not epub), detects a DOI or ISBN per file via `scripts/scan_downloads.py` (filename patterns first — Anna's Archive/libgen/JSTOR conventions — then `pdftotext` on the first 8 pages, including a JSTOR-stable-URL→DOI fallback for `10.2307/<id>`), then for identified files calls `zotero_add_by_doi`/`zotero_add_by_isbn` with `if_exists="skip"` (this is the dedup mechanism), attaches the PDF renamed to `Author - Year - Title.pdf`, and moves the source file to `~/Downloads/zotero-imported/`. Files with no identifier are left untouched and listed in the final report for manual review — deliberately not guessed at, since Downloads mixes real papers with tax docs, ID scans, resumes, etc.

**Validated against the real folder (2026-08):** 293 PDFs, 130 identifiable (34 DOI + 96 ISBN), 163 with no identifier — zero false positives against a personal-document keyword sweep (tax/license/passport/resume/1099/mortgage/etc.).

**Write mode:** configured 2026-08-05 — `zotero` MCP server now runs hybrid (`ZOTERO_LOCAL=true` + `ZOTERO_API_KEY` + `ZOTERO_LIBRARY_ID=5690192`, resolved from the key via `GET api.zotero.org/keys/<key>` since the user only had the username handy, not the numeric ID). Confirmed connected and write-capable.

**Real bug found and fixed (2026-08-05):** `zotero_add_by_isbn`/`zotero_add_by_doi`'s `if_exists="skip"` dedup relies on a Zotero quicksearch pre-filter that does literal substring matching on the bare identifier. DOIs are stored bare in this library so DOI dedup works. ISBNs are commonly stored **hyphenated** (`978-0-8425-2353-0`), so a bare-digit query (`9780842523530`) never substring-matches and the dedup silently misses it — confirmed by testing against a known duplicate (Al-Ghazali *Niche of Lights*, already in library as `8Y2KGCBN`/`buchmanAlGhazaliNicheLights1998`). Left unaddressed, the skill would create real duplicate items for any already-owned book. Fixed by adding `scripts/check_existing.py`, which cross-checks every scanned candidate against the BBT `.bib` export (normalized properly on our side) *before* any write — this is now the authoritative dedup gate; `if_exists="skip"` is just a backstop for items added since the last export sync. On the real Downloads folder this mattered a lot: of 130 identifiable candidates, 42 (8 DOI + 34 ISBN) were already-owned duplicates that the old design would have re-added.

**How to apply:** If asked to run/debug/extend this skill, or if writing similar Zotero-dedup logic elsewhere, do NOT trust `if_exists="skip"` for ISBN matching without the bib cross-check — this is a property of the zotero-mcp-server tool itself (in `_helpers.py`, `find_existing_items`), not something specific to one run.
