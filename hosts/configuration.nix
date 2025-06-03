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
    ./modules/kernel.nix
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

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";

}
