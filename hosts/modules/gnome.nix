{config, lib, pkgs, ...}:

{
 services.xserver = {
  enable = true;

  # GNOME desktop
  desktopManager.gnome.enable = true;

  # GDM display manager
  displayManager.gdm.enable = true;

  xkb = {
    layout = "us";
    variant = "";
    };
  };

  services.xserver.excludePackages = [pkgs.xterm];
  services.displayManager.autoLogin = {
    enable = true;
    user = "parven";
  };

  # Use Kitty as terminal in GNOME extension
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  # Remove unnecessary GNOME apps
  environment.gnome.excludePackages = with pkgs; [
    epiphany yelp totem geary seahorse snapshot gnome-console
    gnome-tour gnome-contacts gnome-maps gnome-weather gnome-music
    gnome-connections gnome-characters gnome-software
  ];

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

}
