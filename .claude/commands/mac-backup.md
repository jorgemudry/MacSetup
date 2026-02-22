---
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Mac Backup — Pre-Format Checklist

You are guiding the user through backing up their Mac before a format/reinstall. Work through each phase interactively, confirming with the user before proceeding to the next.

## Phase 1: File Backup

Help the user back up important files to an external drive or network location.

The existing script at `scripts/before/files_backup.sh` backs up `~/Downloads` and `~/Pictures` via rsync. Ask the user:

1. Where should backups go? (external drive mounted at `/Volumes/...`, network path, or other location)
2. Which directories to back up? The defaults are `~/Downloads` and `~/Pictures`, but offer to include others like `~/Documents`, `~/Desktop`, `~/Music`, `~/Movies`, or any custom paths.

Then run the backup using rsync with progress:

```bash
rsync -avh --progress <source> <destination>/MacBackup_$(date +%Y%m%d_%H%M%S)/
```

List available mounted volumes with `ls /Volumes/` to help the user choose a destination.

## Phase 2: Config Backup

The script `scripts/before/config_backup.sh` is a stub. Instead, perform these config backups interactively:

### Dotfiles
Back up key dotfiles to the chosen backup destination:
- `~/.zshrc`
- `~/.gitconfig`
- `~/.ssh/` (entire directory)
- `~/.gnupg/` (if exists)
- `~/.aws/` (if exists)
- `~/.config/` (if exists)

Use: `rsync -avh <dotfile> <destination>/configs/`

### Homebrew packages
Export the current Homebrew state:
```bash
brew bundle dump --file=<destination>/configs/Brewfile --force
```

### Mac App Store apps
If `mas` is installed, export the app list:
```bash
mas list > <destination>/configs/mas-apps.txt
```

### Mackup
If `mackup` is installed, run:
```bash
mackup backup
```

Ask the user if there are any additional configs or application settings they want to back up.

## Phase 3: Git Uncommitted Changes Check

The existing script at `scripts/before/git_check.sh` scans a directory for repos with uncommitted changes. Ask the user which directories to scan (common choices: `~/Work`, `~/Projects`, `~/Developer`, `~/code`).

For each directory, find git repositories and check for uncommitted changes:

```bash
find <directory> -maxdepth 2 -name ".git" -type d | while read gitdir; do
    repo=$(dirname "$gitdir")
    if [ -n "$(git -C "$repo" status --porcelain)" ]; then
        echo "UNCOMMITTED: $repo"
        git -C "$repo" status --short
    fi
done
```

Present a summary of all repos with uncommitted changes. For each one, ask the user if they want to:
- Commit and push the changes now
- Stash the changes
- Skip (they'll handle it manually)

## Phase 4: Pre-Format Readiness Checklist

The script `scripts/before/ready_format.sh` is a stub. Walk through this checklist with the user, confirming each item:

- [ ] All important files backed up (Phase 1 complete)
- [ ] Configs and dotfiles backed up (Phase 2 complete)
- [ ] No uncommitted git changes remaining (Phase 3 complete)
- [ ] iCloud Drive fully synced (check `brctl status` or `ls ~/Library/Mobile\ Documents/`)
- [ ] Signed out of iMessage (`Messages > Settings > iMessage > Sign Out`)
- [ ] Deauthorized iTunes/Music if needed (`Account > Authorizations > Deauthorize`)
- [ ] Noted down Wi-Fi passwords for post-format (`security find-generic-password -ga <SSID>`)
- [ ] License keys / serial numbers saved for paid software
- [ ] 2FA recovery codes backed up (if any authenticator apps are on this Mac)
- [ ] FileVault recovery key noted down (if applicable)
- [ ] Time Machine backup is current (if using Time Machine)

Present each item one at a time. For items that can be verified programmatically, run the check and report the result. For manual items, ask the user to confirm.

After all phases are complete, confirm that the Mac is ready for formatting.
