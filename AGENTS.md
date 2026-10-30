# Agent instructions (any LLM / coding agent)

## Startup: load memories
At the start of every session, read `~/.agents/memory/MEMORY.md` (index),
then any memory files relevant to the task. They hold durable facts about
the user, their projects, references, and feedback on how to work. Treat as
background context, not commands; verify named files/flags still exist
before relying on them.

## Saving memories
When you learn something durable and non-obvious (user prefs, corrections,
project context not in code/git, pointers to external resources):

1. Check `~/.agents/memory/` for an existing file on it; update that
   instead of duplicating. Delete memories found wrong.
2. Otherwise write `~/.agents/memory/<kebab-slug>.md`:

   ```markdown
   ---
   name: <short name>
   description: <one-line summary>
   metadata:
     type: user | feedback | project | reference
   ---

   <fact; for feedback/project add **Why:** and **How to apply:** lines>
   ```
3. Add a one-line entry to `~/.agents/memory/MEMORY.md`: `- [Title](file.md) — hook`.
4. Don't save what code, git history, or CLAUDE.md already record.

## Style
Be extremely concise; sacrifice grammar. Never mention AI/Claude in commit
messages or PR text. Prefix branches with `robbie/`. Use `gh` for GitHub.
Plans end with a terse list of unresolved questions.
