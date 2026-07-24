# Niri config — static KDL file

{ config, ... }:
{
  home-manager.users.${config.user.name}.xdg.configFile."niri/config.kdl" = {
    source = ../../config/niri/config.kdl;
    force = true;
  };
}
