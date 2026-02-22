---
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Mac Setup — Post-Format Configuration

You are guiding the user through setting up a freshly formatted Mac. Work through each phase interactively, confirming with the user before proceeding to the next.

**Important**: Several steps require `sudo`. Before running any scripts, verify passwordless sudo is available:

```bash
sudo -n true 2>/dev/null && echo "sudo OK" || echo "sudo NOT active"
```

If sudo is NOT active, tell the user:
> "This setup requires passwordless sudo. Please exit Claude Code and run these commands in your terminal:
> ```
> sudo -v
> echo \"$(whoami) ALL=(ALL) NOPASSWD: ALL\" | sudo tee /etc/sudoers.d/macsetup-temp
> ```
> Then start Claude Code again and re-run `/mac-setup`. The temporary sudo rule will be removed at the end of the setup."

Do NOT proceed until `sudo -n true` succeeds.

All scripts must be called with `MACSETUP_NONINTERACTIVE=true` so they skip interactive prompts (password, press-any-key, reboot) that would hang in Claude Code.

## Phase 1: Software Installation

This phase uses the existing `scripts/after/software.sh` script which installs Xcode CLT, Homebrew, Brewfile packages, iTerm2 config, and Oh My Zsh.

Run the software installation:

```bash
cd <repo-root> && MACSETUP_MAIN=true MACSETUP_NONINTERACTIVE=true bash scripts/after/software.sh
```

Where `<repo-root>` is the root of this MacSetup repository. The script will:
1. Install Xcode Command Line Tools (if not present)
2. Install Homebrew (if not present)
3. Run `brew update` and `brew cleanup`
4. Run `brew doctor` to verify health
5. Install all packages from the `Brewfile` via `brew bundle`
6. Configure iTerm2 defaults (quit prompt, fullscreen, hotkey)
7. Install Oh My Zsh (if not present)

Monitor the output and report any failures to the user. If `brew bundle` fails on specific packages, offer to retry them individually.

## Phase 2: System Settings

This phase uses the existing `scripts/after/settings.sh` script which applies 70+ macOS defaults.

Before running, inform the user this will:
- Set computer name and hostname (the script will prompt for these)
- Configure UI/UX preferences (scrollbars, save panels, smart quotes off, etc.)
- Configure Touch Bar, trackpad, keyboard, and mouse settings
- Set up screen saver and screenshot preferences
- Configure Finder (list view, show extensions, show path bar, etc.)
- Configure Dock (auto-hide, icon size 36px, remove default icons, hot corners)
- Configure Activity Monitor, App Store, and other app settings
- Kill affected applications to apply changes (Dock, Finder, etc.)
- Prompt for a reboot at the end

Run the settings script:

```bash
cd <repo-root> && MACSETUP_MAIN=true MACSETUP_NONINTERACTIVE=true bash scripts/after/settings.sh
```

Where `<repo-root>` is the root of this MacSetup repository.

**Note**: This script requires interactive input for the computer name and Apple ID. Before running it, ask the user what computer name and Apple ID they want, then set them directly via `scutil` and `defaults write` commands instead of relying on the script's interactive prompts.

## Phase 3: Final Setup — Dropbox & Config Restore

This phase uses `scripts/after/final_setup.sh`. It requires the user to set up Dropbox first (OAuth + 2FA cannot be automated).

Tell the user:
> "Please open Dropbox, sign in, and wait for sync to complete. The script will detect when your config files are ready and continue automatically."

Then run the final setup script:

```bash
cd <repo-root> && MACSETUP_MAIN=true MACSETUP_NONINTERACTIVE=true bash scripts/after/final_setup.sh
```

Where `<repo-root>` is the root of this MacSetup repository. The script will:
1. Wait for `~/Dropbox/Mackup` and `~/Dropbox/Config` directories to appear
2. Create symlinks from the home directory to Dropbox-synced configs (`.gitconfig`, `.zshrc`, `.ssh`, `.aws`, etc.)
3. Create symlinks for Claude Code config (`~/.claude/CLAUDE.md`, `settings.json`, `agents`)
4. Create symlinks for Oh My Zsh custom files (aliases, functions, plugins)
5. Fix SSH key permissions (700 for `~/.ssh`, 600 for private keys, 644 for public keys)

**Note**: Git configuration and SSH keys are restored from Dropbox — no manual generation needed.

### Additional Post-Install Tasks
After the script completes, ask the user if they need any of these:
- **Python setup**: Verify pyenv or Homebrew python is working, set up virtual environments
- **Docker setup**: Verify OrbStack is running if installed via Brewfile
- **VS Code / Cursor extensions**: Restore extensions from a list if they have one
- **Terminal theme**: Import iTerm2 color scheme or configure terminal preferences

## Post-Setup Cleanup

Remove the temporary passwordless sudo rule that was created before launching Claude Code:

```bash
sudo rm -f /etc/sudoers.d/macsetup-temp
```

Verify it was removed:

```bash
sudo -n true 2>/dev/null && echo "WARNING: sudo still passwordless" || echo "sudo rule removed OK"
```

## Post-Setup Summary

After all phases are complete, provide a summary:
- Software installation status (any failed packages)
- System settings applied
- Dropbox symlinks created (yes/no)
- SSH permissions fixed (yes/no)
- Temporary sudo rule removed (yes/no)
- Any remaining manual steps the user should do (e.g., sign in to apps, configure IDE)
