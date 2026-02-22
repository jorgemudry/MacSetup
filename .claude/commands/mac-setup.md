---
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Mac Setup — Post-Format Configuration

You are guiding the user through setting up a freshly formatted Mac. Work through each phase interactively, confirming with the user before proceeding to the next.

**Important**: Several steps require `sudo`. Ask the user for authentication upfront:
```bash
sudo -v
```

## Phase 1: Software Installation

This phase uses the existing `scripts/after/software.sh` script which installs Xcode CLT, Homebrew, Brewfile packages, iTerm2 config, and Oh My Zsh.

Run the software installation:

```bash
cd <repo-root> && MACSETUP_MAIN=true bash scripts/after/software.sh
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
cd <repo-root> && MACSETUP_MAIN=true bash scripts/after/settings.sh
```

Where `<repo-root>` is the root of this MacSetup repository.

**Note**: This script requires interactive input for the computer name and Apple ID. Let the user interact with those prompts directly.

## Phase 3: Final Setup

The script `scripts/after/final_setup.sh` is a stub. Instead, perform these post-install tasks interactively:

### SSH Key Generation
If `~/.ssh/id_ed25519` does not exist, offer to generate a new SSH key:
```bash
ssh-keygen -t ed25519 -C "<user-email>"
```
Then add it to the ssh-agent:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```
Offer to display the public key so the user can add it to GitHub/GitLab:
```bash
cat ~/.ssh/id_ed25519.pub
```

### Git Global Configuration
Ask the user for their name and email, then configure git:
```bash
git config --global user.name "<name>"
git config --global user.email "<email>"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor "vim"
```
Ask if they want any additional git config (e.g., GPG signing, aliases).

### Restore Configs via Mackup
If `mackup` is installed (from the Brewfile), offer to restore backed-up configs:
```bash
mackup restore
```

### Restore Dotfiles
If the user has a backup from `/mac-backup`, offer to restore dotfiles:
- `~/.zshrc`
- `~/.gitconfig`
- `~/.ssh/`
- Any others they backed up

Ask the user for the backup location and use rsync to restore.

### Additional Post-Install Tasks
Ask the user if they need any of these:
- **Node.js setup**: Install nvm or use the Homebrew-installed node, set up global npm packages
- **Python setup**: Verify pyenv or Homebrew python is working, set up virtual environments
- **Docker setup**: Verify Docker Desktop is running if installed via Brewfile
- **VS Code / Cursor extensions**: Restore extensions from a list if they have one
- **Terminal theme**: Import iTerm2 color scheme or configure terminal preferences
- **Fonts**: Verify Nerd Fonts or other development fonts are installed

## Post-Setup Summary

After all phases are complete, provide a summary:
- Software installation status (any failed packages)
- System settings applied
- SSH key configured (yes/no)
- Git configured (yes/no)
- Any remaining manual steps the user should do (e.g., sign in to apps, set up cloud storage, configure IDE)
