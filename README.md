# home-manager

Declarative home-manager configuration for user `jack` on macOS, driven by Nix flakes. Manages CLI packages, shell, Neovim, git, tmux, and Claude Code commands and skills as code.

## Overview

This repo is the single source of truth for the local development environment. It supports three deployment targets:

- Local macOS (primary use case)
- Docker container for ephemeral dev shells
- Kubernetes StatefulSet exposed over Tailscale for a remote dev box

The flake exposes three identical `homeConfigurations` (`jack`, `jackclarke`, `jack.clarke`) targeting `aarch64-darwin` so any of those usernames can apply it.

## Prerequisites

- Nix installed (multi-user recommended)
- Nix flakes enabled: add `experimental-features = nix-command flakes` to `~/.config/nix/nix.conf`
- `home-manager` available on PATH (the flake pulls it as an input, but the CLI bootstrap requires it once)
- A `~/.env` file sourced by zsh (see [Environment](#environment))

## Quick start

```bash
# Apply the configuration
home-manager switch --flake ~/.config/home-manager#jack

# Shortcut alias (defined in this config, available after first switch)
update
```

The first switch takes a while because Nix builds Neovim plugins and downloads the Scala, Clojure, and Go toolchains.

## Common commands

| Command | Purpose |
| --- | --- |
| `home-manager switch --flake ~/.config/home-manager#jack` | Build and activate the configuration |
| `update` | Alias for `home-manager switch` |
| `home-manager build --flake ~/.config/home-manager#jack` | Build without activating (validates the config) |
| `nixfmt *.nix` | Format Nix files |
| `nix flake update` | Update `flake.lock` to the latest input revisions |

## Repository layout

```
flake.nix              Flake entry point. Declares nixpkgs + home-manager inputs and three homeConfigurations.
flake.lock             Pinned input revisions.
home.nix               Main module: packages, programs, shell, env vars, dotfile links.
CLAUDE.md              Project instructions for Claude Code.
TODO.md                Working notes.
config/
  CLAUDE.md            Global AI coding standards (symlinked to ~/.claude/CLAUDE.md).
  .ideavimrc           IdeaVim config (symlinked to ~/.ideavimrc).
  .tmux.conf           tmux config (symlinked to ~/.tmux.conf).
  claude/
    commands/          Claude Code slash commands (symlinked to ~/.claude/commands).
    skills/            Claude Code skills (symlinked to ~/.claude/skills).
  nvim/                Kickstart.nvim-based config (symlinked to ~/.config/nvim).
  ghostty/             Ghostty terminal config (symlinked to ~/.config/ghostty).
  lazygit/             lazygit config (symlinked to ~/.config/lazygit).
apps/                  Application-specific helpers.
Dockerfile             Debian + Nix image for the container target.
docker-compose.yml     Local container dev setup. Exposes SSH on port 2222.
entrypoint.sh          Container entrypoint that bootstraps home-manager.
k8s/                   Manifests for the Kubernetes deployment.
```

## Environment

zsh sources `~/.env` on startup. Create it before the first switch or the shell prints a warning. Example:

```bash
export GITLAB_TOKEN="..."
export OPENAI_API_KEY="..."
export GOROOT=/Users/jackclarke/.go
export GOPATH=/Users/jackclarke/go
export TF_VAR_environment="production"
. "$HOME/.cargo/env"
```

Do not check `.env` into git.

## Claude Code integration

`home.nix` symlinks the contents of `config/claude/` into `~/.claude/`:

- `config/claude/commands/` becomes `~/.claude/commands/` — slash commands such as `/catchup`, `/investigate`, `/review-loop`, `/stack-branch`
- `config/claude/skills/` becomes `~/.claude/skills/` — skill bundles such as `babashka`, `mc-review-pr`, `technical-writer`, `notification`
- `config/CLAUDE.md` becomes `~/.claude/CLAUDE.md` — global instructions for every Claude Code session

To add a new command or skill, drop it under the matching directory, `git add` it, then run `update`. The Claude Code CLI itself is installed through `programs.claude-code.enable`.

## Neovim

Neovim is enabled via `programs.neovim` with the full Kickstart.nvim config copied to `~/.config/nvim` from `config/nvim/`. Custom plugins live in `config/nvim/lua/custom/plugins/`:

- `avante.lua` — Avante AI assistant, configured to use OpenRouter with Claude Sonnet
- `claude_code.lua` — Claude Code integration
- `copilot.lua` — GitHub Copilot
- `clojure.lua`, `opencode.lua`, `neoconf.lua`, `mkdir.lua` — language and editor helpers

Plugins are lazy-loaded by Lazy.nvim. `gcc` and `gnumake` are installed in `home.nix` so Avante can build its native bits.

## Docker

Use Docker for an isolated copy of the environment without touching the host.

```bash
docker-compose build
docker-compose up -d
ssh -p 2222 jack@localhost   # password: dev
```

The compose file mounts `./.env` read-only into the container and persists home-manager state in a named volume.

## Kubernetes

`k8s/` deploys the same environment as a StatefulSet on a Talos cluster, exposed over Tailscale. See [`k8s/README.md`](k8s/README.md) for the full walkthrough. The short version:

```bash
docker build -t ghcr.io/<user>/home-manager-dev:v1.0 .
docker push ghcr.io/<user>/home-manager-dev:v1.0
kubectl apply -f k8s/
ssh jack@home-manager-dev.<tailnet>.ts.net   # password: dev
```

First boot takes 5-10 minutes while Nix populates the persistent volume.

## Gotchas

- **Flakes only see git-tracked files.** A new file under `config/` will be silently ignored by `update` until you `git add` it. Symptom: you add a new Claude command or skill, run `update`, and it never appears in `~/.claude/`. Fix: `git add <path>` and re-run `update`.
- **`home.stateVersion` is pinned to `25.11`.** Do not change it without reading the home-manager release notes first.
- **`.env` is required.** Without it, zsh prints `could not find .env` on every shell start. `GOROOT` and `GOPATH` are sourced from there, so Go tooling breaks until you create it.
- **`programs.git` overrides global git config.** Username and email are set in `home.nix`; edit there, not in `~/.gitconfig`.
- **Build artefacts.** `result` is a symlink into the Nix store left over from `home-manager build`. Safe to delete.
