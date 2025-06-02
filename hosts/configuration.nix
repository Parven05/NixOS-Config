# Edit this configuration file to define what should be installed on your system.
# Help: `man configuration.nix` or run `nixos-help`.

{ config, pkgs, ... }:

{

  nix.settings.experimental-features = ["nix-command" "flakes"];

  ##############################################
  # System Imports
  ##############################################
  imports = [
    ./hardware-configuration.nix
     # Modules

    ./modules/bootloader.nix
    ./modules/firmware.nix
    ./modules/timezone.nix
    ./modules/networking.nix
    ./modules/bluetooth.nix
    ./modules/user.nix
    ./modules/gnome.nix
  ];

  ##############################################
  # System Settings
  ##############################################
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";

  ##############################################
  # Audio
  ##############################################
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ##############################################
  # Gaming Support
  ##############################################
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;
  programs.nix-ld.enable = true;

  ##############################################
  # System-Wide Packages
  ##############################################
  environment.systemPackages = with pkgs; [
    wget git github-desktop vivaldi discord spotify bleachbit vlc gimp
    audacity obs-studio cheese lutris prismlauncher gnome-tweaks
    gnome-extension-manager podman distrobox telegram-desktop gnome-menus
    gobject-introspection neofetch corefonts powertop kitty xdg-utils
    dconf-editor helix cava tree
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];

  environment.variables.GI_TYPELIB_PATH = "${pkgs.gnome-menus}/lib/girepository-1.0";

  ##############################################
  # Extra Services
  ##############################################
  services = {
    openssh.enable = true;
    printing.enable = true;
    flatpak.enable = true;
  };
}
