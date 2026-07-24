# NH — NixOS rebuild helper

{ config, ... }:
let
  user = config.user.name;
in
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${user}/Pi-Nix";
  };
}
