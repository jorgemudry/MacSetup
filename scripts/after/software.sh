#!/usr/bin/env bash

if [ "$MACSETUP_MAIN" != "true" ]; then
    echo "This script must be run from start.sh!"
    exit 1
fi
source ./scripts/common.sh

function install_xcode_clt {
    echo -e "\n${BLUE}=== Xcode Command Line Tools ===${NC}"

    if xcode-select -p &>/dev/null; then
        execute_command "Xcode CLT already installed" "true"
    else
        execute_command "Requesting Xcode CLT installation" "xcode-select --install"

        echo -e "\n${YELLOW}Waiting for Xcode CLT installation to complete..."
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
        echo -e "${GREEN}Xcode CLT installation complete!${NC}"
    fi
}

function install_homebrew {
    echo -e "\n${BLUE}=== Homebrew ===${NC}"

    if command -v brew &>/dev/null; then
        execute_command "Homebrew already installed" "true"
        return 0
    fi

    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        if [[ "$(uname -m)" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        execute_command "Setting up homebrew environment" "true"
    else
        echo -e "${RED}Homebrew installation failed!${NC}"
        return 1
    fi
}

function check_brew_health {
    echo -e "\n${BLUE}=== Brew Doctor Check ===${NC}"

    echo -e "${YELLOW}Running brew doctor...${NC}"
    brew doctor

    local status=$?
    if [ $status -eq 0 ]; then
        echo -e "\n${GREEN}✓ Brew configuration is healthy${NC}"
        return 0
    elif [ $status -eq 1 ]; then
        echo -e "\n${YELLOW}⚠ Brew doctor found warnings (continuing anyway)${NC}"
        return 0
    else
        echo -e "\n${RED}✗ Critical brew issues detected!${NC}"
        return 1
    fi
}

function install_brew_bundle {
    echo -e "\n${BLUE}=== Brew Bundle ===${NC}"

    local brewfile_path
    brewfile_path="$(dirname "$0")/../../Brewfile"

    if [ ! -f "$brewfile_path" ]; then
        echo -e "${RED}Brewfile not found at: $brewfile_path${NC}"
        return 1
    fi

    local brew_prefix
    brew_prefix=$(brew --prefix)

    if [ -d "${brew_prefix}/Library/Locks" ]; then
        execute_command "Removing stale locks" "find ${brew_prefix}/Library/Locks -type f -delete" true
    fi

    execute_command "Installing Brewfile packages" "brew bundle install --file '$brewfile_path' --force --cleanup" true
}

function setup_iterm {
    echo -e "\n${BLUE}=== Setting iTemr2 Basic Config ===${NC}"

    # Don’t display the annoying prompt when quitting iTerm
    execute_command "Disable quit prompt in iTerm" "defaults write com.googlecode.iterm2 PromptOnQuit -bool false"

    # Disable iTerm2 Native Full Screen Window
    execute_command "Disable native full-screen mode in iTerm2" "defaults write com.googlecode.iterm2 UseLionStyleFullscreen -bool false"

    # Enable iTerm2 HotKey to Hide/Show Window (The key set is "`")
    execute_command "Enable iTerm2 HotKey to toggle window (key: \`)" "defaults write com.googlecode.iterm2 HotkeyModifiers -int 256"
    execute_command "Set iTerm2 HotKey code to 50" "defaults write com.googlecode.iterm2 HotkeyCode -int 50"
    execute_command "Set iTerm2 HotKey char to 96 (backtick)" "defaults write com.googlecode.iterm2 HotkeyChar -int 96"
    execute_command "Enable iTerm2 HotKey" "defaults write com.googlecode.iterm2 Hotkey -bool true"

    # Disable Tab Bar in Full Screen
    execute_command "Disable tab bar in full-screen mode in iTerm2" "defaults write com.googlecode.iterm2 ShowFullScreenTabBar -bool false"
}

function install_oh_my_zsh {
    echo -e "\n${BLUE}=== OH MY ZSH ===${NC}"

# Disabling this because macos already has zsh as its default SHELL
#    current_shell=$(dscl . -read /Users/"$USER" UserShell | awk '{print $2}')
#
#    if [[ "$current_shell" != "$(which zsh)" ]]; then
#        execute_command "Setting ZSH as default shell" "sudo chsh -s $(which zsh)"
#    else
#        echo -e "${GREEN}ZSH is already the default shell ✓${NC}"
#    fi

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        execute_command "Installing Oh My ZSH" "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    else
        echo -e "${GREEN}Oh My ZSH is already installed ✓${NC}"
    fi
}

function main_software_flow {
    install_xcode_clt
    install_homebrew

    if command -v brew &>/dev/null; then
        execute_command "Updating Homebrew" "brew update --force && brew upgrade --force" true
        execute_command "Cleaning broken installations" "brew cleanup --prune=all -s" true

        if ! check_brew_health; then
            echo -e "${RED}Aborting due to critical brew issues${NC}"
            return 1
        fi

        install_brew_bundle

        local brew_prefix
        brew_prefix=$(brew --prefix)

        if [ -d "${brew_prefix}/Cellar/vim" ]; then
            execute_command "Linking vim" "brew link --overwrite vim" true
        fi

        if [ -d "${brew_prefix}/Cellar/zsh" ]; then
            execute_command "Linking zsh" "brew link --overwrite zsh" true
        fi

        if [ -d "${brew_prefix}/Cellar/ruby" ]; then
            execute_command "Linking ruby" "brew link --overwrite ruby" true
        fi
    else
        echo -e "${RED}Homebrew installation failed! Skipping Brewfile...${NC}"
    fi

    setup_iterm
    install_oh_my_zsh

    echo -e "\n${GREEN}Software installation complete!${NC}"
    press_any_key
}

if ! checksudoandprompt; then
#    echo -e "\n${RED}Authentication failed.${NC}"
    press_any_key
    exit 0
fi

# Keep-alive: update existing `sudo` time stamp
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

main_software_flow