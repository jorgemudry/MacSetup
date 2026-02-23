#!/usr/bin/env bash

if [ "${MACSETUP_MAIN:-}" != "true" ]; then
    echo "This script must be run from start.sh!"
    exit 1
fi
source ./scripts/common.sh

function housekeeping {
    # Close any open System Settings/Preferences panes, to prevent them from overriding
    # settings we’re about to change
    osascript -e ‘tell application "System Settings" to quit’ 2>/dev/null
    osascript -e ‘tell application "System Preferences" to quit’ 2>/dev/null
}

function naming_things {
    echo -e "\n${BLUE}=== Naming Things ===${NC}"
    COMPUTERNAME="$(hostname)"
    if [[ "${MACSETUP_NONINTERACTIVE:-}" != "true" ]]; then
        echo -ne "${BLUE}What should your computer be named? (default: ${COMPUTERNAME}): ${NC}"
        read -r
        if [[ -n "$REPLY" ]]; then
            if [[ "$REPLY" =~ ^[a-zA-Z0-9._-]+$ ]]; then
                COMPUTERNAME=$REPLY
            else
                echo -e "${RED}Invalid name. Use only letters, numbers, dots, hyphens, and underscores.${NC}"
            fi
        fi
    fi
    execute_command "Set computer name" "sudo scutil --set ComputerName '${COMPUTERNAME}'"
    execute_command "Set hostname" "sudo scutil --set HostName '${COMPUTERNAME}'"
    execute_command "Set localhost name" "sudo scutil --set LocalHostName '${COMPUTERNAME}'"
    execute_command "Set NetBIOSName name" "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string '${COMPUTERNAME}'"

    if defaults read NSGlobalDomain AppleID 2>&1 | grep -qE "( does not exist)$"; then
        AppleID=""
    else
        AppleID="$(defaults read NSGlobalDomain AppleID)"
    fi
    if [[ "${MACSETUP_NONINTERACTIVE:-}" != "true" ]]; then
        echo -ne "${BLUE}What's your Apple ID? (default: $AppleID): ${NC}"
        read -r
        [ -n "$REPLY" ] && AppleID=$REPLY
    fi

    if [ -n "$AppleID" ]; then
        execute_command "Set AppleID" "defaults write NSGlobalDomain AppleID -string '${AppleID}'"
    fi
}

function date_time {
    echo -e "\n${BLUE}=== Date & Time ===${NC}"
    execute_command "Set network time on" "sudo /usr/sbin/systemsetup -setusingnetworktime on > /dev/null"
}

function general_uiux {
    echo -e "\n${BLUE}=== General UI/UX ===${NC}"
    # Set sidebar icon size to medium
    execute_command "Set sidebar icon size to medium" "defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2"

    # Always show scrollbars
    # Possible values: `WhenScrolling`, `Automatic` and `Always`
    execute_command "Always show scrollbars (Always)" "defaults write NSGlobalDomain AppleShowScrollBars -string 'Always'"

    # Expand save panel by default
    execute_command "Expand save panel by default" "defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true"
    execute_command "Expand save panel by default (version 2)" "defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true"

    # Expand print panel by default
    execute_command "Expand print panel by default" "defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true"
    execute_command "Expand print panel by default (version 2)" "defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true"

    # Save to disk (not to iCloud) by default
    execute_command "Save to disk (not iCloud) by default" "defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false"

    # Automatically quit printer app once the print jobs complete
    execute_command "Automatically quit printer app after print jobs" "defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true"

    # Disable the “Are you sure you want to open this application?” dialog
    execute_command "Disable 'Are you sure you want to open this application?' dialog" "defaults write com.apple.LaunchServices LSQuarantine -bool false"

    # Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
    execute_command "Remove duplicates in 'Open With' menu" "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user"

    # Display ASCII control characters using caret notation in standard text views
    execute_command "Display ASCII control characters using caret notation" "defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true"

    # Disable Resume system-wide
    execute_command "Disable Resume system-wide" "defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false"

    # Disable automatic termination of inactive apps
    execute_command "Disable automatic termination of inactive apps" "defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true"

    # Disable the crash reporter
    # execute_command "Disable the crash reporter" "defaults write com.apple.CrashReporter DialogType -string 'none'"

    # Make Crash Reporter appear as a notification
    execute_command "Make Crash Reporter appear as a notification" "defaults write com.apple.CrashReporter UseUNC 1"

    # Restart automatically if the computer freezes
    # execute_command "Restart automatically if the computer freezes" "sudo systemsetup -setrestartfreeze on"

    # Disable automatic capitalization as it’s annoying when typing code
    execute_command "Disable automatic capitalization" "defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false"

    # Disable smart dashes as they’re annoying when typing code
    execute_command "Disable smart dashes" "defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false"

    # Disable automatic period substitution as it’s annoying when typing code
    execute_command "Disable automatic period substitution" "defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false"

    # Disable smart quotes as they’re annoying when typing code
    execute_command "Disable smart quotes" "defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false"

    # Disable auto-correct
    execute_command "Disable auto-correct" "defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false"

    # Set highlight color to green
    execute_command "Set highlight color to green" "defaults write NSGlobalDomain AppleHighlightColor -string '0.764700 0.976500 0.568600'"

    # Set Help Viewer windows to non-floating mode
    execute_command "Set Help Viewer windows to non-floating mode" "defaults write com.apple.helpviewer DevMode -bool true"

}

function touchbar {
    echo -e "\n${BLUE}=== Touch Bar ===${NC}"
    # Skip on Apple Silicon — no arm64 Mac has a Touch Bar
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo -e "${YELLOW}Skipping Touch Bar settings (not available on Apple Silicon)${NC}"
        return 0
    fi
    execute_command "Always display full control strip (ignoring App Controls)" "defaults write com.apple.touchbar.agent PresentationModeGlobal fullControlStrip"
}

function trackpad_input {
    echo -e "\n${BLUE}=== Input Devices ===${NC}"
    # Trackpad: enable tap to click for this user and for the login screen
    execute_command "Enable tap to click (Trackpad - user)" "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true"
    execute_command "Enable tap to click (Trackpad - login screen)" "defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true"
    execute_command "Enable tap to click (Mouse - current user)" "defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1"
    execute_command "Enable tap to click (Mouse - global)" "defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1"

    # Trackpad: map bottom right corner to right-click
    execute_command "Map bottom right corner to right-click" "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2"
    execute_command "Enable right-click with two fingers" "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true"
    execute_command "Enable right-click (global setting)" "defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1"
    execute_command "Enable secondary click" "defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true"

    # Enable extra multifinger gestures (such as three finger swipe down = app expose)
    execute_command "Enable Mission Control gesture" "defaults write com.apple.dock showMissionControlGestureEnabled -bool true"
    execute_command "Enable App Exposé gesture" "defaults write com.apple.dock showAppExposeGestureEnabled -bool true"
    execute_command "Enable Show Desktop gesture" "defaults write com.apple.dock showDesktopGestureEnabled -bool true"
    execute_command "Enable Launchpad gesture" "defaults write com.apple.dock showLaunchpadGestureEnabled -bool true"

    # Two button mouse mode
    execute_command "Enable Two Button Mouse Mode" "defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string TwoButton"

    # Set Mouse speed
    execute_command "Set Mouse speed" "defaults write NSGlobalDomain com.apple.mouse.scaling -int 2"
    execute_command "Set Scroll Wheel scaling" "defaults write NSGlobalDomain com.apple.scrollwheel.scaling -float 0.215"
    execute_command "Set Trackpad speed" "defaults write NSGlobalDomain com.apple.trackpad.scaling -float 0.875"

    # Set Mouse Springing
    execute_command "Enable Mouse Springing" "defaults write NSGlobalDomain com.apple.springing.enabled -int 1"
    execute_command "Set Mouse Springing delay" "defaults write NSGlobalDomain com.apple.springing.delay -float 0.25"

    # Increase sound quality for Bluetooth headphones/headsets
    # NOTE: May not work on macOS Sonoma+
    execute_command "Increase Bluetooth audio quality" "defaults write com.apple.BluetoothAudioAgent 'Apple Bitpool Min (editable)' -int 40"

    # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
    execute_command "Enable full keyboard access for all controls" "defaults write NSGlobalDomain AppleKeyboardUIMode -int 2"

    # Disable press-and-hold for keys in favor of key repeat
    execute_command "Disable press-and-hold for keys (enable key repeat)" "defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false"

    # Set a fast keyboard repeat rate
    execute_command "Set fast keyboard repeat rate" "defaults write NSGlobalDomain KeyRepeat -int 1"

    # Set language and text formats
    execute_command "Set measurement units to Centimeters" "defaults write NSGlobalDomain AppleMeasurementUnits -string 'Centimeters'"
    execute_command "Set temperature unit to Celsius" "defaults write NSGlobalDomain AppleTemperatureUnit -string 'Celsius'"
    execute_command "Enable metric system" "defaults write NSGlobalDomain AppleMetricUnits -bool true"
    execute_command "Set 24-hour time format" "defaults write NSGlobalDomain AppleICUForce12HourTime -bool false"

    # Set Lock Message to show on login screen
    execute_command "Set Lock Message on login screen" "sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText -string 'Found me? Shoot a mail to jorgemudry@gmail.com to return me. Thanks.'"

    # Disable guest login
    execute_command "Disable guest login" "sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false"

    # Automatically illuminate built-in MacBook keyboard in low light
    execute_command "Automatically illuminate keyboard in low light" "defaults write com.apple.BezelServices kDim -bool true"

    # Turn off keyboard illumination when computer is not used for 5 minutes
    execute_command "Turn off keyboard illumination after 5 minutes" "defaults write com.apple.BezelServices kDimTime -int 300"
}

function screen_settings {
    echo -e "\n${BLUE}=== Screen Settings ===${NC}"
    # Require password immediately after sleep or screen saver begins
    # NOTE: May not work on macOS Sonoma+
    execute_command "Require password after sleep or screensaver" "defaults write com.apple.screensaver askForPassword -int 1"
    execute_command "Set screensaver password delay to 0 seconds" "defaults write com.apple.screensaver askForPasswordDelay -int 0"

    # Set screensaver to Flurry, start after 20 minutes
    execute_command "Set screensaver to Flurry" "defaults -currentHost write com.apple.screensaver moduleDict -dict path -string '/System/Library/Screen Savers/Flurry.saver' moduleName -string 'Flurry' type -int 0"
    execute_command "Set screensaver idle time to 20 minutes" "defaults -currentHost write com.apple.screensaver idleTime -int 1200"

    # Save screenshots to ~/Pictures/screenshots
    execute_command "Create ~/Pictures/screenshots directory" "mkdir -p ~/Pictures/screenshots"
    execute_command "Set screenshots save location to ~/Pictures/screenshots" "defaults write com.apple.screencapture location -string '${HOME}/Pictures/screenshots'"

    # Save screenshots in PNG format
    execute_command "Set screenshot format to PNG" "defaults write com.apple.screencapture type -string 'png'"

    # Disable shadow in screenshots
    execute_command "Disable screenshot shadow" "defaults write com.apple.screencapture disable-shadow -bool true"

    # Enable subpixel font rendering on non-Apple LCDs
    execute_command "Enable subpixel font rendering on non-Apple LCDs" "defaults write NSGlobalDomain AppleFontSmoothing -int 1"

    # Enable HiDPI display modes (requires restart)
    execute_command "Enable HiDPI display modes (requires restart)" "sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true"
}

function finder_settings {
    echo -e "\n${BLUE}=== Finder ===${NC}"
    # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
    execute_command "Enable Finder quitting via ⌘ + Q" "defaults write com.apple.finder QuitMenuItem -bool true"

    # Finder: disable window animations and Get Info animations
    execute_command "Disable Finder window and Get Info animations" "defaults write com.apple.finder DisableAllAnimations -bool true"

    # Set Home as the default location for new Finder windows
    execute_command "Set Finder default location to Home" "defaults write com.apple.finder NewWindowTarget -string 'PfLo'"
    execute_command "Set Finder NewWindowTargetPath to Home" "defaults write com.apple.finder NewWindowTargetPath -string 'file://${HOME}/'"

    # Hide icons for hard drives, servers, and removable media from the desktop
    execute_command "Hide hard drives from desktop" "defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false"
    execute_command "Hide mounted servers from desktop" "defaults write com.apple.finder ShowMountedServersOnDesktop -bool false"
    execute_command "Hide external hard drives from desktop" "defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false"
    execute_command "Hide removable media from desktop" "defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false"

    # Finder showX settings
    execute_command "Hide Recent Tags in Finder" "defaults write com.apple.finder ShowRecentTags -bool false"
    execute_command "Show Sidebar in Finder" "defaults write com.apple.finder ShowSidebar -bool true"
    execute_command "Show Status Bar in Finder" "defaults write com.apple.finder ShowStatusBar -bool true"
    execute_command "Show Tab View in Finder" "defaults write com.apple.finder ShowTabView -bool true"
    execute_command "Hide Preview Pane in Finder" "defaults write com.apple.finder ShowPreviewPane -bool false"
    execute_command "Show Path Bar in Finder" "defaults write com.apple.finder ShowPathbar -bool true"

    # Finder: show all filename extensions
    execute_command "Show all filename extensions" "defaults write NSGlobalDomain AppleShowAllExtensions -bool true"

    # Display full POSIX path as Finder window title
    execute_command "Display full POSIX path in Finder window title" "defaults write com.apple.finder _FXShowPosixPathInTitle -bool true"

    # Keep folders on top when sorting by name
    execute_command "Keep folders on top when sorting by name" "defaults write com.apple.finder _FXSortFoldersFirst -bool true"

    # When performing a search, search the current folder by default
    execute_command "Set Finder search to current folder by default" "defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'"

    # Disable the warning when changing a file extension
    execute_command "Disable warning when changing file extensions" "defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false"

    # Enable spring loading for directories
    execute_command "Enable spring loading for directories" "defaults write NSGlobalDomain com.apple.springing.enabled -bool true"

    # Set small spring loading delay for directories
    execute_command "Set small spring loading delay" "defaults write NSGlobalDomain com.apple.springing.delay -float 0.5"

    # Avoid creating .DS_Store files on network or USB volumes
    execute_command "Avoid creating .DS_Store files on network volumes" "defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true"
    execute_command "Avoid creating .DS_Store files on USB volumes" "defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true"

    # Use list view in all Finder windows by default
    execute_command "Set Finder default view mode to List" "defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'"

    # Disable the warning before emptying the Trash
    execute_command "Disable warning before emptying Trash" "defaults write com.apple.finder WarnOnEmptyTrash -bool false"

    # Enable AirDrop over Ethernet and on unsupported Macs running Lion
    execute_command "Enable AirDrop over Ethernet and unsupported Macs" "defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true"

    # Show the ~/Library folder
    execute_command "Show ~/Library folder" "chflags nohidden ~/Library"

    # Show the /Volumes folder
    execute_command "Show /Volumes folder" "sudo chflags nohidden /Volumes"

    # Expand File Info panes: “General”, “Open with”, and “Sharing & Permissions”
    execute_command "Expand Finder Info panes (General, Open With, Permissions)" "defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true"
}

function dock_settings {
    echo -e "\n${BLUE}=== Dock ===${NC}"
    # Enable highlight hover effect for the grid view of a stack (Dock)
    execute_command "Enable highlight hover effect for stack grid view" "defaults write com.apple.dock mouse-over-hilite-stack -bool true"

    # Set the icon size of Dock items to 36 pixels
    execute_command "Set Dock icon size to 36 pixels" "defaults write com.apple.dock tilesize -int 36"

    # Change minimize/maximize window effect
    execute_command "Set minimize/maximize effect to scale" "defaults write com.apple.dock mineffect -string 'scale'"

    # Minimize windows into their application’s icon
    execute_command "Minimize windows into application’s icon" "defaults write com.apple.dock minimize-to-application -bool true"

    # Enable spring loading for all Dock items
    execute_command "Enable spring loading for Dock items" "defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true"

    # Show indicator lights for open applications in the Dock
    execute_command "Show indicator lights for open applications" "defaults write com.apple.dock show-process-indicators -bool true"

    # Wipe all (default) app icons from the Dock
    execute_command "Remove all default app icons from Dock" "defaults write com.apple.dock persistent-apps -array"

    # Show only open applications in the Dock
    execute_command "Show only open applications in Dock" "defaults write com.apple.dock static-only -bool true"

    # Don’t animate opening applications from the Dock
    execute_command "Disable animation when opening applications" "defaults write com.apple.dock launchanim -bool false"

    # Speed up Mission Control animations
    execute_command "Speed up Mission Control animations" "defaults write com.apple.dock expose-animation-duration -float 0.1"

    # Don’t group windows by application in Mission Control
    execute_command "Disable window grouping in Mission Control" "defaults write com.apple.dock expose-group-by-app -bool false"

    # Don’t automatically rearrange Spaces based on most recent use
    execute_command "Disable automatic rearranging of Spaces" "defaults write com.apple.dock mru-spaces -bool false"

    # Remove the auto-hiding Dock delay
    execute_command "Remove auto-hide delay for Dock" "defaults write com.apple.dock autohide-delay -float 0"

    # Remove the animation when hiding/showing the Dock
    execute_command "Remove Dock hide/show animation" "defaults write com.apple.dock autohide-time-modifier -float 0"

    # Automatically hide and show the Dock
    execute_command "Enable auto-hide for Dock" "defaults write com.apple.dock autohide -bool true"

    # Make Dock icons of hidden applications translucent
    execute_command "Make Dock icons of hidden applications translucent" "defaults write com.apple.dock showhidden -bool true"

    # Hot corners
    # Possible values:
    #  0: no-op
    #  2: Mission Control
    #  3: Show application windows
    #  4: Desktop
    #  5: Start screen saver
    #  6: Disable screen saver
    #  7: Dashboard
    # 10: Put display to sleep
    # 11: Launchpad
    # 12: Notification Center

    # Top right screen corner → Start screen saver
    execute_command "Set top-right hot corner to start screen saver" "defaults write com.apple.dock wvous-tr-corner -int 5"
    execute_command "Set top-right hot corner modifier to none" "defaults write com.apple.dock wvous-tr-modifier -int 0"

}

function activity_monitor {
    echo -e "\n${BLUE}=== Activity Monitor ===${NC}"
    # Show the main window when launching Activity Monitor
    execute_command "Show main window on Activity Monitor launch" "defaults write com.apple.ActivityMonitor OpenMainWindow -bool true"

    # Show all processes in Activity Monitor
    execute_command "Show all processes in Activity Monitor" "defaults write com.apple.ActivityMonitor ShowCategory -int 0"

    # Show Data in the Disk graph (instead of IO)
    execute_command "Show Data in Disk graph instead of IO" "defaults write com.apple.ActivityMonitor DiskGraphType -int 1"

    # Show Data in the Network graph (instead of packets)
    execute_command "Show Data in Network graph instead of packets" "defaults write com.apple.ActivityMonitor NetworkGraphType -int 1"

}

function misc_apps {
    echo -e "\n${BLUE}=== Misc Apps ===${NC}"
    # Enable the debug menu in Disk Utility
    execute_command "Enable Disk Utility debug menu" "defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true"
    execute_command "Enable advanced image options in Disk Utility" "defaults write com.apple.DiskUtility advanced-image-options -bool true"

    # Auto-play videos when opened with QuickTime Player
    execute_command "Enable auto-play for videos in QuickTime Player" "defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true"

}

function appstore {
    echo -e "\n${BLUE}=== App Store ===${NC}"
    # Enable the WebKit Developer Tools in the Mac App Store
    execute_command "Enable WebKit Developer Tools in App Store" "defaults write com.apple.appstore WebKitDeveloperExtras -bool true"

    # Enable Debug Menu in the Mac App Store
    execute_command "Enable Debug Menu in App Store" "defaults write com.apple.appstore ShowDebugMenu -bool true"

    # Enable the automatic update check
    execute_command "Enable automatic update check" "defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true"

    # Check for software updates daily instead of weekly
    execute_command "Set software update check frequency to daily" "defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1"

    # Download newly available updates in background
    execute_command "Enable background download of updates" "defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1"

    # Install system data files & security updates
    execute_command "Enable automatic installation of system data & security updates" "defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1"

    # Don't automatically download apps purchased on other Macs
    execute_command "Disable automatic download of apps purchased on other Macs" "defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 0"

    # Turn on app auto-update
    execute_command "Enable automatic app updates" "defaults write com.apple.commerce AutoUpdate -bool true"

    # Allow the App Store to reboot machine on macOS updates
    execute_command "Allow App Store to reboot machine for macOS updates" "defaults write com.apple.commerce AutoUpdateRestartRequired -bool true"
}

function photos {
    echo -e "\n${BLUE}=== Photos ===${NC}"
    execute_command "Disable Photos auto-launch when device is plugged in" "defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true"
}

function kill_affected_applications {
    pkill "Touch Bar agent";
    for app in "Activity Monitor" \
    	"Address Book" \
    	"cfprefsd" \
    	"Dock" \
    	"Finder" \
    	"Messages" \
    	"Photos" \
    	"Safari" \
    	"ControlStrip" \
    	"SystemUIServer"; do
    	killall "${app}" &> /dev/null
    done
}

if ! check_sudo; then
    echo -e "\n${RED}Authentication failed.${NC}"
    press_any_key
    exit 0
fi

# Keep-alive: update existing `sudo` time stamp
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!
trap "kill $SUDO_PID 2>/dev/null" EXIT

housekeeping
naming_things
date_time
general_uiux
touchbar
trackpad_input
screen_settings
finder_settings
dock_settings
activity_monitor
misc_apps
appstore
photos
kill_affected_applications
askforreboot