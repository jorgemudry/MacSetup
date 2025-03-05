#!/usr/bin/env bash

if [ "$MACSETUP_MAIN" != "true" ]; then
    echo "This script must be run from start.sh!"
    exit 1
fi

echo -e "\n\033[1mStarting Config Backup...\033[0m"
# Add config backup commands here
echo -e "\033[32mConfig backup completed successfully!\033[0m"