# Home Manager base — stateVersion, XDG

{ config, ... }:
let
  user = config.user.name;
in
{
  home-manager.users.${user} = {
    home = {
      stateVersion = "26.05";
      sessionPath = [ "$HOME/.local/bin" ];
      preferXdgDirectories = true;
    };

    xdg = {
      enable = true;
      autostart.enable = true;
      mime.enable = true;
      mimeApps.enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        music = null;
        publicShare = null;
        templates = null;
        videos = null;
      };
    };

    programs.home-manager.enable = true;
    systemd.user.startServices = "sd-switch";
  };
}
