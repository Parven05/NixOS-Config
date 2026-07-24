# Swayidle idle manager — Home Manager

{ config, pkgs, ... }:
{
  home-manager.users.${config.user.name} = {
    services.swayidle.enable = true;
    services.swayidle.events."before-sleep" = "${pkgs.swaylock}/bin/swaylock -f";
  };
}
