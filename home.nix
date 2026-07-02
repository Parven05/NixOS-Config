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

    interactiveShellInit = ''
      zoxide init fish | source
    '';

    shellAliases = {
      # system alias
      btw = "echo i use nixos, btw";
      build = "nh os switch /home/parven/dotfiles";
      clean = "nh clean all";
      # tools alias
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first";
      la = "eza -a --icons --group-directories-first";
      cat = "bat";
    };
  };

  home.file.".config/kitty".source = ./config/kitty;
}
