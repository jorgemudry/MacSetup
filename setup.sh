#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR
cd "$SCRIPT_DIR"

export MACSETUP_MAIN=true
source "$SCRIPT_DIR/scripts/common.sh"

function show_header {
    clear
    echo -e "${GREEN}"
    echo " ███╗   ███╗ █████╗  ██████╗              ███████╗███████╗████████╗██╗   ██╗██████╗   "
    echo " ████╗ ████║██╔══██╗██╔════╝              ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗  "
    echo " ██╔████╔██║███████║██║         █████╗    ███████╗█████╗     ██║   ██║   ██║██████╔╝  "
    echo " ██║╚██╔╝██║██╔══██║██║         ╚════╝    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝   "
    echo " ██║ ╚═╝ ██║██║  ██║╚██████╗              ███████║███████╗   ██║   ╚██████╔╝██║       "
    echo " ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝              ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝       "
    echo -e "${NC}"
    echo
}

function display_menu {
    echo -e "\033[1mStart your clean Mac setup:\033[0m"
    echo "1. Software"
    echo "2. Settings"
    echo "3. Final Setup"
    echo
    echo "4. Exit"
}

while true; do
    show_header
    display_menu
    echo -n -e "\n\033[94mEnter your choice: \033[0m"
    read -r choice

    case $choice in
        1) bash scripts/after/software.sh ;;
        2) bash scripts/after/settings.sh ;;
        3) bash scripts/after/final_setup.sh ;;
        4)
            echo -e "\n\033[32mGoodbye! 👋\033[0m\n"
            exit 0
            ;;
        *)
            echo -e "\n\033[31mInvalid option!\033[0m"
            ;;
    esac
done
