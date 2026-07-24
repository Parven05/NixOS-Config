# Starship prompt — NixOS + Home Manager

{ config, ... }:
let
  user = config.user.name;
in
{
  programs.starship.enable = true;

  home-manager.users.${user}.programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
    };
  };
}
