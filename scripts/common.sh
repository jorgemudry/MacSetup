set -u -o pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
CHECK="✓"
CROSS="✗"

sudo_authenticated=false

function check_sudo {
    if ! $sudo_authenticated; then
        echo -e "\n${YELLOW}Authentication required...${NC}"
        if sudo -v; then
            sudo_authenticated=true
            echo -e "${GREEN}Authentication successful!${NC}"
        else
            echo -e "${RED}Failed to authenticate!${NC}"
            return 1
        fi
    fi
    return 0
}

function press_any_key {
    echo -ne "\n${BLUE}Press any key to continue...${NC}"
    read -r -n1 -s
}


function execute_command {
    local description="$1"
    local cmd="$2"
    local verbose="${3:-false}"

    echo -n -e "${BLUE}${description}"

    if $verbose; then
        echo -e "\n"
        eval "$cmd"
    else
        eval "$cmd" >/dev/null 2>&1
    fi

    local status=$?

    if ! $verbose; then
        if [ $status -eq 0 ]; then
            echo -e " ${GREEN}${CHECK}${NC}"
        else
            echo -e " ${RED}${CROSS}${NC}"
        fi
    fi
}

function askforreboot {
    echo -e "\n${CYAN}A reboot is required.${NC}"
    echo -e "\nDo you want to reboot now? [Y/n]"
    echo -ne "> ${BLUE}\a"
    read -r
    echo -e "${NC}"

    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        echo -e "\n${YELLOW}Rebooting now. See you on the other side …${NC}\n"
        # sudo shutdown -r now
        osascript -e 'tell app "System Events" to restart'
        exit;
    fi
}

function checksudoandprompt {
    if sudo -nl 2>&1 | grep -qE "password is required$"; then
        echo -ne "\a"
        if ! sudo -v; then
            echo -e "\n${RED}Authentication failed. Unable to proceed.${NC}"
            return 1
        fi
    else
        echo -e "\n${YELLOW}Already running with sudo pass … no need to ask 😊${NC}"
    fi
    return 0
}

