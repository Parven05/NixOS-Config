# Fuzzel app launcher — Home Manager config

{ config, ... }:
{
  home-manager.users.${config.user.name}.xdg.configFile."fuzzel/fuzzel.ini".source = ../../../config/fuzzel/fuzzel.ini;
}
