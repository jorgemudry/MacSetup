# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MacSetup is a macOS automated setup and provisioning framework. It automates preparing a Mac before formatting (backups, git status checks) and setting up a fresh Mac after formatting (system preferences, software installation via Homebrew).

## Running

```bash
./start.sh    # Interactive menu-driven interface
```

No build step — all scripts are interpreted bash/zsh. The entry point `start.sh` presents a menu with two phases:

- **Before formatting**: file backups, config backups, git uncommitted change detection
- **After formatting**: macOS system preferences, Homebrew software installation, final setup

## Architecture

```
start.sh                          # Entry point / interactive menu
├── scripts/common.sh             # Shared utilities (colors, sudo handling, execute_command)
├── scripts/before/
│   ├── files_backup.sh           # Backup Downloads/Pictures to USB/external drive
│   ├── config_backup.sh          # Config backup (stub)
│   ├── git_check.sh              # Recursively scan dirs for uncommitted git changes
│   └── ready_format.sh           # Pre-format validation (stub)
└── scripts/after/
    ├── settings.sh               # Apply 70+ macOS defaults (UI, Finder, Dock, trackpad, etc.)
    ├── software.sh               # Install Xcode CLT, Homebrew, Brewfile bundle, iTerm, oh-my-zsh
    └── final_setup.sh            # Final configuration (stub)
```

All scripts source `common.sh` for shared functions: `check_sudo()`, `execute_command()`, `press_any_key()`, `askforreboot()`, `checksudoandprompt()`.

The `Brewfile` at the root is a declarative Homebrew manifest (taps, formulas, casks, Mac App Store apps) consumed by `brew bundle` in `software.sh`.

Scripts marked as "stub" contain only placeholder structure and are intended for future implementation.

## Conventions

- All scripts use bash (`#!/usr/bin/env bash`)
- Color output via ANSI codes defined in `common.sh` (RED, GREEN, YELLOW, BLUE)
- Commands are wrapped in `execute_command()` which provides status feedback (success/fail indicators)
- Scripts are idempotent — they detect existing installations and skip if already done
