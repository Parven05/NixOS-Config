# Niri compositor — enable + portal

{ lib, pkgs, ... }:
{
  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config = {
      niri.default = lib.mkForce "gnome";
      common.default = "gtk";
    };
  };
}
