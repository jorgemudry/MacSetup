#!/usr/bin/env bash

###############################################################################
# PREVENT PEOPLE FROM SHOOTING THEMSELVES IN THE FOOT                         #
###############################################################################

starting_script=`basename "$0"`
if [ "$starting_script" != "freshinstall.sh" ]; then
	echo -e "\n\033[31m\aUhoh!\033[0m This script is part of freshinstall and should not be run by itself."
	echo -e "Please launch freshinstall itself using \033[1m./freshinstall.sh\033[0m"
	echo -e "\n\033[93mMy journey stops here (for now) … bye! 👋\033[0m\n"
	exit 1
fi;

###############################################################################
# GNU Core Utilities                                                          #
###############################################################################

# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
#brew install coreutils
#sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install some other useful utilities like `sponge`.
#brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
#brew install findutils

# Install GNU `sed`, overwriting the built-in `sed`.
#brew install gnu-sed --with-default-names

# Install `wget` with IRI support.
brew install wget --with-iri

###############################################################################
# Bash.                                                                       #
###############################################################################

# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
#brew install bash
#brew install bash-completion

###############################################################################
# Sublime Text                                                                #
###############################################################################

brew cask install sublime-text

# Make sure directories exists
if [ ! -d "~/Library/Application Support/Sublime Text 3" ]; then
	mkdir ~/Library/Application\ Support/Sublime\ Text\ 3
fi;
if [ ! -d "~/Library/Application Support/Sublime Text 3/Installed Packages" ]; then
	mkdir ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
fi;
if [ ! -d "~/Library/Application Support/Sublime Text 3/Packages" ]; then
	mkdir ~/Library/Application\ Support/Sublime\ Text\ 3/Packages
fi;
if [ ! -d "~/Library/Application Support/Sublime Text 3/Packages/User" ]; then
	mkdir ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
fi;

# Open files by default with sublime using duti
#
# Note that duti is preferred over the command below, as that on requires a reboot
# 	defaults write com.apple.LaunchServices LSHandlers -array-add '{"LSHandlerContentType" = "public.plain-text"; "LSHandlerPreferredVersions" = { "LSHandlerRoleAll" = "-"; }; LSHandlerRoleAll = "com.sublimetext.3";}'
#
# Some pointers:
# - To get identifier of Sublime: /usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' /Applications/Sublime\ Text.app/Contents/Info.plist
# - To get UTI of a file: mdls -name kMDItemContentTypeTree /path/to/file.ext
#
brew install duti
duti -s com.sublimetext.3 public.data all # for files like ~/.bash_profile
duti -s com.sublimetext.3 public.plain-text all
duti -s com.sublimetext.3 public.script all
duti -s com.sublimetext.3 net.daringfireball.markdown all


###############################################################################
# vim                                                                         #
###############################################################################

brew install vim --override-system-vi

###############################################################################
# CTF tools                                                                   #
###############################################################################

# Install some CTF tools; see https://github.com/ctfs/write-ups.
# brew install bfg
# brew install binutils
# brew install binwalk
# brew install cifer
# brew install dex2jar
# brew install dns2tcp
# brew install fcrackzip
# brew install foremost
# brew install hashpump
# brew install hydra
# brew install john
# brew install knock
# brew install nmap
# brew install pngcheck
# brew install socat
# brew install sqlmap
# brew install tcpflow
# brew install tcpreplay
# brew install tcptrace
# brew install ucspi-tcp # `tcpserver` etc.
# brew install xpdf
# brew install xz

###############################################################################
# git-ftp (for older projects)                                                #
###############################################################################

# sudo chown -R $(whoami):staff /Library/Python/2.7
# curl https://bootstrap.pypa.io/get-pip.py | python
# pip install gitpython

# cp ./resources/apps/git-ftp/git-ftp.py ~/git-ftp.py
# echo '# git-ftp' >> ~/.bash_profile
# echo 'alias git-ftp="python ~/git-ftp.py"' >> ~/.bash_profile

###############################################################################
# Mac App Store                                                               #
###############################################################################

brew install mas

# Apple ID
if [ -n "$(defaults read NSGlobalDomain AppleID 2>&1 | grep -E "( does not exist)$")" ]; then
	AppleID=""
else
	AppleID="$(defaults read NSGlobalDomain AppleID)"
fi;
echo -e "\nWhat's your Apple ID? (default: $AppleID)"
echo -ne "> \033[34m\a"
read
echo -e "\033[0m\033[1A\n"
[ -n "$REPLY" ] && AppleID=$REPLY

if [ "$AppleID" != "" ]; then

	# Sign in
	mas signin --dialog $AppleID

	# iWork
	mas install 409203825 # Numbers
	mas install 409201541 # Pages
	mas install 409183694 # Keynote

	# Others
	mas install 425424353 # The Unarchiver
	mas install 946399090 # Telegram Desktop
    mas install 803453959 # Slack
	mas install 417602904 # CloudApp
    mas install 1063631769 # Medis - GUI for Redis

fi;


###############################################################################
# TMUX                                                                        #
###############################################################################

# brew install tmux
# brew install reattach-to-user-namespace
# cp ./resources/apps/tmux/.tmux.conf ~/.tmux.conf


###############################################################################
# BROWSERS                                                                    #
###############################################################################

brew cask install google-chrome
brew cask install firefox
brew cask install opera

###############################################################################
# CLI Improved Tools                                                          #
###############################################################################

# https://remysharp.com/2018/08/23/cli-improved
# https://github.com/sharkdp/bat
brew install bat
# http://denilson.sa.nom.br/prettyping/
brew install prettyping
# https://github.com/junegunn/fzf
brew install fzf
# https://github.com/so-fancy/diff-so-fancy
brew install diff-so-fancy
# https://github.com/sharkdp/fd/
brew install fd
# https://dev.yorhel.nl/ncdu
brew install ncdu
# https://tldr.sh/
brew install tldr

###############################################################################
# IMAGE & VIDEO PROCESSING                                                    #
###############################################################################

brew install imagemagick --with-librsvg --with-opencl --with-webp

brew install libvpx
brew install ffmpeg --with-libass --with-libvorbis --with-libvpx --with-x265 --with-ffplay
brew install youtube-dl

###############################################################################
# QUICK LOOK PLUGINS                                                          #
###############################################################################

# https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode
brew cask install qlstephen
brew cask install qlmarkdown
brew cask install quicklook-json
brew cask install qlimagesize
brew cask install suspicious-package
brew cask install qlvideo

brew cask install provisionql
brew cask install quicklookapk

# restart quicklook
defaults write org.n8gray.QLColorCode extraHLFlags '-l'
qlmanage -r
qlmanage -m


###############################################################################
# Composer + MySQL + Valet                                                    #
###############################################################################

# Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Newer PHP Versions
brew install php
brew install php@7.1

brew services start php
brew link php

pecl install mcrypt-1.0.1 # mcrypt for PHP 7.2
pecl install grpc # needed for google firestore et al

# @note: You might wanna "sudo brew services restart php" after this

# MySQL
# brew install mysql
# brew services start mysql

# # Tweak MySQL
# mysqlpassword="root"
# echo -e "\n  What should the root password for MySQL be? (default: $mysqlpassword)"
# echo -ne "  > \033[34m\a"
# read
# echo -e "\033[0m\033[1A"
# [ -n "$REPLY" ] && mysqlpassword=$REPLY

# mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '$mysqlpassword'; FLUSH PRIVILEGES;"
# cat ./resources/apps/mysql/my.cnf > /usr/local/etc/my.cnf
# brew services restart mysql

# Laravel Valet
# composer global require laravel/valet
# valet install

# If you want PMA available over https://pma.test/, run this:
# cd ~/repos/misc/
# composer create-project phpmyadmin/phpmyadmin
# cd ~/repos/misc/phpmyadmin
# valet link pma
# valet secure

###############################################################################
# Transmission.app + Config                                                   #
###############################################################################

# Install it
brew cask install transmission

# Use `~/Downloads/torrents` to store incomplete downloads
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/torrents"
if [ ! -d "${HOME}/Downloads/torrents" ]; then
	mkdir ${HOME}/Downloads/torrents
fi;

# Use `~/Downloads/_COMPLETE` to store completed downloads
# defaults write org.m0k.transmission DownloadLocationConstant -bool true
# defaults write org.m0k.transmission DownloadFolder -string "${HOME}/Downloads/_COMPLETE"
# if [ ! -d "${HOME}/Downloads/_COMPLETE" ]; then
# 	mkdir ${HOME}/Downloads/_COMPLETE
# fi;

# Autoload torrents from Downloads folder
# defaults write org.m0k.transmission AutoImportDirectory -string "${HOME}/Downloads"

# Don’t prompt for confirmation before downloading
defaults write org.m0k.transmission DownloadAsk -bool false
defaults write org.m0k.transmission MagnetOpenAsk -bool false

# Don’t prompt for confirmation before removing non-downloading active transfers
defaults write org.m0k.transmission CheckRemoveDownloading -bool true

# Trash original torrent files
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

# Hide the donate message
defaults write org.m0k.transmission WarningDonate -bool false

# Hide the legal disclaimer
defaults write org.m0k.transmission WarningLegal -bool false

# IP block list.
# Source: https://giuliomac.wordpress.com/2014/02/19/best-blocklist-for-transmission/
defaults write org.m0k.transmission BlocklistNew -bool true
defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"
defaults write org.m0k.transmission BlocklistAutoUpdate -bool true

# Randomize port on launch
# defaults write org.m0k.transmission RandomPort -bool true

# Set UploadLimit
defaults write org.m0k.transmission SpeedLimitUploadLimit -int 10
defaults write org.m0k.transmission UploadLimit -int 5

###############################################################################
# iTerm + Config                                                              #
###############################################################################

brew cask install iterm2
# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Disable iTerm2 Native Full Screen Window
defaults write com.googlecode.iterm2 UseLionStyleFullscreen -bool false

# Enable iTerm2 HotKey to Hide/Show Window (The key set is "`")
defaults write com.googlecode.iterm2 HotkeyModifiers -int 256
defaults write com.googlecode.iterm2 HotkeyCode -int 50
defaults write com.googlecode.iterm2 HotkeyChar -int 96
defaults write com.googlecode.iterm2 Hotkey -bool true

# Disable Tab Bar in Full Screen
defaults write com.googlecode.iterm2 ShowFullScreenTabBar -bool false

###############################################################################
# OTHER BREW/CASK THINGS                                                      #
###############################################################################

brew install speedtest-cli
brew install jq
brew install ssh-copy-id
brew install pv
brew install rename
brew install tree
brew install webkit2png
brew install httpie
brew install mackup
brew install mc
brew install htop

# brew cask install 1password
# brew cask install macpass

# Development
brew cask install sequel-pro
brew cask install vagrant
brew cask install virtualbox
# brew cask install docker
brew cask install paw
brew cask install insomnia
# brew cask install postman

# Utilities
brew cask install caffeine
brew cask install coconutbattery
brew cask install spectacle
brew cask install android-file-transfer
# brew cask install onyx
brew cask install cronnix
# brew cask install tunnelbear
# brew cask install nosleep


# https://shauninman.com/archive/2016/10/20/day_o_2_mac_menu_bar_clock
brew cask install day-o
# https://www.deltawalker.com/
brew cask install deltawalker

# Media
brew cask install vlc
duti -s org.videolan.vlc public.avi all
brew cask install spotify
# https://handbrake.fr/
brew cask install handbrake
# https://mkvtoolnix.download/
# brew install mkvtoolnix
# https://www.makemkv.com/
# brew cask install makemkv
# https://www.flixtools.com/
brew cask install flixtools

# https://www.charlesproxy.com/
brew cask install charles
brew cask install ngrok

# Messaging
brew cask install skype
# brew cask install google-hangouts
# brew cask install limechat
# brew cask install telegram
# brew cask install hipchat
# brew cask install whatsapp

# Productivity
brew cask install dropbox
# brew cask install google-drive
brew cask install evernote
# brew cask install skitch
# brew cask install jumpcut

# https://theunarchiver.com/archive-browser
# brew cask install the-archive-browser
# https://pngmini.com/
# brew cask install imagealpha

# Locking down to this version (no serial for later version)
# https://www.telestream.net/screenflow/
brew cask install https://raw.githubusercontent.com/grettir/homebrew-cask/36b240eeec68e993a928395d3afdcef1e32eb592/Casks/screenflow.rb

###############################################################################
# ZSH                                                                         #
###############################################################################

# Install Oh My ZSH
curl -L http://install.ohmyz.sh | sh

###############################################################################
# ALL DONE NOW!                                                               #
###############################################################################

echo -e "\n\033[93mSo, that should've installed all software for you …\033[0m"