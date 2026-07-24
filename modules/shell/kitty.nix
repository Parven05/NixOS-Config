# Kitty terminal — Home Manager config

{ config, ... }:
{
  home-manager.users.${config.user.name}.xdg.configFile."kitty" = {
    source = ../../config/kitty;
    force = true;
  };
}
