#!/usr/bin/env bash

if [ "$MACSETUP_MAIN" != "true" ]; then
    echo "This script must be run from start.sh!"
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function show_files_backup_header {
    clear
    echo -e "${BLUE}"
    echo " ███████╗██╗██╗     ███████╗███████╗    ██████╗  █████╗  ██████╗██╗  ██╗██╗   ██╗██████╗  "
    echo " ██╔════╝██║██║     ██╔════╝██╔════╝    ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗ "
    echo " █████╗  ██║██║     █████╗  ███████╗    ██████╔╝███████║██║     █████╔╝ ██║   ██║██████╔╝ "
    echo " ██╔══╝  ██║██║     ██╔══╝  ╚════██║    ██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔═══╝  "
    echo " ██║     ██║███████╗███████╗███████║    ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║      "
    echo " ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝      "
    echo -e "${NC}"
    echo "                        === FILES BACKUP UTILITY ==="
    echo
}

pendriveNames=()
pendriveMounts=()

function detect_pendrives {
    pendriveNames=()
    pendriveMounts=()

    while IFS= read -r line; do
        mount_point=$(echo "$line" | awk '{print $NF}')
        if [[ "$mount_point" == /Volumes/* ]]; then
            vol_name=$(basename "$mount_point")
            pendriveNames+=("$vol_name")
            pendriveMounts+=("$mount_point")
        fi
    done < <(df -h | awk '$0 ~ /^\/dev\/disk/ && $NF ~ /^\/Volumes\// { print }')
}

function validate_path {
    local path="$1"

    if [[ "$path" == smb://* || "$path" == afp://* ]]; then
        echo -e "\n${YELLOW}Note for network paths:${NC}"
        echo "1) Connect/mount the network share first (Finder > Go > Connect to Server)"
        echo "2) Then provide the local mount point (e.g., /Volumes/ShareName)"
        return 1
    fi

    if [ ! -d "$path" ]; then
        echo -e "${RED}The path '${path}' does not exist!${NC}"
        return 1
    fi

    if [ ! -w "$path" ]; then
        echo -e "${RED}Write permission denied on '${path}'!${NC}"
        return 1
    fi

    return 0
}

function do_files_backup {
    local destination="$1"

    local backup_dirs=("$HOME/Downloads" "$HOME/Pictures")
    local backup_folder="${destination}/MacBackup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_folder"

    local backup_log="$HOME/Desktop/Backup_Report_$(date +%Y%m%d_%H%M%S).txt"

    echo "Backup started: $(date)" | tee "$backup_log"
    echo "Destination: $backup_folder" | tee -a "$backup_log"

    for dir in "${backup_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "${BLUE}Copying: $dir${NC}" | tee -a "$backup_log"
            rsync -avh --progress "$dir" "$backup_folder" 2>&1 | tee -a "$backup_log"
        else
            echo -e "${YELLOW}Skipping missing directory: $dir${NC}" | tee -a "$backup_log"
        fi
    done

    echo -e "${GREEN}Backup completed!${NC}\n" | tee -a "$backup_log"
    echo -ne "${BLUE}Press any key to continue...${NC}"
    read -n1 -s
}

while true; do
    detect_pendrives
    show_files_backup_header

    optionLabels=()
    optionDest=()

    for i in "${!pendriveNames[@]}"; do
        volName="${pendriveNames[$i]}"
        mp="${pendriveMounts[$i]}"
        optionLabels+=("$volName -> $mp")
        optionDest+=("$mp")
    done

    optionLabels+=("Choose a custom destination")
    optionDest+=("custom")

    optionLabels+=("Back to main menu")
    optionDest+=("back")

    for idx in "${!optionLabels[@]}"; do
        if [ "${optionLabels[$idx]}" == "Back to main menu" ]; then
            echo
        fi
        echo "$((idx+1)). ${optionLabels[$idx]}"
    done

    echo
    echo -ne "${BLUE}Enter your choice: ${NC}"
    read -r choice

    index=$(( choice - 1 ))
    if [ $index -lt 0 ] || [ $index -ge ${#optionDest[@]} ]; then
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        continue
    fi

    selection="${optionDest[$index]}"

    case "$selection" in
        "back")
            break
            ;;
        "custom")
            echo -e "\n${BLUE}Enter a custom path (e.g., /Volumes/NetworkShare):${NC}"
            read -r custom_path
            validate_path "$custom_path"
            if [ $? -ne 0 ]; then
                sleep 2
                continue
            fi
            do_files_backup "$custom_path"
            break
            ;;
        *)
            validate_path "$selection"
            if [ $? -ne 0 ]; then
                sleep 2
                continue
            fi
            do_files_backup "$selection"
            break
            ;;
    esac
done
