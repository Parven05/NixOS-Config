# Swaylock screen locker — Home Manager

{ config, pkgs, ... }:
{
  home-manager.users.${config.user.name} = {
    programs.swaylock.enable = true;
  };
}
