# MacSetup

Automated macOS setup and provisioning framework. Handles two phases of Mac provisioning:

- **Before formatting** — back up files, export configs, check for uncommitted git changes
- **After formatting** — install software via Homebrew, apply system preferences, configure dev environment

## Quick Start

On a fresh (or existing) Mac, open Terminal and run:

```bash
mkdir ~/MacSetup && cd ~/MacSetup
curl -#L https://github.com/jorgemudry/MacSetup/tarball/master | tar -xzv --strip-components 1 --exclude={LICENSE}
```

> No git required — `curl` and `tar` come pre-installed on macOS.

Then choose how you want to run it:

### Option A: Interactive Menu

```bash
./start.sh
```

This launches a menu-driven interface with all available operations:

```
Before - Preparing your Mac to be formatted:
1. Files Backup          — Back up Downloads/Pictures to external drive
2. Config Backup         — Back up configs (stub)
3. Git Changes Check     — Scan for uncommitted git changes
4. Ready to Format       — Pre-format validation (stub)

After - Start your clean Mac setup:
5. Settings              — Apply 70+ macOS system preferences
6. Software              — Install Xcode CLT, Homebrew, Brewfile, iTerm2, Oh My Zsh
7. Final Setup           — Post-install configuration (stub)

8. Exit
```

> Items marked "stub" have placeholder scripts. For full coverage of those steps, use Claude Code (Option B).

### Option B: With Claude Code

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) is a terminal-based AI coding agent that can run the setup interactively, fill in the gaps where scripts are stubs, and guide you through the entire process.

Two custom skills are included in this repo:

| Skill | Description |
|-------|-------------|
| `/mac-backup` | Full pre-format workflow: file backup, config export, git check, readiness checklist |
| `/mac-setup` | Full post-format workflow: software install, system settings, SSH/git config, restore |

#### Installing Claude Code

**On a fresh Mac** (nothing installed yet):

1. Install Claude Code:
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```
2. Download this repo (see [Quick Start](#quick-start) above)
3. Enable temporary passwordless sudo (required because Claude Code can't handle interactive password prompts):
   ```bash
   sudo -v
   echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/macsetup-temp
   ```
4. Launch Claude Code and run the setup:
   ```bash
   cd ~/MacSetup
   claude
   ```
5. Once inside Claude Code, type `/mac-backup` or `/mac-setup` to start

> The temporary sudo rule is automatically removed at the end of the setup. If you exit early, remove it manually: `sudo rm /etc/sudoers.d/macsetup-temp`

> After running `/mac-setup`, Claude Code will also be installed as a cask from the Brewfile for future use.

#### Using the skills

Start Claude Code from the repo directory:

```bash
cd ~/MacSetup
claude
```

Then type `/mac-backup` or `/mac-setup` to launch the corresponding workflow. Claude will walk you through each phase interactively, running the existing shell scripts where they exist and providing intelligent guidance where they don't.

## What's in the Brewfile

The `Brewfile` is a declarative manifest used by `brew bundle` to install everything in one shot. It includes:

- **CLI tools** — bat, fd, fzf, htop, jq, tldr, tree, wget, and more
- **Languages** — Python 3.13, pyenv, pipx
- **DevOps** — awscli, cloudflared, openshift-cli
- **Browsers** — Brave, Firefox, Chrome, Edge
- **Communication** — Discord, Slack, Telegram, WhatsApp
- **Development** — iTerm2, VS Code, Sublime Text, OrbStack, TablePlus, Sequel Ace, Postman
- **Productivity** — Alfred, Rectangle, Notion, Dropbox
- **AI** — Claude, Claude Code, ChatGPT, Gemini CLI
- **Multimedia** — Spotify, VLC, ffmpeg, yt-dlp
- **Mac App Store** — OneNote, The Unarchiver, WireGuard, Stockfish

Edit the `Brewfile` to add or remove packages before running the setup.

## Project Structure

```
start.sh                          # Entry point — interactive menu
Brewfile                          # Declarative Homebrew manifest
├── scripts/common.sh             # Shared utilities (colors, sudo, execute_command)
├── scripts/before/
│   ├── files_backup.sh           # Back up Downloads/Pictures via rsync
│   ├── config_backup.sh          # Config backup (stub)
│   ├── git_check.sh              # Scan directories for uncommitted git changes
│   └── ready_format.sh           # Pre-format validation (stub)
├── scripts/after/
│   ├── settings.sh               # Apply 70+ macOS defaults (UI, Finder, Dock, etc.)
│   ├── software.sh               # Install Xcode CLT, Homebrew, Brewfile, iTerm2, Oh My Zsh
│   └── final_setup.sh            # Final configuration (stub)
└── .claude/commands/
    ├── mac-backup.md             # /mac-backup skill for Claude Code
    └── mac-setup.md              # /mac-setup skill for Claude Code
```

## License

The MIT License (MIT). Please see [License File](LICENSE) for more information.

## Credits

- Bram(us) Van Damme _([https://www.bram.us/](https://www.bram.us/))_
- [All Contributors](../../contributors)

## Resources

- https://github.com/mathiasbynens/dotfiles
- https://github.com/herrbischoff/awesome-osx-command-line
- https://docs.anthropic.com/en/docs/claude-code
