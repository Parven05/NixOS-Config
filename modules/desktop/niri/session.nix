# Wayland session variables — NixOS + Home Manager

{ config, ... }:
{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "niri:gnome";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  home-manager.users.${config.user.name}.home.sessionVariables = {
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Original-Classic";
  };
}
