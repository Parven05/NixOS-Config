# Quickshell — Home Manager config

{ config, ... }:
{
  home-manager.users.${config.user.name}.xdg.configFile."quickshell" = {
    source = ../../../config/quickshell;
    force = true;
  };
}
