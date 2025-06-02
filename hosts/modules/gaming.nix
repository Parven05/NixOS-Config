{config, pkgs, lib, ... }:

{
  programs.steam = {
  enable = true;
  gamescopeSession.enable = true;
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
  
  };

  programs.gamemode.enable = true;
  programs.nix-ld.enable = true;

}
