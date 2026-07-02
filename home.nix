{ config, pkgs, ... }:
{
  home.username = "parven";
  home.homeDirectory = "/home/parven";
  home.stateVersion = "26.05";

  programs.git = {
    enable = true;
    userName = "Parven05";
    userEmail = "parven5@proton.me";
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
      build = "nh os switch /home/parven/dotfiles";
      clean = "nh clean all";
    };
  };

  home.file.".config/kitty".source = ./config/kitty;
}
