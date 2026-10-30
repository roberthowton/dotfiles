---
name: WorkOS course access system
description: How roberthowtondotcom uses WorkOS to gate access to philosophy course pages — orgs, roles, permissions, auth flow, enrollment
type: project
originSessionId: 2619fa83-31b5-4c80-afae-4440f3e49ff9
---
## Overview

`roberthowtondotcom` (Astro + Vercel) is the personal/teaching site of Robbie Howton, a philosophy instructor at the Brooklyn Institute for Social Research (BISR). Course pages contain syllabi, lecture materials, and meeting links that should only be accessible to enrolled students. WorkOS AuthKit manages all of this.

## Course content structure

Courses live in `src/content/course/<slug>/index.mdx`. Each course's frontmatter includes:

```yaml
orgId: org_01KFRG0AMYQ3Z2T8HBVDQXQEME   # WorkOS org ID — the key field
visible: true                             # Whether it appears in listings
title: "Aristotle's Metaphysics"
term: "February 2026"
institution: "Brooklyn Institute for Social Research"
```

Courses without an `orgId` or with `visible: false` are hidden/archived (e.g. Heraclitus, Leibniz, Aristotle and the Left).

## WorkOS data model

### One org per course

Each course gets its own WorkOS **Organization**. Org names mirror course titles exactly:

| Course slug | Org ID | Org name |
|---|---|---|
| `aristotle-metaphysics` | `org_01KFRG0AMYQ3Z2T8HBVDQXQEME` | Aristotle's Metaphysics |
| `color` | `org_01K9MY7G2EGXXSHMMDARE33EJR` | The Philosophy of Color |
| `anscombe` | `org_01K6ZMADPF1ANWKP44Z45XQ2AZ` | Elizabeth Anscombe: Philosophy, Intention, and Morality |
| `nicomachean-ethics` | `org_01JWBYRXSEE328AVFQW42R7857` | Aristotle: Nicomachean Ethics |
| `teleology` | `org_01JMDQ3NCA2VB50RS5B03ZFVXB` | Own Goal: an Introduction to Teleology |
| `kripke` | `org_01JJ81SGRSRHW3T8016A71ZXYF` | Saul Kripke: Naming and Necessity |

### Roles and permissions

Each org has a **custom role** with a slug matching the course:
- `org-aristotle-metaphysics`
- `org-kripke`
- etc.

Each role carries a WorkOS permission: `class:<slug>:view` (e.g. `class:kripke:view`). This permission is what the application actually checks. Enrolling a student = creating an org membership with that role, which puts the permission in their session token.

### Users

All students share a single global user pool — a user enrolled in multiple courses across years has one account. ~100+ users total. Some users appear across multiple course orgs (returning students).

Notable accounts:
- `info@thebrooklyninstitute.com` — BISR admin account (unverified, never signed in)
- A handful of users with unverified emails who never completed signup

## Authentication flow

### Environment variables required

```
WORKOS_API_KEY         # Production: sk_... (not sk_test_...)
WORKOS_CLIENT_ID       # Production: client_01JHDH2C74YA291GF4ER92G67J
WORKOS_COOKIE_PASSWORD # 32+ char secret for sealing session cookies
```

Staging credentials (sk_test_...) exist but have no orgs/students. Always use prod for real course management.

### Login (`src/pages/login.astro`)

1. Reads `?class=<slug>` query param
2. Looks up the course entry to get its `orgId`
3. Calls `workos.userManagement.getAuthorizationUrl()` with `provider: "authkit"`, the `orgId` (if present), and `state: classId`
4. Redirects user to AuthKit hosted UI

### Callback (`src/pages/api/callback.astro`)

1. Exchanges the auth `code` for a session via `authenticateWithCode`
2. If a `classId` came back in `state`, refreshes the session with `{ organizationId: orgId }` to embed org context (and therefore the `class:X:view` permission) into the sealed cookie
3. Sets `wos-session` cookie (httpOnly, secure, sameSite: lax)
4. Redirects to `/course/<classId>/syllabus` or `/`

### Middleware (`src/middleware.ts`)

Three middleware layers run in sequence:

**1. `devAuthBypass`** — In dev (without `REQUIRE_AUTH=true`), skips all auth and redirects login/callback directly to the course or home.

**2. `withAuthKit`** — The main WorkOS guard. For any route matching `/course/*/...` or `/user/*`:
- Loads the sealed session from the `wos-session` cookie
- For `/user/*` routes: just checks authenticated, no org context needed
- For course routes: calls `getIsAuthenticatedStudent(cookies, classId)` which checks `session.permissions.includes('class:<classId>:view')`
- If authenticated but wrong org (e.g. user has a session for a different course): tries `session.refresh({ organizationId: orgId })` to switch context — handles multi-course students seamlessly
- On failure: deletes cookies and redirects to `/login?class=<classId>`
- On expired session: attempts `session.refresh()` and updates cookie, then redirects to reload with fresh cookie

**3. `authenticateCourseUsers`** — Legacy basic auth fallback for course/lecture pages. Uses `COURSE_USERNAME`/`COURSE_PASSWORD` env vars. Runs only in production. This predates WorkOS and may be unused in practice.

### Session helpers (`src/utils/workos.ts`)

- `getSession(cookies)` — loads and authenticates sealed session, returns auth response or null
- `getUser(cookies)` — returns the WorkOS User object or null
- `getIsAuthenticated(cookies)` — boolean
- `getLogoutUrl(cookies)` — generates WorkOS logout URL for the current session

### Student detection (`src/utils/index.ts`)

```ts
export const getIsAuthenticatedStudent = async (cookies, classId) => {
  const isAuthenticated = await getIsAuthenticated(cookies);
  const session = await getSession(cookies);
  const isStudent = session?.permissions?.includes(`class:${classId}:view`);
  return isAuthenticated && isStudent;
};
```

The key check is the permission string. If the session doesn't have `class:<slug>:view`, the user is not admitted even if they're authenticated.

### Protected routes

`isUnprotectedRoute` returns true for anything that does NOT match `/course/*/...` (i.e., one level deep is fine — `/course/kripke` is public) or `/user/*`. So course index pages are public; individual course sub-pages (syllabus, lectures, etc.) require auth.

## Account page (`src/pages/user/account.astro`)

Shows the user their enrolled courses. Uses `getUserCourses(userId)` which:
1. Lists all org memberships for the user via `workos.userManagement.listOrganizationMemberships({ userId })`
2. Gets all course content entries
3. Returns courses whose `orgId` is in the user's org membership set and `visible !== false`

This means a student's account page automatically shows all courses they've ever been enrolled in across all terms.

## Enrollment workflow (current, manual)

At course launch:
1. Create a WorkOS Organization named after the course
2. Create a custom role with slug `org-<course-slug>` and attach permission `class:<course-slug>:view`
3. Add the org's ID to the course MDX frontmatter as `orgId`
4. For each enrolled student: create a WorkOS user (or find existing), create an org membership with the course role
5. Students receive an email to set their password and can then log in

No automated enrollment — it's all done manually via the WorkOS dashboard or (now) via Claude with the WorkOS MCP.

## Env file note

The `.env` file in `roberthowtondotcom` uses staging credentials (`sk_test_...`). The WorkOS MCP is configured with production credentials. When updating `.env` for local dev with real data, use the production key (`sk_a2...`). The `dev:auth` npm script (`REQUIRE_AUTH=true astro dev`) runs the site with auth enabled locally.
