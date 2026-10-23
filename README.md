# Vibe Config

Portable configuration for [Mistral Vibe](https://docs.mistral.ai/vibe/code/overview) —
skills, rules, prompts, hooks, and settings. The `~/.vibe` directory is itself a
git repo; portable config is tracked while secrets and ephemeral state are
gitignored. There is no separate backup archive to restore **from** — the repo
itself **is** the config folder. Restoring means cloning it to the exact
location Vibe reads.

## What's backed up

| Path | Contents |
|---|---|
| `AGENTS.md` | Global rules (ported from Claude's `CLAUDE.md` + `rules/`) |
| `skills/` | 14 user skills + `skill-rules.json` |
| `prompts/` | Slash-command prompts (`/dev-docs`, `/dev-docs-update`) |
| `hooks.toml` | Hook definitions (post-tool-use tracker) |
| `hooks/` | Hook scripts |
| `config.toml` | Settings (models, themes, tool allowlists) |

**Never backed up:** `.env` (API keys), `logs/`, session history, caches,
`trusted_folders.toml`.

## Quick Start

### New machine — Vibe not installed yet (restore, Scenario A)

```bash
git clone https://github.com/twomee/Mistral-config.git ~/.vibe
mkdir -p ~/.vibe/logs
```

The clone writes every file directly where Vibe expects it
(`~/.vibe/AGENTS.md`, `~/.vibe/skills/...`, `~/.vibe/hooks.toml`, ...).
Nothing is moved or copied by hand. Then recreate your API key (never stored
in the repo):

```bash
echo "MISTRAL_API_KEY=your-key" > ~/.vibe/.env
chmod 600 ~/.vibe/.env
```

Install Vibe (`uv tool install mistral-vibe`), run `vibe`, done.

### Machine where Vibe already ran (restore, Scenario B)

If `~/.vibe` already exists (Vibe creates it with logs/caches on first run),
overlay the backup onto it:

```bash
git clone https://github.com/twomee/Mistral-config.git ~/vibe-config-restore
cp -rT ~/vibe-config-restore ~/.vibe
rm -rf ~/vibe-config-restore
```

Then recreate `~/.vibe/.env` as above.

### Save changes (backup)

```bash
~/.vibe/install.sh backup
```

Stages, commits, and pushes all config changes to the remote.

### Check what changed (status)

```bash
~/.vibe/install.sh status
```

## First-time setup on a new machine's clone

The remote is already set. If you ever clone from scratch elsewhere:

```bash
git -C ~/.vibe remote add origin https://github.com/twomee/Mistral-config.git
~/.vibe/install.sh backup
```

