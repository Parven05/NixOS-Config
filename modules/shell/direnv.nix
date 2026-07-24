# Direnv — NixOS + Home Manager

{ config, ... }:
let
  user = config.user.name;
in
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home-manager.users.${user}.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };
}
