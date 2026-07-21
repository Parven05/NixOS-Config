{ config, lib, pkgs, ... }:
with lib;
mkIf (config.my.desktop == "niri" || config.my.desktop == "both") {
  programs.niri.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

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


  environment.systemPackages = with pkgs; [
    kitty
    nautilus
    gnome-tweaks
    gnome-extension-manager
    file-roller
  ];
}
