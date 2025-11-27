# TAPS (Homebrew sources / repositories)
tap "homebrew/core"
tap "homebrew/cask"
tap "buo/cask-upgrade"

###############################################################################
# BREW FORMULAS
###############################################################################

# 1) General CLI utilities (https://remysharp.com/2018/08/23/cli-improved)

brew "bat"               # Improved 'cat' with syntax highlighting (https://github.com/sharkdp/bat)
brew "diff-so-fancy"     # Better 'diff' output (https://github.com/so-fancy/diff-so-fancy)
brew "fd"                # Simple, fast and user-friendly alternative to 'find' (https://github.com/sharkdp/fd/)
brew "fzf"               # Fuzzy finder for the command line (https://github.com/junegunn/fzf)
brew "git"               # Distributed version control
brew "htop"              # Interactive process viewer
brew "httpie"            # User-friendly HTTP CLI client
brew "jq"                # JSON processor
brew "mackup"            # Backup/restore configs in the cloud
brew "mas"               # Mac App Store command line interface
brew "midnight-commander"# Terminal-based file manager
brew "ncdu"              # Disk usage analyzer in the terminal (https://dev.yorhel.nl/ncdu)
brew "prettyping"        # Prettier, more colorful ping output (http://denilson.sa.nom.br/prettyping/)
brew "pv"                # Monitor the progress of data through a pipe
brew "rename"            # Perl-powered file rename utility
brew "speedtest-cli"     # Command line interface for speedtest.net
brew "ssh-copy-id"       # Install SSH keys on a server
brew "tldr"              # Simplified and community-driven man pages (https://tldr.sh/)
brew "tree"              # Display directories as trees (recursive listing)
# brew "vim", args: { force: true, overwrite: true }  # Command-line text editor
brew "wget"              # Network downloader
brew "zsh", link: true, conflicts_with: ["zsh-completion"]    # Oh My Zsh is an open source, community-driven framework for managing your zsh configuration.

# 2) Programming languages / environment
# brew "cryptography", restart_service: true  # Python cryptography library
# brew "php", link: true, conflicts_with: ["php@7.4", "php@8.0", "php@8.1", "php@8.2", "php@8.3"] # PHP language
brew "pipx"              # Install and run Python CLI apps in isolation
brew "pyenv"             # Python versions management
brew "python@3.13", link: true, conflicts_with: ["python", "python3"]       # Python 3.13 (latest major version)
# brew "ruby", args: { force: true }

# 3) DevOps, Cloud & Networking
brew "awscli"            # AWS command-line interface
brew "cloudflared"       # Cloudflare's tunnel CLI
brew "openshift-cli" # OpenShift command-line tools

# 4) Security / Pentesting / CTF tools (https://github.com/ctfs/write-ups)
# brew "bfg"
# brew "binutils"
# brew "binwalk"
# brew "cifer"
# brew "dex2jar"
# brew "dns2tcp"
# brew "fcrackzip"
# brew "foremost"
# brew "hashpump"
# brew "hydra"
# brew "john"
# brew "knock"
brew "nmap"                 # Network/port scanner
# brew "pngcheck"
# brew "socat"
brew "sqlmap" # SQL injection testing tool
# brew "tcpflow"
# brew "tcpreplay"
# brew "tcptrace"
# brew "ucspi-tcp"
# brew "xpdf"
# brew "xz"
# brew "wpscanteam/tap/wpscan" # WordPress security scanner (from WPScan tap)

# 5) Multimedia & Processing
brew "ffmpeg"            # Video/audio conversion and manipulation
brew "handbrake"         # Video transcoder (https://handbrake.fr/)
brew "harfbuzz"          # Text shaping engine
brew "glib"              # Core app building blocks (GTK, GNOME, etc.)
brew "libvpx"            # VP8/VP9 video codec library
brew "libzip"            # Library for reading/creating ZIP archives
brew "tesseract"         # OCR engine
brew "webkit2png"        # Convert web pages to PNG images
brew "yt-dlp"            # YouTube downloader (community maintained fork)

# 6) Miscellaneous
# brew "wallpaper"         # CLI to set wallpapers
# brew "wimlib"            # Tools to handle WIM archives (Windows Imaging Format)

###############################################################################
# CASKS (GUI applications)
###############################################################################

# 1) Browsers
cask "brave-browser"
cask "firefox"
cask "google-chrome"
cask "microsoft-edge"

# 2) Communication & messaging
cask "discord"
cask "slack"
cask "telegram"
cask "whatsapp"

# 3) Productivity & system utilities
cask "alfred"               # Productivity launcher
cask "dropbox"              # Cloud file sync
cask "keepingyouawake"      # Prevent system sleep
cask "notion"               # Note-taking & collaboration
# cask "obsidian"             # Markdown-based note-taking
cask "rectangle"            # Window management
cask "suspicious-package"   # Inspect .pkg installers
cask "shottr"               # Screenshot measurement and annotation tool

# Quick Look Plugins
cask "provisionql"       # QuickLook for .mobileprovision files
cask "qlcolorcode"       # QuickLook syntax highlighting
cask "qlvideo"           # QuickLook plugin for video thumbnails
cask "quicklook-json"    # QuickLook JSON files

# 4) Development / DevOps
# cask "dynobase"                       # GUI for DynamoDB
# cask "insomnia"                         # API client for REST/GraphQL
cask "iterm2", args: { force: true }    # Enhanced terminal emulator
cask "jdownloader"                      # Download manager
# cask "ngrok"                          # Secure tunnels to localhost
cask "orbstack"                         # Docker/WSL-like environment for macOS
cask "postman"                          # API development environment
cask "rapidapi"                         # RapidAPI client
cask "apidog"                           # APIDog client
cask "sequel-ace"                       # GUI for MySQL/MariaDB
cask "sublime-text"                     # Text/code editor
cask "tableplus"                        # Database GUI client
cask "visual-studio-code", args: { force: true }   # Code editor (VS Code)
cask "font-fira-code"                   # Fira Code Font (https://github.com/tonsky/FiraCode/wiki/Installing)

# 5) Multimedia / Entertainment
cask "android-file-transfer"
cask "spotify"
cask "vlc"

# 6) AI
cask "claude"                   # Anthropic's official Claude AI desktop app
cask "claude-code"              # Terminal-based AI coding assistant
cask "chatgpt"                  # OpenAI's official ChatGPT desktop app
brew "gemini-cli"               # Interact with Google Gemini AI models from the command-line

###############################################################################
# MAS (Mac App Store apps)
###############################################################################
mas "Microsoft OneNote", id: 784801555
mas "Stockfish", id: 801463932
mas "The Unarchiver", id: 425424353
mas "WireGuard", id: 1451685025