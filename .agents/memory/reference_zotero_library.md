---
name: zotero-library-organization
description: "How Zotero library is organized (tags not collections), BBT biblatex auto-export config, and PDF attachment/storage layout"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 71c88c9d-e659-4346-876a-030013c4eb09
  modified: 2026-08-03T16:29:40.768Z
---

Library: 1585 items, single "My Library" (no group libraries). No collections used — organization is entirely via 781 flat tags (topic/person/period tags like "Aristotle", "Byzantine Empire", plus `#nosource` marking items with no attached file). See [[zotero-mcp-setup]] for the MCP server itself.

**BibLaTeX export (Better BibTeX / BBT):**
- Active auto-export target: `/Users/rfh/Documents/Local/Bibliography/library.bib` (BBT `autoExport` pref, updates live as library changes)
- Stale leftover export at `/Users/rfh/Documents/Library/library.bib` — last touched 2021-05-18, not the live one, don't treat as current
- Citekey format: `auth.lower + shorttitle(3,3) + year` (BBT `citekeyFormat`), e.g. `abdelhaleemQuranNewTranslation2004`
- `baseAttachmentPath` = `/Users/rfh/Documents/Library` — BBT uses this to shorten file paths in the exported .bib

**PDF attachment storage — mixed model:**
- Legacy/bulk items: linked attachments (not copied by Zotero) at `/Users/rfh/Documents/Library/Zotero Library/<ItemType>/<Author - Year - Title>.pdf`, organized into type subfolders (Book, Book Section, Journal Article, Manuscript, Report, Thesis, etc.)
- Recently added items (since ~2026-06): stored copies inside Zotero's own data dir at `/Users/rfh/Zotero/storage/<ItemKey>/<filename>.pdf` (default Zotero "store a copy" behavior, not linked) — attachment strategy shifted at some point, don't assume all files live under Documents/Library
- Zotero data dir: `/Users/rfh/Zotero` (`extensions.zotero.dataDir` pref); profile at `~/Library/Application Support/Zotero/Profiles/pw3pddk6.default`

**How to apply:** Treat `/Users/rfh/Documents/Local/Bibliography/library.bib` as the canonical .bib file. Use the `zotero_get_attachment_path` MCP tool (not a path guess) to find a given item's PDF, since location varies by when it was added. Collections are unused — filter/search by tag instead.
