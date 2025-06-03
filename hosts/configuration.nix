{ config, pkgs, ... }:

{

  nix.settings.experimental-features = ["nix-command" "flakes"];

  imports = [
    ./hardware-configuration.nix
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
  
  system.stateVersion = "24.11";
}
