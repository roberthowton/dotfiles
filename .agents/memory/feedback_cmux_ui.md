---
name: Use cmux for UI tasks
description: When checking or interacting with web UIs, proactively use cmux browser API without being asked
type: feedback
---

Always check for cmux when a UI task arises (inspecting layout, verifying styles, clicking elements). Do not wait for the user to mention it.

**Why:** User had to prompt me multiple times to use cmux instead of reaching for playwright or screencapture. cmux is their primary environment and has a full browser API.

**How to apply:** On any UI-related task, run `cmux ping` first. If available, find the browser surface with `cmux list-pane-surfaces` and use `cmux browser --surface <id> ...` for navigation, snapshots, and interaction. See CLAUDE.md for full workflow.
