{ pkgs, ... }:

{
  # If you use Determinate Nix Installer (recommended), let it manage Nix itself.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    # Leave anything not listed here installed; switch to "uninstall"/"zap" to enforce the list.
    onActivation.cleanup = "none";
    taps = [
      "can1357/tap"
      "darrylmorley/whatcable"
      "pantsbuild/tap"
    ];
    brews = [
      "aircrack-ng"
      "apktool"
      "atuin"
      "awscli"
      "black"
      "btop"
      "cmake"
      "colima"
      "dive"
      "docker"
      "docker-buildx"
      "docker-compose"
      "ffmpeg"
      "fnm"
      "fzf"
      "gh"
      "ghidra"
      "glpk"
      "gradle"
      "htop"
      "jadx"
      "jq"
      "lazygit"
      "libomp"
      "magic-wormhole"
      "mas"
      "maven"
      "ncdu"
      "nono"
      "can1357/tap/omp"
      "openjdk@25"
      "poppler"
      "postgresql@18"
      "pre-commit"
      "pygobject3"
      "python@3.12"
      "qalculate-gtk"
      "rbenv"
      "reaver"
      "ripgrep"
      "rtk"
      "ruby"
      "ruff"
      "stow"
      "stu"
      "tabiew"
      "tmux"
      "topgrade"
      "tree"
      "uv"
      "wget"
      "darrylmorley/whatcable/whatcable-cli"
      "zoxide"
    ];
    casks = [
      "alienator88-sentinel"
      "android-file-transfer"
      "android-platform-tools"
      "bit-slicer"
      "bruno"
      "cmux"
      "codex"
      "coteditor"
      "cutter"
      "db-browser-for-sqlite"
      "dbeaver-community"
      "firefox@developer-edition"
      "flameshot"
      "ghostty@tip"
      "godot"
      "gram"
      "hex-fiend"
      "impactor"
      "iterm2"
      "itsycal"
      "jetbrains-toolbox"
      "jordanbaird-ice"
      "keepingyouawake"
      "keka"
      "localsend"
      "middleclick"
      "neovide-app"
      "onlyoffice"
      "pantsbuild/tap/pants"
      "processspy"
      "raycast"
      "rectangle"
      "stats"
      "sublime-merge"
      "sublime-text"
      "temurin"
      "temurin@17"
      "tor-browser"
      "visual-studio-code"
      "vlc"
      "wezterm@nightly"
      "zen"
      "alt-tab"
      "anydesk"
      "claude"
      "drawio"
      "google-chrome"
      "google-drive"
      "helium-browser"
      "kde-connect"
      "libreoffice"
      "notion"
      "obsidian"
      "phoenix-code"
      "slack"
      "tailscale-app"
      "unity-hub"
      "zed"
      "zoom"
    ];
  };

  system.primaryUser = "w";
  users.users.w = {
    home = "/Users/w";
    shell = pkgs.zsh;
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      "com.apple.swipescrolldirection" = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      AppleShowAllExtensions = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };

    trackpad = {
      Clicking = true;
    };

    dock.autohide = true;
  };

  environment.systemPath = [
    "/run/current-system/sw/bin"
    "/etc/profiles/per-user/w/bin"
  ];

  system.stateVersion = 6;
}
