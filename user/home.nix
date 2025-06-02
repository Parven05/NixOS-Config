{ config, pkgs, ... }:

{
  # Enable Home Manager itself
  programs.home-manager.enable = true;

  # Set username and home directory
  home.username = "parven";
  home.homeDirectory = "/home/parven";
  home.stateVersion = "24.11";

  # Enable Bash and customize shell init
  programs.bash.enable = true;

  # Set session environment variables
  home.sessionVariables = {
    TERMINAL = "kitty";
  };
}

