{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ------------------------------------------------------------------
  # Boot
  # ------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ------------------------------------------------------------------
  # Garbage Collection
  # ------------------------------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 1d";
  };

  boot.loader.systemd-boot.configurationLimit = 3;

  # ------------------------------------------------------------------
  # Networking
  # ------------------------------------------------------------------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Kuala_Lumpur";

  # ------------------------------------------------------------------
  # Desktop environment
  # ------------------------------------------------------------------
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
  };
  services.displayManager.gdm.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "parven";
  };
  services.desktopManager.gnome.enable = true;

  # Use Kitty as terminal in GNOME's "Open Terminal Here"
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  # Remove unnecessary GNOME apps
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    yelp
    totem
    geary
    seahorse
    snapshot
    gnome-tour
    gnome-contacts
    gnome-maps
    gnome-weather
    gnome-music
    gnome-characters
    gnome-software
    gnome-connections
  ];

  # ------------------------------------------------------------------
  # Hardware / services
  # ------------------------------------------------------------------
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
  services.flatpak.enable = true;

  # ------------------------------------------------------------------
  # Shell / user
  # ------------------------------------------------------------------
  programs.fish.enable = true;

  users.users.parven = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "bluetooth"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # ------------------------------------------------------------------
  # System packages
  # ------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    firefox
    kitty
    discord
    vlc
    obs-studio
    fastfetch
    gnome-tweaks
    gnome-extension-manager
    btop
    nixfmt
    eza
    bat
    zoxide
    tmux
    # Dev packages
    wget
    git
    vscode
    cmake
    gnumake
    glib.dev
    zig
    devenv
    gitui
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # ------------------------------------------------------------------
  # Stylix theming
  # ------------------------------------------------------------------
  stylix.enable = true;
  stylix.image = ./wallpapers/nix-wallpaper-binary-black_8k.png;
  stylix.polarity = "dark";
  stylix.base16Scheme = {
    base00 = "111418"; # near-black
    base01 = "181c22"; # dark slate
    base02 = "1f242b"; # charcoal
    base03 = "6e7681"; # slate gray
    base04 = "8b97a3"; # cool gray
    base05 = "c9d1d9"; # light gray
    base06 = "e6e9ed"; # pale gray
    base07 = "f0f2f5"; # off-white
    base08 = "be5a55"; # red
    base09 = "be825a"; # orange
    base0A = "c8aa5a"; # amber
    base0B = "6eaa82"; # green
    base0C = "5aaaaf"; # teal
    base0D = "6ea8e0"; # blue
    base0E = "aa82aa"; # purple
    base0F = "a892b8"; # mauve
  };

  # ------------------------------------------------------------------
  # CLI tooling
  # ------------------------------------------------------------------
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/parven/dotfiles";
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
    };
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
