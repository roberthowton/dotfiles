---
name: invite-students
description: Invite students from a pasted list of emails to a course via WorkOS. Use when the user says "invite students", "send invitations", "enroll students", or similar. Reads the course orgId and role slug from the course MDX, then sends WorkOS invitations for each email.
---

# Invite Students to Course

Send WorkOS invitations to a list of students for a given course.

## Step 1: Identify the course

If not already provided, ask: "Which course? (provide the slug, e.g. `neoplatonism`)"

## Step 2: Get emails

If not already provided, ask: "Paste the student emails (one per line, or comma-separated)."

Accept any of:
- One email per line
- Comma-separated
- Mixed whitespace/newline delimiters

Extract all valid-looking email addresses. Deduplicate.

## Step 3: Read course metadata

Read `src/content/course/<slug>/index.mdx` in `/Users/rfh/dev/roberthowtondotcom`. Extract `orgId`.

## Step 4: Confirm

Show the user the full list of emails found, and the course + role they'll be invited to:

```
Course: <title> (<slug>)
Org: <orgId>

Emails found (<N>):
  student1@example.com
  student2@example.com
  ...

Proceed?
```

Wait for confirmation before sending.

## Step 5: Check existing invitations

Call `mcp__workos__list_invitations` with `organization_id: <orgId>` and `limit: 100`. Extract emails of already-pending invitations. Skip those in the send step.

## Step 6: Send invitations

For each non-skipped email, call `mcp__workos__send_invitation`:
- `email`: the address
- `organization_id`: `<orgId>`
- `expires_in_days`: 30

Omit `role_slug` — WorkOS automatically assigns the org's default role.

Send in parallel. Collect successes and failures.

## Step 7: Report

```
Invited (N):
  student@example.com
  ...

Already pending / skipped (N):
  returning@example.com
  ...

Failed (N):
  bad@example.com — <error>
  ...
```

## Step 8: Offer course info email draft (optional)

Ask: "Would you like me to draft the course info email for this course?"

Wait for confirmation. If yes:

1. Search Gmail for the most recent sent `[BISR] * -- Course Info` email using `mcp__claude_ai_Gmail__search_threads` with query `from:me subject:"BISR" "Course Info" in:sent` and fetch its full body via `mcp__claude_ai_Gmail__get_thread` to use as a template.

2. Find the first lecture file: look for MDX files under `src/content/lecture/<slug>/` in `/Users/rfh/dev/roberthowtondotcom`, sorted alphabetically — read the first one.

3. Create a Gmail draft via `mcp__claude_ai_Gmail__create_draft`:
   - `to`: `["info@thebrooklyninstitute.com"]`
   - `bcc`: all emails that were successfully invited in Step 6
   - `subject`: `[BISR] <course title> -- Course Info`
   - `body`: follow the structure and tone of the template email, substituting course-specific details (title, dates, meeting place, syllabus URL `roberthowton.com/course/<slug>`, and a summary of week 1 readings drawn from the lecture MDX)
