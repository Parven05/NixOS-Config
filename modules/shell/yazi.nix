# Yazi file manager — Home Manager

{ config, ... }:
{
  home-manager.users.${config.user.name} = {
    home.activation = {
      removeOldYazi = ''
        if [ -e "$HOME/.config/yazi" ] || [ -L "$HOME/.config/yazi" ]; then
          rm -rf "$HOME/.config/yazi"
          echo "Removed old yazi config"
        fi
      '';
    };
    xdg.configFile."yazi" = {
      source = ../../config/yazi;
      force = true;
    };
  };
}
