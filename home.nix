{ config, pkgs, ... }:

{
  # Set username and home directory
  home.username = "parven";
  home.homeDirectory = "/home/parven";  # Must be absolute path
  home.stateVersion = "24.11";         # Match HM version used

  # Enable Bash and customize shell init
  programs.bash.enable = true;
  programs.git = {
    enable = true;
    userName = "Parven";
    userEmail = "parven5@proton.me";
  };
  
  # Set session environment variables (for desktop sessions)
  home.sessionVariables = {
    TERMINAL = "kitty";
  };
}
