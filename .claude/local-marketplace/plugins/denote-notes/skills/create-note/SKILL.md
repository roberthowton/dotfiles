---
name: create-note
description: Creates a new Denote note in ~/Documents/Notes/ via emacsclient. Use this skill when the user invokes /create-note, asks to "save this as a note", "create a note about X", "take notes on this", or wants to capture something from the current conversation into their note system.
argument-hint: <description of note content>
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep]
---

# Create Denote Note

Read `references/denote-context.md` first — it has the emacsclient patterns, tag list, and file format details you need.

## Workflow

### 1. Determine title and tags

Based on the user's argument and the conversation context, propose a title and tags.

- Title: concise, descriptive, in plain English (denote will slugify it)
- Tags: pick from existing tags where appropriate; infer new ones if clearly warranted
- Format: `.org` by default; use `markdown-yaml` if the user mentions markdown

Present your proposal briefly:
> Title: "Aristotle on Substance" | Tags: `philosophy`, `bisr`
>
> Proceed, or adjust?

Wait for confirmation. If the user says "yes" / "looks good" / doesn't object, proceed. If they suggest changes, apply them.

### 2. Create the file via emacsclient

```bash
emacsclient --eval "(buffer-file-name (denote \"TITLE\" '(\"tag1\" \"tag2\") 'org))"
```

Strip the surrounding quotes from the returned path. That's your file path.

### 3. Write content

Read the file to see the frontmatter denote wrote, then append the note body after it.

Draw content from the current conversation — summarize, extract key points, or write verbatim depending on what the user asked for. Use standard org structure:

```org
* Overview

<summary or introduction>

* Key points

- Point one
- Point two

* Notes / follow-up

<anything that warrants further attention>
```

Adapt the structure to the content — a quick factual note doesn't need all these headings; a long research summary might need more.

### 4. Confirm

Tell the user the file path and a one-line summary of what was written.
