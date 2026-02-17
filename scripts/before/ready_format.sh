#!/usr/bin/env bash

if [ "$MACSETUP_MAIN" != "true" ]; then
    echo "This script must be run from start.sh!"
    exit 1
fi

echo -e "\n\033[1mPreparing for format...\033[0m"
# Add pre-format commands here
echo -e "\033[32mSystem ready for formatting!\033[0m"