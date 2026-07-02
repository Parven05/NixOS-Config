{ config, lib, pkgs, ... }:
{
  imports =
    [
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
  services.xserver.excludePackages = [pkgs.xterm];
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
    epiphany yelp totem geary seahorse snapshot
    gnome-tour gnome-contacts gnome-maps gnome-weather 
    gnome-music gnome-characters gnome-software gnome-connections
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
    extraGroups = [ "wheel" "networkmanager" "video" "bluetooth"];
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
    vscode
  ] ++ (with pkgs.gnomeExtensions; [
    blur-my-shell
    burn-my-windows
    compiz-alike-magic-lamp-effect
    compiz-windows-effect
    dash-to-dock
    tray-icons-reloaded
    user-themes
  ]);

  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  services.flatpak.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}