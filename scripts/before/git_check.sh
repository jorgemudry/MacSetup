#!/usr/bin/env bash

if [ "${MACSETUP_MAIN:-}" != "true" ]; then
    echo "This script must be run from start.sh!"
    exit 1
fi

source ./scripts/common.sh

function show_git_check_header {
    clear
    echo -e "${BLUE}"
    echo "  ██████╗██╗████████╗     ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗"
    echo " ██╔════╝██║╚══██╔══╝    ██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝"
    echo " ██║     ██║   ██║       ██║     ███████║█████╗  ██║     █████╔╝ "
    echo " ██║     ██║   ██║       ██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ "
    echo " ╚██████╗██║   ██║       ╚██████╗██║  ██║███████╗╚██████╗██║  ██╗"
    echo "  ╚═════╝╚═╝   ╚═╝        ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo "                  === UNCOMMITTED CHANGES CHECK ==="
    echo
}

function expand_path {
    local path="$1"
    # Expand tilde safely without eval
    echo "${path/#\~/$HOME}"
}

function validate_directory {
    local path="$1"

    if [ ! -d "$path" ]; then
        echo -e "${RED}Error: Directory does not exist!${NC}"
        return 1
    fi

    if [ ! -r "$path" ]; then
        echo -e "${RED}Error: Read permission denied!${NC}"
        return 1
    fi

    return 0
}

function check_git_changes {
    local base_dir="$1"
    # Declaramos el array vacío en el shell actual
    changes_found=()

    echo -e "\n${BLUE}Scanning directory: $base_dir${NC}"

    # Usamos sustitución de proceso para que el while se ejecute en el shell actual
    while IFS= read -d $'\0' -r dir; do
        if [ "$dir" = "$base_dir" ]; then
            continue
        fi

        if [ -d "$dir/.git" ]; then
            echo -e "${YELLOW}Checking repository: $dir${NC}"
            if [ -n "$(git -C "$dir" status --porcelain)" ]; then
                changes_found+=("$dir")
                echo -e "${RED}Uncommitted changes found!${NC}"
            else
                echo -e "${GREEN}No uncommitted changes${NC}"
            fi
        fi
    done < <(find "$base_dir" -maxdepth 1 -type d -print0)

    return_changes "${changes_found[@]}"
}

function return_changes {
    local changes=("$@")

    echo -e "\n${BLUE}=== Scan Results ===${NC}"

    if [ ${#changes[@]} -eq 0 ]; then
        echo -e "${GREEN}No repositories with uncommitted changes found!${NC}"
    else
        echo -e "${RED}Repositories with uncommitted changes:${NC}"
        for repo in "${changes[@]}"; do
            echo -e " - ${YELLOW}$repo${NC}"
        done
    fi

    press_any_key
}

while true; do
    show_git_check_header

    echo "1. Check for uncommitted Git changes"
    echo "2. Back to main menu"
    echo
    echo -ne "${BLUE}Enter your choice: ${NC}"
    read -r choice

    case $choice in
        1)
            echo -e "\n${BLUE}Enter directory path to scan (supports ~/ paths):${NC}"
            read -r scan_path
            expanded_path=$(expand_path "$scan_path")

            if ! validate_directory "$expanded_path"; then
                echo -ne "${RED}Press any key to try again...${NC}"
                read -n1 -s
                continue
            fi

            check_git_changes "$expanded_path"
            ;;
        2)
            break
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done
