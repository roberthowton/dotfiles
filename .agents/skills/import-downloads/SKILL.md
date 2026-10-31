---
name: import-downloads
description: Import academic PDFs from ~/Downloads into Zotero, creating bib entries from DOI/ISBN, attaching and renaming the PDF, skipping duplicates and non-bibliographic files. Use when the user says "import my downloads to zotero", "add pdfs from downloads to my library", or similar.
---

# Import Downloads to Zotero

`~/Downloads` mixes real papers/books with tax documents, ID scans, resumes, board minutes, screenshots, etc. This skill is deliberately conservative: it only touches a PDF if it can find a DOI or ISBN for it (in the filename or the PDF's own text). Anything it can't identify is left alone and reported, never guessed at.

Scope: top-level `*.pdf` files directly in `~/Downloads` only (no subfolders, no `.epub`).

## Step 0: Prerequisites

Zotero write operations (`zotero_add_by_doi`, `zotero_add_by_isbn`, `zotero_attach_file`) fail in local-only mode. Check the current server env:

```bash
grep -A6 '"zotero"' ~/.claude.json
```

If it only has `ZOTERO_LOCAL=true` with no `ZOTERO_API_KEY`/`ZOTERO_LIBRARY_ID`, stop and tell the user: they need a Web API key + numeric userID from https://www.zotero.org/settings/security#applications, then you (Claude) reconfigure with:

```bash
claude mcp remove zotero --scope user
claude mcp add zotero --scope user --env ZOTERO_LOCAL=true --env ZOTERO_API_KEY=<key> --env ZOTERO_LIBRARY_ID=<id> -- zotero-mcp
```

This needs a session restart / `/mcp` reconnect to take effect. Don't proceed past this step until write mode is confirmed working (e.g. a harmless call like `zotero_get_recent` still works, and the credentials are present).

Also confirm Zotero desktop is running (local reads still go through it even in hybrid mode).

## Step 1: Scan

Run the bundled scanner (read-only, safe to run anytime):

```bash
python3 "<skill_dir>/scripts/scan_downloads.py" ~/Downloads
```

(`<skill_dir>` is this skill's own directory — resolve it relative to this file.)

Output is JSONL, one object per PDF:
```json
{"path": "...", "filename": "...", "id_type": "doi"|"isbn"|null, "id_value": "...", "source": "filename"|"text"|null}
```

Parse it and bucket into: `doi_items`, `isbn_items`, `no_identifier` (id_type is null).

## Step 2: Cross-check against the existing library (don't trust `if_exists="skip"` alone)

**Known bug:** `zotero_add_by_isbn`/`zotero_add_by_doi`'s `if_exists="skip"` dedup pre-filters via a Zotero quicksearch on the bare identifier, which does a literal substring match. DOIs are stored bare so DOI dedup works fine. ISBNs are commonly stored **hyphenated** (e.g. `978-0-8425-2353-0`), so a bare-digit candidate (`9780842523530`) never substring-matches and the built-in dedup silently misses it — this WILL create a real duplicate item if you skip this step and rely on Step 3/4's `if_exists="skip"` alone. Confirmed empirically against this library; do not re-litigate it, just do this step.

Cross-check against the BBT biblatex export instead (continuously auto-synced, see memory on Zotero library organization for the path — as of this writing `/Users/rfh/Documents/Local/Bibliography/library.bib`). This same script also detects duplicate downloads **within** this batch (e.g. two copies of the same PDF), using actual file-content hashing rather than trusting a shared identifier:

```bash
python3 "<skill_dir>/scripts/scan_downloads.py" ~/Downloads | \
  python3 "<skill_dir>/scripts/check_existing.py" /Users/rfh/Documents/Local/Bibliography/library.bib > scan_annotated.jsonl
```

**Why hash, not just identifier:** this library has multi-volume works (Boyle's collected works, Alexander of Aphrodisias' *Metaphysics* commentary, Anscombe's collected papers, Plotinus' *Enneads*) where Anna's Archive's cataloging reuses ONE ISBN across several genuinely different volumes. Treating "same ISBN" as "same file" would silently drop real, distinct volumes — confirmed empirically (Boyle vol.4 and vol.5 share an ISBN but are different files with different content). So two files only count as a true duplicate when they're byte-identical; if they share an identifier but aren't byte-identical, they're routed to manual review instead of being resolved either way.

Each row now has:
- `already_in_library` (bool) / `matched_citekey` — already owned, per Step 2's bib cross-check.
- `batch_duplicate` (bool) / `duplicate_of` — byte-identical to an earlier file in this scan.
- `identifier_collision` (bool) / `collision_with` — shares a DOI/ISBN with other file(s) here but isn't byte-identical to them (different volume or different scan/source) — ambiguous, needs a human decision.

Split `doi_items`/`isbn_items` into four buckets:
- `new`: none of the above flags set → proceed to Step 4/5.
- `duplicate_owned`: `already_in_library` → never call an add tool, goes straight to the duplicates-folder move in Step 4.
- `duplicate_batch`: `batch_duplicate` (and not already owned) → same, moves to the duplicates folder, only the primary copy gets imported.
- `collision`: `identifier_collision` → do NOT move, do NOT import. Report only, for manual review.

If the bib file is missing or unreadable, fall back to relying on `if_exists="skip"` for DOI items only, and warn the user explicitly that ISBN dedup could not be verified and duplicates are possible — do not silently proceed as if it were safe.

## Step 3: Confirm before running

This mutates the user's Zotero library and moves files. Show a summary and wait for go-ahead:

```
Scanned N PDFs in ~/Downloads:
  X with a DOI, Y with an ISBN
    -> A already in your library (moving to ~/Downloads/zotero-duplicates/)
    -> B duplicate downloads within this batch (moving to ~/Downloads/zotero-duplicates/)
    -> C same identifier but different content — needs your manual review, left in place
    -> D genuinely new
  Z with no identifier found (left untouched)

Proceed with importing D new items?
```

## Step 4: Move duplicate PDFs aside

Before importing anything, clear duplicates out of the way so they aren't left cluttering `~/Downloads` (create `~/Downloads/zotero-duplicates/` if it doesn't exist):

- For every row in `duplicate_owned` (already in the library): `mv "<path>" ~/Downloads/zotero-duplicates/`. Record in the report's `already-owned` bucket with `matched_citekey`.
- For every row in `duplicate_batch` (byte-identical to another file in this scan): `mv "<path>" ~/Downloads/zotero-duplicates/`. Record in the report's `batch-duplicate` bucket, noting which primary file it duplicated (that primary proceeds to import normally in Step 5/6).
- For every row in `collision` (identifier collision, not byte-identical): leave the file exactly where it is. Do not move it, do not import it. Record in the report's `needs-manual-review` bucket with the paths of the other file(s) it collides with.

## Step 5: Import new DOI items

For each item in `doi_items`'s `new` bucket, call:

```
mcp__zotero__zotero_add_by_doi(doi=<id_value>, attach_mode="none", if_exists="skip")
```

`if_exists="skip"` here is just a backstop (catches anything added to the library after the bib export last ran) — the real dedup already happened in Step 2. Inspect the response:
- **Created**: a new item key comes back → go to Step 7 to attach the PDF.
- **Skipped (already existed)**: record in the `already-owned` bucket with the filename and the existing item's title/key.
- **Error** (e.g. DOI not found in CrossRef): record in the `failed` bucket with the error message.

## Step 6: Import new ISBN items

Same pattern for `isbn_items`'s `new` bucket:

```
mcp__zotero__zotero_add_by_isbn(isbn=<id_value>, if_exists="skip")
```

(No `attach_mode` param here — books never auto-download a PDF, so nothing to disable.) Same three outcomes as Step 5 — but remember `if_exists="skip"` is not reliable for ISBN on its own (Step 2's bug note), so a "Created" result here is trustworthy only because Step 2 already filtered out the known duplicates.

## Step 7: Attach and rename the PDF

For every item actually created in Steps 5–6:

1. Fetch its metadata: `mcp__zotero__zotero_get_item_metadata(item_key=<key>, format="json")`.
2. Build the attachment filename in this library's existing convention, `Author - Year - Title.pdf`:
   - Author: first creator's last name (if multiple creators, just the first — matches existing library examples like "Buchman - 1998 - ...")
   - Year: from the `date` field
   - Title: the `title` field, trimmed if extremely long
   - Sanitize for the filesystem (strip `/`, `:`, etc.)
3. Call `mcp__zotero__zotero_attach_file(item_key=<key>, file_path=<original local path>, filename=<built name>)`.
4. On success, move the original file: `mv "<original path>" ~/Downloads/zotero-imported/` (create that directory first if it doesn't exist). Record in the `imported` bucket.
5. On attach failure, record in `failed` — do NOT move the file (leave it in Downloads since it's only half-imported).

## Step 8: Duplicate sanity pass

After processing, run `mcp__zotero__zotero_find_duplicates(method="both", limit=50)` on the whole library. This is read-only — report any duplicate clusters it surfaces for the user's manual review, but do not merge anything automatically.

## Step 9: Report

Print a final categorized report:

```
## Zotero Import Report

Imported (N):
  - <Title> (<Author>, <Year>) — moved to ~/Downloads/zotero-imported/<filename>.pdf

Already in your library, moved to ~/Downloads/zotero-duplicates/ (N):
  - <original filename> — matches existing item "<title>" (<citekey>)

Duplicate downloads within this batch, moved to ~/Downloads/zotero-duplicates/ (N):
  - <filename> — byte-identical to <primary filename> (which was imported)

Same identifier but different content — left in place, needs your review (N):
  - <filename> — shares <DOI/ISBN> with: <other filename(s)>
  - ... (this usually means different volumes of a multi-volume work cataloged under one ISBN — check before adding manually)

No identifier found, left in place (N):
  - <filename>
  - ... (list all — this is the user's manual-review pile)

Failed (N):
  - <filename> — <error>

Possible duplicate clusters flagged by Zotero (N groups):
  - <titles/keys> — review manually, not auto-merged
```

Keep the "no identifier found" and "needs your review" lists complete (not truncated) — they're the main actionable output for the user.
