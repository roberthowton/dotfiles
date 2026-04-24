---
name: update-note
description: Updates an existing Denote note in ~/Documents/Notes/ via emacsclient. Use this skill when the user invokes /update-note, asks to "add this to my note on X", "update my notes about Y", "append to the Z note", "change the tags on", "rename my note", or any request to modify an existing note.
argument-hint: <note to update> [what to change]
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep]
---

# Update Denote Note

Read `references/denote-context.md` first — it has emacsclient patterns, tag list, and file format details.

## Workflow

### 1. Find the note

Use the user's argument to locate the right note. Try in this order:

**By filename/title** (fast):
```bash
emacsclient --eval "(denote-directory-files-matching-regexp \"search-term\")"
```

**By content** (when title is unclear):
```bash
grep -rl "search term" ~/Documents/Notes/ --include="*.org" --include="*.md"
```

If multiple matches, show the candidates (title + date + tags extracted from filename) and ask the user to pick one.

### 2. Identify the change

Determine what kind of update is needed:

- **Append content** — add new material at end of file or into a specific section
- **Edit a section** — modify existing content under a heading
- **Update metadata** — change title, tags, or date via denote-rename-file
- **Combination** — metadata + content changes

For ambiguous requests, read the note first so you can make a sensible proposal.

### 3. Apply the update

**Content changes** — use Edit directly on the file. Read the file first to understand its structure and find the right insertion point. For appending, add content after the last heading or create a new one.

**Metadata changes** (title, tags, date) — use emacsclient so denote keeps the filename and frontmatter in sync:

```bash
# Change tags only (nil keeps existing title and date)
emacsclient --eval "(denote-rename-file \"FILEPATH\" nil '(\"tag1\" \"tag2\") nil)"

# Change title only
emacsclient --eval "(denote-rename-file \"FILEPATH\" \"New Title\" nil nil)"
```

After `denote-rename-file`, the file may have a new path (title change = new slug in filename). Confirm the new path from the return value.

### 4. Confirm

Tell the user what changed and the (possibly new) file path.
