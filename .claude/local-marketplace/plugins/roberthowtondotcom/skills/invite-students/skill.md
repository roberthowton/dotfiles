---
name: invite-students
description: Add or invite students from a pasted list of emails to a course via WorkOS. Use when the user says "invite students", "send invitations", "add students", "enroll students", or similar. Reads the course orgId from the course MDX, confirms invitation vs. direct-add mode with the user, then enrolls each email accordingly.
---

# Add Students to Course

Enroll a list of students for a given course via WorkOS, either by email invitation (must accept) or direct add (immediate access, no acceptance step).

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

Read `src/content/course/<slug>/index.mdx` in `/Users/rfh/dev/roberthowtondotcom`. Extract `orgId`. The course's role slug follows the `org-<keyword>` convention (see the `new-course` skill) — derive `<keyword>` from `<slug>`; confirm it with the user in Step 4 rather than assuming it's exact.

## Step 4: Confirm mode and details — always ask, every run

Do not assume or reuse a prior answer from earlier in the conversation — always use `AskUserQuestion` to ask which mode to use for this batch:

- **Invitation** — WorkOS sends an email; student must accept before getting access. Uses the org's default role automatically.
- **Direct add** — student is added as an active org member immediately, no email, no acceptance. Requires the role slug (`org-<keyword>`); create the WorkOS user first if they don't already have an account.

Then show the full list of emails found, and the course + role:

```
Course: <title> (<slug>)
Org: <orgId>
Mode: <Invitation | Direct add>
Role slug (direct add only): org-<keyword>

Emails found (<N>):
  student1@example.com
  student2@example.com
  ...

Proceed?
```

Wait for confirmation before sending.

## Step 5a: Invitation mode

1. Call `mcp__workos__list_invitations` with `organization_id: <orgId>` and `limit: 100`. Extract emails of already-pending invitations. Skip those in the send step.
2. For each non-skipped email, call `mcp__workos__send_invitation`:
   - `email`: the address
   - `organization_id`: `<orgId>`
   - `expires_in_days`: 30
   - Omit `role_slug` — WorkOS automatically assigns the org's default role.
3. Send in parallel. Collect successes and failures.

## Step 5b: Direct-add mode

For each email:

1. Call `mcp__workos__list_users` with `email: <email>` to check for an existing WorkOS user.
2. If none found, call `mcp__workos__create_user` with `email: <email>` and `email_verified: false` — omit `first_name`/`last_name` rather than guessing one from the email local-part; the app's account page and header avatar already fall back cleanly to the email/a generic icon when no name is on file (a synthesized name like "Jdoe123" is worse than no name).
3. Call `mcp__workos__create_organization_membership`:
   - `user_id`: the found/created user's id
   - `organization_id`: `<orgId>`
   - `role_slug`: `org-<keyword>`

If the membership call fails because the user is already a member, treat as skipped, not failed.

Do this per-email sequentially (create-then-membership is two dependent calls per user) but you may run different emails' pipelines in parallel.

## Step 6: Report

```
<Invited | Added> (N):
  student@example.com
  ...

Already pending / already a member — skipped (N):
  returning@example.com
  ...

Failed (N):
  bad@example.com — <error>
  ...
```

If direct-add mode: note that newly-created users have no password set — they'll need to use your normal signup/password-reset flow (e.g. `mcp__workos__send_password_reset_email`) to log in for the first time.

## Step 7: Offer course info email draft (optional)

Ask: "Would you like me to draft the course info email for this course?"

Wait for confirmation. If yes:

1. Search Gmail for the most recent sent `[BISR] * -- Course Info` email using `mcp__claude_ai_Gmail__search_threads` with query `from:me subject:"BISR" "Course Info" in:sent` and fetch its full body via `mcp__claude_ai_Gmail__get_thread` to use as a template.

2. Find the first lecture file: look for MDX files under `src/content/lecture/<slug>/` in `/Users/rfh/dev/roberthowtondotcom`, sorted alphabetically — read the first one.

3. Create a Gmail draft via `mcp__claude_ai_Gmail__create_draft`:
   - `to`: `["info@thebrooklyninstitute.com"]`
   - `bcc`: all emails successfully invited/added in Step 5a/5b
   - `subject`: `[BISR] <course title> -- Course Info`
   - `body`: follow the structure and tone of the template email, substituting course-specific details (title, dates, meeting place, syllabus URL `roberthowton.com/course/<slug>`, and a summary of week 1 readings drawn from the lecture MDX)
