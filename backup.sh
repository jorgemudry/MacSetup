#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR
cd "$SCRIPT_DIR"

export MACSETUP_MAIN=true
source "$SCRIPT_DIR/scripts/common.sh"

function show_header {
    clear
    echo -e "${GREEN}"
    echo " ███╗   ███╗ █████╗  ██████╗              ██████╗  █████╗  ██████╗██╗  ██╗██╗   ██╗██████╗  "
    echo " ████╗ ████║██╔══██╗██╔════╝              ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗ "
    echo " ██╔████╔██║███████║██║         █████╗    ██████╔╝███████║██║     █████╔╝ ██║   ██║██████╔╝ "
    echo " ██║╚██╔╝██║██╔══██║██║         ╚════╝    ██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔═══╝  "
    echo " ██║ ╚═╝ ██║██║  ██║╚██████╗              ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║      "
    echo " ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝              ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝      "
    echo -e "${NC}"
    echo
}

function display_menu {
    echo -e "\033[1mPreparing your Mac to be formatted:\033[0m"
    echo "1. Files Backup"
    echo "2. Config Backup"
    echo "3. Check for uncommitted Git changes"
    echo "4. Ready to format"
    echo
    echo "5. Exit"
}

while true; do
    show_header
    display_menu
    echo -n -e "\n\033[94mEnter your choice: \033[0m"
    read -r choice

    case $choice in
        1) bash scripts/before/files_backup.sh ;;
        2) bash scripts/before/config_backup.sh ;;
        3) bash scripts/before/git_check.sh ;;
        4) bash scripts/before/ready_format.sh ;;
        5)
            echo -e "\n\033[32mGoodbye! 👋\033[0m\n"
            exit 0
            ;;
        *)
            echo -e "\n\033[31mInvalid option!\033[0m"
            ;;
    esac
done
