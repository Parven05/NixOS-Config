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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kuala_Lumpur";

  services.xserver = {
    enable = true;
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.displayManager.autoLogin = {
    enable = true;
    user = "parven";
  };

  # Use Kitty as terminal in GNOME extension
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

  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

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

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    git
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

    # Dev packages
    vscode
    cmake
    gnumake
    glib.dev
    zig
    devenv

  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

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

  services.flatpak.enable = true;

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
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
