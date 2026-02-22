#!/usr/bin/env bash

if [ "${MACSETUP_MAIN:-}" != "true" ]; then
    echo "This script must be run from start.sh!"
    exit 1
fi
source ./scripts/common.sh

function wait_for_dropbox {
    echo -e "\n${BLUE}=== Dropbox Setup ===${NC}"
    echo -e "${YELLOW}Please open Dropbox, sign in, and complete sync before continuing.${NC}"
    echo -e "You can open it with: ${GREEN}open -a Dropbox${NC}"

    if [[ "${MACSETUP_NONINTERACTIVE:-}" == "true" ]]; then
        echo -e "${YELLOW}Waiting for Dropbox folder to appear at ~/Dropbox...${NC}"
    else
        echo -e "\nOnce Dropbox is synced, press any key to continue."
    fi

    # Wait until ~/Dropbox exists
    until [ -d "$HOME/Dropbox" ]; do
        sleep 5
    done

    # Wait until the expected config directories are synced
    echo -e "${YELLOW}Dropbox folder detected. Waiting for config files to sync...${NC}"
    until [ -d "$HOME/Dropbox/Mackup" ] && [ -d "$HOME/Dropbox/Config" ]; do
        sleep 5
    done

    echo -e "${GREEN}Dropbox config files are ready!${NC}"
}

function create_symlink {
    local target="$1"
    local link="$2"

    # Remove existing file/symlink/directory at the link path
    if [ -e "$link" ] || [ -L "$link" ]; then
        rm -rf "$link"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$link")"

    ln -s "$target" "$link"
}

function setup_symlinks {
    echo -e "\n${BLUE}=== Creating Symlinks ===${NC}"

    # Home directory symlinks
    local -A home_links=(
        ["$HOME/.aws"]="$HOME/Dropbox/Mackup/.aws"
        ["$HOME/.bashrc"]="$HOME/Dropbox/Mackup/.bashrc"
        ["$HOME/.boto"]="$HOME/Dropbox/Mackup/.boto"
        ["$HOME/.editorconfig"]="$HOME/Dropbox/Mackup/.editorconfig"
        ["$HOME/.gdbinit"]="$HOME/Dropbox/Mackup/.gdbinit"
        ["$HOME/.gitconfig"]="$HOME/Dropbox/Mackup/.gitconfig"
        ["$HOME/.letmein"]="$HOME/Dropbox/Config/home/.letmein"
        ["$HOME/.mackup.cfg"]="$HOME/Dropbox/Mackup/.mackup.cfg"
        ["$HOME/.ssh"]="$HOME/Dropbox/Config/home/.ssh"
        ["$HOME/.subversion"]="$HOME/Dropbox/Mackup/.subversion"
        ["$HOME/.wget-hsts"]="$HOME/Dropbox/Mackup/.wget-hsts"
        ["$HOME/.wp-cli"]="$HOME/Dropbox/Mackup/.wp-cli"
        ["$HOME/.zprofile"]="$HOME/Dropbox/Mackup/.zprofile"
        ["$HOME/.zshrc"]="$HOME/Dropbox/Mackup/.zshrc"
    )

    echo -e "${BLUE}Home directory:${NC}"
    for link in "${!home_links[@]}"; do
        local target="${home_links[$link]}"
        execute_command "  $(basename "$link") -> $target" "create_symlink '$target' '$link'"
    done

    # ~/.claude directory symlinks
    mkdir -p "$HOME/.claude"

    local -A claude_links=(
        ["$HOME/.claude/agents"]="$HOME/Dropbox/Config/home/.claude/agents"
        ["$HOME/.claude/CLAUDE.md"]="$HOME/Dropbox/Config/home/.claude/CLAUDE.md"
        ["$HOME/.claude/settings.json"]="$HOME/Dropbox/Config/home/.claude/settings.json"
    )

    echo -e "\n${BLUE}Claude Code config:${NC}"
    for link in "${!claude_links[@]}"; do
        local target="${claude_links[$link]}"
        execute_command "  $(basename "$link") -> $target" "create_symlink '$target' '$link'"
    done

    # ~/.oh-my-zsh/custom symlinks
    local -A omz_links=(
        ["$HOME/.oh-my-zsh/custom/aliases.zsh"]="$HOME/Dropbox/Mackup/.oh-my-zsh/custom/aliases.zsh"
        ["$HOME/.oh-my-zsh/custom/functions.zsh"]="$HOME/Dropbox/Mackup/.oh-my-zsh/custom/functions.zsh"
    )

    echo -e "\n${BLUE}Oh My Zsh custom:${NC}"
    for link in "${!omz_links[@]}"; do
        local target="${omz_links[$link]}"
        execute_command "  $(basename "$link") -> $target" "create_symlink '$target' '$link'"
    done

    # ~/.oh-my-zsh/custom/plugins symlinks
    echo -e "\n${BLUE}Oh My Zsh plugins:${NC}"
    execute_command "  zsh-syntax-highlighting -> ~/Dropbox/Mackup/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
        "create_symlink '$HOME/Dropbox/Mackup/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting' '$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting'"
}

function fix_ssh_permissions {
    echo -e "\n${BLUE}=== SSH Permissions ===${NC}"

    if [ -d "$HOME/.ssh" ]; then
        execute_command "Set ~/.ssh directory permissions to 700" "chmod 700 '$HOME/.ssh'"

        # Fix permissions on all private keys (files without .pub extension)
        for key_file in "$HOME"/.ssh/*; do
            if [ -f "$key_file" ]; then
                case "$key_file" in
                    *.pub)
                        execute_command "  $(basename "$key_file") -> 644" "chmod 644 '$key_file'"
                        ;;
                    */known_hosts|*/authorized_keys|*/config)
                        execute_command "  $(basename "$key_file") -> 644" "chmod 644 '$key_file'"
                        ;;
                    *)
                        execute_command "  $(basename "$key_file") -> 600" "chmod 600 '$key_file'"
                        ;;
                esac
            fi
        done
    else
        echo -e "${RED}~/.ssh not found — skipping permissions fix${NC}"
    fi
}

wait_for_dropbox
setup_symlinks
fix_ssh_permissions

echo -e "\n${GREEN}Final setup completed successfully!${NC}"
press_any_key
