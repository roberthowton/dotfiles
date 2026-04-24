- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## cmux

cmux is a terminal multiplexer with a browser API, available at `/Applications/cmux.app/Contents/Resources/bin/cmux`.

When a task involves inspecting or interacting with a web UI (checking styles, verifying layout, clicking elements, taking snapshots), check if cmux is available and use it proactively. Do not wait to be asked.

### Workflow

1. Detect environment: `cmux ping` — if it fails, cmux isn't available; fall back to other methods.
2. Find the browser surface: `cmux list-pane-surfaces` (and `cmux list-pane-surfaces --pane <id>` for other panes) — look for a surface with a page title.
3. All browser commands require `--surface <id>`:
   - Navigate: `cmux browser --surface <id> goto "<url>"`
   - Wait: `cmux browser --surface <id> wait --load-state complete`
   - Snapshot (semantic tree): `cmux browser --surface <id> snapshot --compact [--selector "<css>"]`
   - Click: `cmux browser --surface <id> click "<selector>"`
   - Eval JS: `cmux browser --surface <id> eval "<script>"`
   - Get styles: `cmux browser --surface <id> get styles "<selector>" "<prop1,prop2>"`
   - Get box: `cmux browser --surface <id> get box "<selector>"`
4. Iterate: snapshot → identify issues → edit code → reload → snapshot again.

## PR Comments

<pr-comment-rule>
When I say to add a comment to a PR with a TODO on it, use the checkbox markdown format to add the TODO. For instance:
<example>
- [ ] A description of the TODO goes here
</example>
</pr-comment-rule>

## Commit messages and Github PR descriptions and Issues

- Never include a reference to Claude code or the fact that the change in question was created with the assistance of Claude or AI. I pay for this service, and I do not consent to you using my work to advertise it.

## Github

- Your primary method for interacting with Github should be the Github CLI

## Git

- When creating branches, prefix them with "robbie/" to indicate that they're mine.

## Plans

- At the end of each plan, give me a list of unresolved questions, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.

- If I tell you to store this plan in an issue, what I mean is this: make a Github issue containing the current plan, including all of the items you checked off the plan list. Add anything to that plan that will help Claude resume the plan by reading the Github issue from a fresh context window.
