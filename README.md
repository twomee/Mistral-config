# Vibe Config

Portable configuration for [Mistral Vibe](https://docs.mistral.ai/vibe/code/overview) —
skills, rules, prompts, hooks, and settings. The `~/.vibe` directory is itself a
git repo; portable config is tracked while secrets and ephemeral state are
gitignored.

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

### New machine (restore)

```bash
git clone <repo-url> ~/.vibe
mkdir -p ~/.vibe/logs
# Recreate your API keys manually:
echo "MISTRAL_API_KEY=..." > ~/.vibe/.env
chmod 600 ~/.vibe/.env
```

Then run `vibe` and `/reload` if a session is already open.

### Save changes (backup)

```bash
~/.vibe/install.sh backup
```

Stages, commits, and pushes all config changes to the remote.

### Check what changed (status)

```bash
~/.vibe/install.sh status
```

## First-time setup on this machine

```bash
cd ~/.vibe
git remote add origin git@github.com:<you>/Vibe-Config.git
~/.vibe/install.sh backup
```
