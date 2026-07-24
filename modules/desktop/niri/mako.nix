# Mako notification daemon — Home Manager

{ config, lib, ... }:
{
  home-manager.users.${config.user.name}.services.mako = lib.mkForce {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 10";
      background-color = "#080808e6";
      border-radius = 8;
      border-size = 0;
    };
    extraConfig = ''
      [anchor=bottom-center]
      max-visible=1

      [hidden=true]
      invisible=1
    '';
  };
}
