---
name: new-course
description: Scaffold a new course page in the roberthowtondotcom Astro repo from a Brooklyn Institute for Social Research (BISR) course URL. Use this skill whenever the user wants to add, set up, or create a new course — including when they paste a thebrooklyninstitute.com URL, say "add this course", "set up a new course", "create a course page", or similar. Fetches course data from BISR automatically, creates the directory structure and MDX file, and sets up the WorkOS organization and role for student enrollment.
---

# New Course Setup

Scaffold a new course in `src/content/course/` of the roberthowtondotcom repo. Steps 1–3 are sequential. After confirmation, dispatch four subagents in parallel (Phase A), then create `index.mdx` once they return.

## Step 1: Get the BISR URL

If not already provided, ask: "What's the BISR course URL?"

## Step 2: Fetch and extract

WebFetch the URL. Extract:

| Field | Source |
|---|---|
| `title` | h1 or `og:title` meta tag |
| `description` | Main course description (all body paragraphs) |
| `dates` | Date range string, e.g. `"April 14—May 5, 2026"` |
| `term` | Month + year of start date, e.g. `"April 2026"` |
| `meetingTimes` | Day(s) and time, e.g. `"Tuesdays, 6:30–9:30pm ET"` |
| `isOnline` | `true` if "online" or Zoom is mentioned; `false` otherwise |
| `imageUrl` | `og:image` meta tag first, then largest page image |
| `imageAlt` | Image caption or credit from the page (often artist/artwork attribution) |
| `slug` | Last non-empty path segment of the URL |

## Step 3: Confirm and collect missing fields

Present what was extracted, then ask for what can't be scraped.

**For in-person courses:**
- `meetingPlace` — venue name (e.g., `"BISR Central"`, `"Valerie Goodman Gallery"`)
- `meetingPlaceUrl` — venue website
- `googleMapsUrl` — Google Maps embed URL (Maps → Share → Embed a map → copy the `src` from the iframe)

**For online courses:**
- `meetingLink` — Zoom URL (may not exist yet; omit from frontmatter if so)

Also propose a **role keyword** for the WorkOS role slug. Convention:
- Philosopher-named courses → philosopher's surname lowercase (e.g., `kripke`, `anscombe`)
- Topic courses → key topic word (e.g., `color`, `teleology`)

Present as: `org-<keyword>` and ask the user to confirm before proceeding.

Wait for user confirmation before proceeding.

---

## Phase A: Parallel subagents

Dispatch all four subagents **in the same message** and wait for all to complete before proceeding.

### Subagent 1 — WorkOS setup

> Set up a WorkOS organization for a new course. Use the WorkOS MCP tools.
>
> 1. Create the organization using `mcp__workos__create_organization`:
>    - `name`: "<course title>"
>    - `allow_profiles_outside_organization`: false
>
> 2. Using the returned org `id`, create the role using `mcp__workos__create_role`:
>    - `organization_id`: <orgId>
>    - `name`: "<Keyword> Students"
>    - `slug`: "org-<keyword>"
>
> Return the `orgId`.
>
> Note: `mcp__workos__update_organization`'s `default_role` param is a no-op (confirmed: response never echoes it, dashboard "Org default" badge doesn't change) — the default flag lives on the role, not the org, and there's no `update_role` tool. Setting the role as org default, plus creating/attaching the permission, must both be done manually in the dashboard (Step 4b below).

### Subagent 2 — Assets

> Download the course image for a new course in the roberthowtondotcom repo at `/Users/rfh/dev/roberthowtondotcom`.
>
> 1. `mkdir -p src/content/course/<slug>/assets`
> 2. `curl -L "<imageUrl>" -o "src/content/course/<slug>/assets/<filename>"`
>    - Derive `<filename>` from the URL basename; use a short kebab-case name if it's generic.
>
> Return the `<filename>` used.

### Subagent 3 — Google Calendar

> Create recurring Google Calendar events for a new course using `mcp__claude_ai_Google_Calendar__create_event`.
>
> Calendar ID: `8b72d58868a5b5aafc4eaebc0003e3dc0a42ac97b1ae7eeae7ab4f46e4624cdc@group.calendar.google.com`
>
> Derive session dates from `dates` and `meetingTimes`. Use `RRULE:FREQ=WEEKLY;COUNT=<n>` for the number of sessions. If `dates` mentions exceptions (e.g. "No class November 30"), add `EXDATE:<date>T000000Z` to `recurrenceData`.
>
> ```
> summary:        "<course title>"
> startTime:      "<first session>T<HH:MM:SS>"
> endTime:        "<first session>T<HH:MM:SS>"
> timeZone:       "America/New_York"
> location:       "<meetingPlace>" (in-person only)
> description:    "https://roberthouton.com/course/<slug>"
> recurrenceData: ["RRULE:FREQ=WEEKLY;COUNT=<n>"]
> ```

### Subagent 4 — cv.json

> Update `src/content/academic/cv.json` in the roberthowtondotcom repo at `/Users/rfh/dev/roberthowtondotcom`.
>
> In the `courses` array, insert at the top (reverse-chronological):
> ```json
> {
>   "term": "<term>",
>   "title": "<title>",
>   "institution": "Brooklyn Institute for Social Research",
>   "url": "/course/<slug>",
>   "previewTerm": "<abbreviated term>"
> }
> ```
>
> Do not add `current`/`upcoming` fields — the homepage derives "Current"/"Upcoming" placement automatically from the course's own `details.dates` (falling back to `term` only for entries with no local `/course/<slug>` page), via `src/lib/courseUtils.ts`. No manual audit step needed.

---

## Step 4: Create `index.mdx`

Once subagents 1 and 2 have returned `orgId` and `filename`, create `src/content/course/<slug>/index.mdx`:

**In-person** (`isOnline: false`):
```mdx
---
title: "<title>"
term: "<term>"
institution: "Brooklyn Institute for Social Research"
visible: true
hideLoginLink: true
isOnline: false
orgId: <orgId>
url: "<bisr-url>"
showSyllabusIntroText: true
image:
  src: "./assets/<filename>"
  alt: "<imageAlt>"
details:
  dates: "<dates or 'TBA'>"
  meetingTimes: "<meetingTimes or 'TBA'>"
  meetingPlace: "<meetingPlace or 'TBA'>"
  meetingPlaceUrl: <meetingPlaceUrl or 'https://thebrooklyninstitute.com'>
  googleMapsUrl: "<googleMapsUrl or 'https://www.google.com/maps'>"
---

<course description paragraphs>
```

**Online** (`isOnline: true`):
```mdx
---
title: "<title>"
term: "<term>"
institution: "Brooklyn Institute for Social Research"
visible: true
hideLoginLink: true
isOnline: true
orgId: <orgId>
url: "<bisr-url>"
showSyllabusIntroText: true
image:
  src: "./assets/<filename>"
  alt: "<imageAlt>"
details:
  dates: "<dates or 'TBA'>"
  meetingTimes: "<meetingTimes or 'TBA'>"
---

<course description paragraphs>
```

Notes:
- Omit `meetingLink` if Zoom URL isn't known yet
- Write the full course description as the MDX body — no imports or headings, just the paragraphs from BISR
- All required fields must always be present. Use `"TBA"` for unknown strings, `"https://www.google.com/maps"` for unknown `googleMapsUrl`, and `"https://thebrooklyninstitute.com"` for unknown `meetingPlaceUrl` — never omit required fields even when data is unavailable

## Step 4b: Role defaults + permission (manual — blocking)

Neither of these can be automated via WorkOS API/MCP tools — no `update_role` tool exists, and `update_organization`'s `default_role` param is a confirmed no-op. Do not skip or downgrade this to a mention in the final report. After Phase A completes, use `AskUserQuestion` to block until the user confirms they've done it. Give them these exact steps in the dashboard (Production env, org from Step 1's `orgId`):

1. Organizations → `<orgId>` → Roles → `<Keyword> Students` (`org-<keyword>`) → `...` menu → Set as organization default
2. Authorization → Permissions → Create permission: name `View <Title> Class`, slug `class:<keyword>:view`
3. Organizations → `<orgId>` → Roles → `<Keyword> Students` (`org-<keyword>`) → attach the `class:<keyword>:view` permission

This mirrors the pattern already used by other course roles (e.g. `class:kripke:view`, `class:color:view`). Options for the question: "Done" / "Skip for now". If skipped, still proceed to Step 5 but flag it as outstanding.

## Step 5: Confirm

Report:
- Files created: image path, MDX path
- WorkOS org ID and role slug
- Calendar events created
- `cv.json` updated
- Step 4b (org default role + permission): done, or flagged outstanding if skipped
- To add readings: `pnpm upload-readings upload <slug> <localDir>` (Vercel Blob private store), then add `filename:` entries to lecture frontmatter
- When enrollment opens: set `hideLoginLink: false`
- If online: add `meetingLink` to frontmatter when Zoom URL is available
