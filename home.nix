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

      if test "$TERM" = "xterm-kitty"
        fastfetch
      end
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

  gtk = {
    enable = true;

    iconTheme = {
      name = "Fluent";
      package = pkgs.fluent-icon-theme;
    };
  };

  dconf.settings = {
    # ...
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "trayIconsReloaded@selfmade.pl"
        "compiz-alike-magic-lamp-effect@hermes83.github.com"
        "compiz-windows-effect@hermes83.github.com"
        "burn-my-windows@schneegans.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "search-light@icedman.github.com"
        "just-perfection-desktop@just-perfection"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        "ideapad@laurento.frittella"
        "impatience@gfxmonk.net"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "dash2dock-lite@icedman.github.com"
      ];
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    dash2dock-lite
    auto-move-windows
    ideapad
    just-perfection
    workspace-indicator
    blur-my-shell
    burn-my-windows
    compiz-alike-magic-lamp-effect
    compiz-windows-effect
    search-light
    tray-icons-reloaded
    user-themes
    impatience
  ];

  home.file.".config/kitty".source = ./config/kitty;
  home.file.".config/fastfetch".source = ./config/fastfetch;
}
