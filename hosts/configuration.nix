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
    ./modules/audio.nix
    ./modules/gaming.nix
    ./modules/systempkgs.nix
    ./modules/services.nix
  ];

  ##############################################
  # System Settings
  ##############################################
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";

  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];

  environment.variables.GI_TYPELIB_PATH = "${pkgs.gnome-menus}/lib/girepository-1.0";

  ##############################################
  # Extra Services
  ##############################################

}
