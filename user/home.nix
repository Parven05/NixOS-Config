{ config, pkgs, ... }:

{
  # Set username and home directory
  home.username = "parven";
  home.homeDirectory = "/home/parven";
  home.stateVersion = "24.11";

  # Enable Bash and customize shell init
  programs.bash.enable = true;

  # Set session environment variables (for desktop sessions)
  home.sessionVariables = {
    TERMINAL = "kitty";
  };

  # Stylix theming (Gruvbox dark)
  stylix = {
    enable = true;

    base16Scheme = {
      slug = "gruvbox-dark-hard";
    };

    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
        name = "FiraCode Nerd Font Mono";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };

    cursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
    };

    targets.gnome.enable = true;  # Applies GTK theming
  };
}

