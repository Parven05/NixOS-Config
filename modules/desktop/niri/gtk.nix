# GTK theming — Home Manager

{ config, lib, pkgs, ... }:
{
  home-manager.users.${config.user.name}.gtk = {
    enable = true;
    iconTheme = lib.mkForce {
      name = "Fluent";
      package = pkgs.fluent-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Original-Classic";
      package = pkgs.bibata-cursors;
    };
  };
}
