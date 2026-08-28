---
name: import-translation
description: Pull new/changed translation text from the "Proclus Elements of Physics" Google Doc and open a PR against the institutio-physica repo. Use when the user says "import the translation", "pull from the doc", "sync the Proclus doc", or similar.
---

# Import Translation from Google Doc

Repo: `/Users/rfh/dev/institutio-physica`. Conventions: `CONVENTIONS.md` in that
repo — read it if unsure of the target format.

## Step 1: Fetch the Doc

Find the doc: `mcp__claude_ai_Google_Drive__search_files` with query
`title contains 'Proclus Elements of Physics' and mimeType = 'application/vnd.google-apps.document'`.
Use the most recently modified match.

Download it: `mcp__claude_ai_Google_Drive__download_file_content` with
`exportMimeType: text/markdown`. Content comes back base64-encoded — decode it.

## Step 2: Parse structure

Every heading in the Doc's export is `#` regardless of visual level — classify
by text, not by `#` count:

- `Title` / `*Elements of Physics* of the Successor Proclus of Lycia` — front
  matter, discard (already in README.md).
- `Book (\d+)` — start of book N. Target file `book-N.md`.
- `Book (\d+) Definitions` / `Book (\d+) Theorems` — section marker, no repo
  action by itself.
- `Definition (\d+)\.(\d+)` — item, id `def-{book}.{n}`.
- `Theorem (\d+)\.(\d+)` — item, id `thm-{book}.{n}`.

Everything between one of these item headings and the next heading (of any
kind) is that item's body — collect it verbatim (preserve blockquotes,
paragraph breaks, bold, etc; do not rewrite the translator's prose).

If a book/item appears in the Doc that the repo file doesn't have a heading
for yet (new definition/theorem added since last import), that's fine — it
gets appended in the right place (after the preceding numbered item in its
section) with a freshly assigned `{#def-N.M}` / `{#thm-N.M}` id.

## Step 3: Diff against the repo

For each item, read the corresponding `### Definition/Theorem X.Y {#id}`
block in `book-N.md` (from heading to the next `##`/`###` heading or EOF).
Compare its current body to the Doc's body for that item.

- Doc body empty → skip (nothing drafted yet, don't blank out repo content).
- Doc body identical to repo (ignoring whitespace) → skip.
- Otherwise → stage a replacement of that block's body, keeping the heading
  line (with its `{#id}`) unchanged.

If nothing changed, tell the user "nothing new in the doc" and stop — don't
open an empty PR.

## Step 4: Confirm

Show the user a summary before touching git:

```
Changes found in book-N.md:
  Definition 1.4 — new (12 words)
  Theorem 1.2 — edited (was 40 words, now 65)

Proceed?
```

Wait for confirmation.

## Step 5: Branch, commit, PR

In `/Users/rfh/dev/institutio-physica`:

1. `git checkout main && git pull`
2. `git checkout -b robbie/import-doc-<YYYY-MM-DD>`
3. Apply the staged block replacements to the relevant `book-N.md` file(s).
4. `git add book-*.md && git commit -m "<short summary, e.g. 'add Def 1.4, revise Thm 1.2'>"`
5. `git push -u origin HEAD`
6. `gh pr create --title "<same short summary>" --body "<list of changed items>"`

Report the PR URL.
