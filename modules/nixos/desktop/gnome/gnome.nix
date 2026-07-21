{ config, lib, pkgs, ... }:
with lib;
mkIf (config.my.desktop == "gnome" || config.my.desktop == "both") {
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
  };
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
    gnome-tweaks
    gnome-extension-manager
  ];
}
