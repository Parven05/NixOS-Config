# Awww wallpaper daemon — Home Manager systemd service

{ config, pkgs, ... }:
{
  home-manager.users.${config.user.name}.systemd.user.services.awww = {
    Unit = {
      Description = "Wallpaper daemon for awww";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
