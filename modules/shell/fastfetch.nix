# Fastfetch — Home Manager config

{ config, ... }:
{
  home-manager.users.${config.user.name}.xdg.configFile."fastfetch" = {
    source = ../../config/fastfetch;
    force = true;
  };
}
