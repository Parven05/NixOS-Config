# Waybar — Home Manager config

{ config, ... }:
{
  home-manager.users.${config.user.name}.xdg.configFile."waybar" = {
    source = ../../config/waybar;
    force = true;
  };
}
