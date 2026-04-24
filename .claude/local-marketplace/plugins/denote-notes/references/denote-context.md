# Denote Notes Context

## Setup

- **Notes directory**: `~/Documents/Notes/`
- **Emacs server**: Running — use `emacsclient` for all operations
- **Default format**: `.org`; use `markdown-yaml` if user requests markdown
- **Config**: `~/dotfiles/.config/emacs/emacs.org` (denote section)

## File naming convention

```
YYYYMMDDThhmmss--title-slug__tag1_tag2.ext
```

- Title slug: lowercase, spaces → hyphens, special chars stripped
- Tags: underscores between multiple tags, after `__`
- Timestamp: current local time in `YYYYMMDDThhmmss` format

## Known tags (from config)

`emacs`, `philosophy`, `dev`

## Tags currently in use (from existing notes)

`note`, `life`, `philosophy`, `bisr`, `course`, `dev`, `emacs`

New tags can be inferred from content — denote has `denote-infer-keywords t`.

## Org frontmatter format

```org
#+title:      Note Title
#+date:       [YYYY-MM-DD Day HH:MM]
#+filetags:   :tag1:tag2:
#+identifier: YYYYMMDDThhmmss
```

## Markdown frontmatter format (denote-markdown, YAML)

```yaml
---
title: "Note Title"
date: YYYY-MM-DDTHH:MM:SS+00:00
tags:  ["tag1", "tag2"]
identifier: "YYYYMMDDThhmmss"
---
```

## emacsclient patterns

### Create a new note

```bash
emacsclient --eval "(buffer-file-name (denote \"TITLE\" '(\"tag1\" \"tag2\") 'org))"
```

For markdown:
```bash
emacsclient --eval "(buffer-file-name (denote \"TITLE\" '(\"tag1\") 'markdown-yaml))"
```

The return value is the full path to the newly created file (with quotes), e.g.:
`"/Users/rfh/Documents/Notes/20260317T143022--my-title__tag1_tag2.org"`

After creation, denote has already written the frontmatter. Write the body content directly to the file using the Edit/Write tools — no need to go back through emacsclient for content.

### Rename / update metadata

```bash
emacsclient --eval "(denote-rename-file \"FILEPATH\" \"NEW TITLE\" '(\"tag1\" \"tag2\") \"NEW-DATE\")"
```

Leave title/tags/date as `nil` to keep existing values:
```bash
emacsclient --eval "(denote-rename-file \"FILEPATH\" nil '(\"new-tag\") nil)"
```

### Find notes

Search by regexp across filenames:
```bash
emacsclient --eval "(denote-directory-files-matching-regexp \"search-term\")"
```

Or use Grep directly on the notes directory for content search.
