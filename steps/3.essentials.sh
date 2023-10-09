#!/usr/bin/env bash

###############################################################################
# PREVENT PEOPLE FROM SHOOTING THEMSELVES IN THE FOOT                         #
###############################################################################

starting_script=$(basename "$0")
if [ "$starting_script" != "freshinstall.sh" ]; then
	echo -e "\n\033[31m\aUhoh!\033[0m This script is part of freshinstall and should not be run by itself."
	echo -e "Please launch freshinstall itself using \033[1m./freshinstall.sh\033[0m"
	echo -e "\n\033[93mMy journey stops here (for now) … bye! 👋\033[0m\n"
	exit 1
fi;

###############################################################################
# XCODE                                                                       #
###############################################################################
echo -e "\n- Xcode Command Line Tools:\n"

# @ref https://github.com/Homebrew/install/blob/master/install#L110
if [ ! -f "/Library/Developer/CommandLineTools/usr/bin/git" ] || [ ! -f "/usr/include/iconv.h" ]; then
    xcodetools_installed="no"
else
    xcodetools_installed="yes"
fi;

if [ "$xcodetools_installed" == "yes" ]; then
    echo -e "  - Command Line Tools       \033[32mInstalled\033[0m"
else
    echo -e "  - Command Line Tools       \033[31mNot Installed\033[0m"
fi;

if [ "$xcodetools_installed" == "no" ]; then
    echo -e "\nLaunching installer for Xcode Command Line Tools …"

    xcode-select --install &>/dev/null

    echo -e "\nPress any key when the installer has finished."
    read -n 1

fi;
###############################################################################
# HOMEBREW                                                                    #
###############################################################################

echo -e "\n- Homebrew:"

echo -ne "\n  - Installation Status      "
if [ -n "$(which brew)" ]; then
	echo -e "\033[32mInstalled\033[0m"
else
	echo -e "\033[93mInstalling\033[0m"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
	eval "$(/opt/homebrew/bin/brew shellenv)"

	brew update
fi;

# Make sure proper permissions are set …
echo -ne "  - Folder permissions       "
if [ "$(ls -ld /usr/local/Cellar/ | awk '{print $3}')" != "$(whoami)" ]; then
	echo -e "\033[93mFixing\033[0m"
	sudo chown -R $(whoami) /usr/local/Cellar
	sudo chown -R $(whoami) /usr/local/Homebrew
	sudo chown -R $(whoami) /usr/local/var/homebrew/locks
	sudo chown -R $(whoami) /usr/local/etc /usr/local/lib /usr/local/sbin /usr/local/share /usr/local/var /usr/local/Frameworks /usr/local/share/locale /usr/local/share/man /usr/local/opt
else
	echo -e "\033[32mOK\033[0m"
fi;

# Run brew doctor to be sure
echo -ne "  - Check with “brew doctor” "

if [ "$(brew doctor 2>&1 | grep "Error")" ]; then
	echo -e "\033[31mNOK\033[0m"
	echo -e "\n\033[93mUh oh, “brew doctor” returned some errors … please fix these manually and then restart ./freshinstall\033[0m\n"
	exit
else
	echo -e "\033[32mOK\033[0m"
fi;

###############################################################################
# GIT                                                                         #
###############################################################################

echo -e "\n- Git: "

echo -ne "\n  - Installation Status      "

# GIT_NEEDS_TO_BE_INSTALLED="no"
# if [ -n "$(which git)" ]; then
# 	if [ ! -n "$(git --version) | grep "Apple"" ]; then # we don't want the Apple version
# 		echo -e "\033[33mNeeds upgrade\033[0m"
# 		GIT_NEEDS_TO_BE_INSTALLED="yes"
# 	else
# 		echo -e "\033[32mInstalled\033[0m"
# 	fi;
# else
# 	echo -e "\033[31mNot Installed\033[0m"
# 	GIT_NEEDS_TO_BE_INSTALLED="yes"
# fi;

# if [ "$GIT_NEEDS_TO_BE_INSTALLED" = "yes" ]; then
# 	brew install git
# fi;

# Always try to install git with brew
brew install git

echo -e "\033[32mOK\033[0m"

echo -e "\n\033[93mGreat, we've installed some essentials\033[0m"