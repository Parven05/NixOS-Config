{ config, lib, pkgs, ... }:
with lib;
mkIf (config.my.desktop == "gnome" || config.my.desktop == "both") {
  home.packages = with pkgs; [
    pavucontrol
  ] ++ (with pkgs.gnomeExtensions; [
    dash2dock-lite
    workspace-indicator
    auto-move-windows
    blur-my-shell
    burn-my-windows
    compiz-alike-magic-lamp-effect
    compiz-windows-effect
    just-perfection
    user-themes
    search-light
    tray-icons-reloaded
    ideapad
  ]);

  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "adwaita";
  };

  gtk.enable = true;

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
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "dash2dock-lite@icedman.github.com"
      ];
    };

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

    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-left = [ "<Alt>q" ];
      switch-to-workspace-right = [ "<Alt>e" ];
      move-to-workspace-left = [ "<Alt>w" ];
      move-to-workspace-right = [ "<Alt>r" ];
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "<Shift><Super>s" ];
    };

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

    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = false;
      quick-settings-airplane-mode = false;
      weather = false;
      events-button = false;
      search = false;
      workspace-popup = false;
      startup-status = 0;
    };

    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [
        "kitty.desktop:1"
        "code.desktop:2"
        "firefox.desktop:3"
        "discord.desktop:4"
      ];
    };

    "org/gnome/shell/extensions/com/github/hermes83/compiz-alike-magic-lamp-effect" = {
      duration = 225.0;
    };

    "org/gnome/shell/extensions/com/github/hermes83/compiz-windows-effect" = {
      friction = 1.5;
      mass = 80.0;
      speedup-factor-divider = 6.0;
      spring-k = 1.0;
    };
  };
}
