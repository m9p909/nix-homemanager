# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Home-manager configuration for user "jack" using Nix flakes. Manages packages, programs, and dotfiles declaratively. Supports local, Docker, and Kubernetes deployment.

## Commands

```bash
# Apply configuration locally
home-manager switch --flake ~/.config/home-manager#jack

# Shortcut (defined alias)
update

# Build without applying (check for errors)
home-manager build --flake ~/.config/home-manager#jack

# Format nix files
nixfmt *.nix

# Docker local dev
docker-compose build
docker-compose up -d
ssh -p 2222 jack@localhost  # password: dev

# Kubernetes deployment
kubectl apply -f k8s/
```

## Architecture

```
flake.nix           # Nix flake entry point, declares nixpkgs + home-manager inputs
home.nix            # Main config: packages, programs, shell aliases, env vars
config/
  nvim/
    init.lua        # Kickstart.nvim base config
    lua/custom/plugins/  # Custom plugins (avante, claude_code, copilot)
  CLAUDE.md         # AI coding standards (used by Avante)
k8s/                # Kubernetes manifests for cloud deployment
Dockerfile          # Debian + Nix container image
docker-compose.yml  # Local container dev setup
```

## Key Patterns

- **Declarative packages**: All tools declared in `home.nix` under `home.packages`
- **Program configs**: Programs like git, zsh, neovim configured in `programs.*` blocks
- **Environment variables**: Sourced from `.env` file in zsh `initContent`
- **Neovim plugins**: Lazy-loaded via Lazy.nvim, custom plugins in `lua/custom/plugins/`
- **AI integration**: Avante plugin uses OpenRouter with Claude Sonnet 4.5

## Nix Tips

- `home.packages` for installing tools
- `programs.<name>.enable = true` for programs with configuration
- State version in `home.stateVersion` - don't change after initial setup
- Run `nix flake update` to update dependencies
