{config, lib, pkgs, ...}:
{
  
environment.systemPackages = with pkgs; [
  wget git github-desktop vivaldi discord spotify bleachbit vlc gimp
  audacity obs-studio cheese lutris prismlauncher gnome-tweaks
  gnome-extension-manager podman distrobox telegram-desktop gnome-menus
  gobject-introspection neofetch corefonts powertop kitty xdg-utils
  dconf-editor helix cava tree blender
  ];

}
