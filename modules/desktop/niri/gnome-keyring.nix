# GNOME Keyring — Home Manager

{ config, ... }:
{
  home-manager.users.${config.user.name}.services.gnome-keyring.enable = true;
}
