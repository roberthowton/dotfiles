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
> 3. Set it as the default using `mcp__workos__update_organization`:
>    - `organization_id`: <orgId>
>    - `default_role`: `{ "slug": "org-<keyword>" }`
>
> Return the `orgId`.

### Subagent 2 — Assets

> Download the course image and create the readings directory for a new course in the roberthowtondotcom repo at `/Users/rfh/dev/roberthowtondotcom`.
>
> 1. `mkdir -p src/content/course/<slug>/assets`
> 2. `curl -L "<imageUrl>" -o "src/content/course/<slug>/assets/<filename>"`
>    - Derive `<filename>` from the URL basename; use a short kebab-case name if it's generic.
> 3. `mkdir -p src/content/readings/<slug>`
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
> In the `courses` array:
>
> 1. Insert at the top (reverse-chronological):
> ```json
> {
>   "term": "<term>",
>   "title": "<title>",
>   "institution": "Brooklyn Institute for Social Research",
>   "url": "/course/<slug>",
>   "upcoming": true,
>   "previewTerm": "<abbreviated term>"
> }
> ```
>
> 2. Audit `current` and `upcoming` flags on existing BISR entries using today's date (<today's date>):
>    - `current`: true only if the course is actively running now
>    - `upcoming`: true only if the start date is in the future
>    - Otherwise remove or set to false

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
  dates: "<dates>"
  meetingTimes: "<meetingTimes>"
  meetingPlace: "<meetingPlace>"
  meetingPlaceUrl: <meetingPlaceUrl>
  googleMapsUrl: "<googleMapsUrl>"
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
  dates: "<dates>"
  meetingTimes: "<meetingTimes>"
---

<course description paragraphs>
```

Notes:
- Omit `meetingLink` if Zoom URL isn't known yet
- Write the full course description as the MDX body — no imports or headings, just the paragraphs from BISR

## Step 5: Confirm

Report:
- Files created: image path, readings dir, MDX path
- WorkOS org ID and role slug
- Calendar events created
- `cv.json` updated
- When enrollment opens: set `hideLoginLink: false`
- If online: add `meetingLink` to frontmatter when Zoom URL is available
