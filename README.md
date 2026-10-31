# .files

## Instructions

### Install from Brewfile

1. Ensure `brew` is installed

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. `cd` to `brewfiles/personal` or `brewfiles/work`

3. Install from `Brewfile`

```shell
brew bundle
```

### Install dotfiles

1. Ensure `stow` is installed.

```shell
brew install stow
```

2. Clone repo to `~/dotfiles`

3. Run `stow`

```shell
cd ~/dotfiles
stow .
```

## LLM memory

Shared by all agents; stow links `.agents/` -> `~/.agents`.

- `AGENTS.md` -> `~/AGENTS.md`: startup + save instructions for any agent.
- `.agents/memory/`: memory files + `MEMORY.md` index. Edit in place.
- Claude Code reads the same dir via `autoMemoryDirectory` in
  `~/dev/.claude/settings.json` (project-scoped to `~/dev`, not in this repo).
  Other projects keep their own default memory.
- `CLAUDE.md` (repo root) is ignored by stow.

## Skills

Personal skills live in `.agents/skills/<name>/SKILL.md` (generic agent format;
stow links `.agents/` -> `~/.agents`). Claude Code reads `~/.claude/skills`, so
`.claude/skills/<name>` are relative symlinks into `.agents/skills`. Add a skill:
create the dir under `.agents/skills`, add a matching link under `.claude/skills`,
run `stow .`. Skill scripts are referenced by absolute `~/.agents/skills/...`
paths in permission allowlists (`~/dev/.claude/settings*.json`).
