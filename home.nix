{
  config,
  pkgs,
  lib,
  ...
}:
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

  # GNOME settings
  gtk = {
    enable = true;
    iconTheme = {
      name = "Fluent";
      package = pkgs.fluent-icon-theme;
    };
  };

  dconf.settings = {
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

    # settings
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      overlay-key = "";
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      help = [ ];
    };

    # keybindings
    "org/gnome/desktop/wm/keybindings" = {
      # navigation
      switch-to-workspace-left = [ "<Alt>q" ];
      switch-to-workspace-right = [ "<Alt>e" ];
      move-to-workspace-left = [ "<Alt>w" ];
      move-to-workspace-right = [ "<Alt>r" ];
    };

    "org/gnome/shell/keybindings" = {
      # screenshot
      show-screenshot-ui = [ "<Shift><Super>s" ];
    };

    # search-light
    "org/gnome/shell/extensions/search-light" = {
      shortcut-search = [ "<Alt>a" ];
      border-radius = 7.0;
      border-color = lib.hm.gvariant.mkTuple [
        1.0
        1.0
        1.0
        0.5
      ];
      background-color = lib.hm.gvariant.mkTuple [
        0.0
        0.0
        0.0
        6.0
      ];
    };

    # dash2dock-lite
    "org/gnome/shell/extensions/dash2dock-lite" = {
      open-app-animation = true;
      separator-thickness = 1;
      dock-padding = 1.0;
      edge-distance = 1.0;
      border-radius = 8.0;
      border-thickness = 1;
      border-color = lib.hm.gvariant.mkTuple [
        0.0
        0.0
        0.0
        0.5
      ];
      customize-label = true;
      label-border-radius = 6.0;
      apps-icon = false;
      trash-icon = true;
      downloads-icon = true;
      animation-magnify = 0.20;
      animation-spread = 0.23;
    };

    # just-perfection
    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = false;
      quick-settings-airplane-mode = false;
      weather = false;
      events-button = false;
      search = false;
      workspace-popup = false;
      startup-status = 0;
    };

    # auto-move-windows
    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [
        "kitty.desktop:1"
        "code.desktop:2"
        "firefox.desktop:3"
        "discord.desktop:4"
      ];
    };

    # compiz-alike-magic-lamp-effect
    "org/gnome/shell/extensions/com/github/hermes83/compiz-alike-magic-lamp-effect" = {
      duration = 225.0;
    };

    # compiz-windows-effect
    "org/gnome/shell/extensions/com/github/hermes83/compiz-windows-effect" = {
      # subtle
      friction = 1.5;
      mass = 80.0;
      speedup-factor-divider = 6.0;
      spring-k = 1.0;
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

  # vscode
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      pkief.material-icon-theme
      ritwickdey.liveserver
      usernamehw.errorlens
      zhuangtongfa.material-theme
      ziglang.vscode-zig
    ];
  };

  home.file.".config/kitty".source = ./config/kitty;
  home.file.".config/fastfetch".source = ./config/fastfetch;

}
