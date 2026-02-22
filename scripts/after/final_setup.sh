#!/usr/bin/env bash

if [ "${MACSETUP_MAIN:-}" != "true" ]; then
    echo "This script must be run from start.sh!"
    exit 1
fi
source ./scripts/common.sh

function wait_for_dropbox {
    echo -e "\n${BLUE}=== Dropbox Setup ===${NC}"
    echo -e "${YELLOW}Please open Dropbox, sign in, and wait for sync to complete.${NC}"
    echo -e "You can open it with: ${GREEN}open -a Dropbox${NC}"

    if [[ "${MACSETUP_NONINTERACTIVE:-}" == "true" ]]; then
        # Non-interactive: wait for a specific file deep in the tree to confirm sync is done
        echo -e "${YELLOW}Waiting for Dropbox config files to fully sync...${NC}"
        until [ -f "$HOME/Dropbox/Mackup/.zshrc" ] && [ -d "$HOME/Dropbox/Config/home/.ssh" ]; do
            sleep 10
        done
    else
        echo -e "\n${YELLOW}Once Dropbox is fully synced, press any key to continue.${NC}"
        echo -ne "${BLUE}Press any key when ready...${NC}"
        read -r -n1 -s
        echo
    fi

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

    # Home directory symlinks (target link pairs)
    local home_targets=(
        "$HOME/Dropbox/Mackup/.aws"
        "$HOME/Dropbox/Mackup/.bashrc"
        "$HOME/Dropbox/Mackup/.boto"
        "$HOME/Dropbox/Mackup/.editorconfig"
        "$HOME/Dropbox/Mackup/.gdbinit"
        "$HOME/Dropbox/Mackup/.gitconfig"
        "$HOME/Dropbox/Config/home/.letmein"
        "$HOME/Dropbox/Mackup/.mackup.cfg"
        "$HOME/Dropbox/Config/home/.ssh"
        "$HOME/Dropbox/Mackup/.subversion"
        "$HOME/Dropbox/Mackup/.wget-hsts"
        "$HOME/Dropbox/Mackup/.wp-cli"
        "$HOME/Dropbox/Mackup/.zprofile"
        "$HOME/Dropbox/Mackup/.zshrc"
    )
    local home_links=(
        "$HOME/.aws"
        "$HOME/.bashrc"
        "$HOME/.boto"
        "$HOME/.editorconfig"
        "$HOME/.gdbinit"
        "$HOME/.gitconfig"
        "$HOME/.letmein"
        "$HOME/.mackup.cfg"
        "$HOME/.ssh"
        "$HOME/.subversion"
        "$HOME/.wget-hsts"
        "$HOME/.wp-cli"
        "$HOME/.zprofile"
        "$HOME/.zshrc"
    )

    echo -e "${BLUE}Home directory:${NC}"
    for i in "${!home_targets[@]}"; do
        local target="${home_targets[$i]}"
        local link="${home_links[$i]}"
        execute_command "  $(basename "$link") -> $target" "create_symlink '$target' '$link'"
    done

    # ~/.claude directory symlinks
    mkdir -p "$HOME/.claude"

    local claude_targets=(
        "$HOME/Dropbox/Config/home/.claude/agents"
        "$HOME/Dropbox/Config/home/.claude/CLAUDE.md"
        "$HOME/Dropbox/Config/home/.claude/settings.json"
    )
    local claude_links=(
        "$HOME/.claude/agents"
        "$HOME/.claude/CLAUDE.md"
        "$HOME/.claude/settings.json"
    )

    echo -e "\n${BLUE}Claude Code config:${NC}"
    for i in "${!claude_targets[@]}"; do
        local target="${claude_targets[$i]}"
        local link="${claude_links[$i]}"
        execute_command "  $(basename "$link") -> $target" "create_symlink '$target' '$link'"
    done

    # ~/.oh-my-zsh/custom symlinks
    local omz_targets=(
        "$HOME/Dropbox/Mackup/.oh-my-zsh/custom/aliases.zsh"
        "$HOME/Dropbox/Mackup/.oh-my-zsh/custom/functions.zsh"
    )
    local omz_links=(
        "$HOME/.oh-my-zsh/custom/aliases.zsh"
        "$HOME/.oh-my-zsh/custom/functions.zsh"
    )

    echo -e "\n${BLUE}Oh My Zsh custom:${NC}"
    for i in "${!omz_targets[@]}"; do
        local target="${omz_targets[$i]}"
        local link="${omz_links[$i]}"
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
