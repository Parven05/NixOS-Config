{ pkgs, ... }: {
  programs.niri.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Use gdm as login manager so niri has a session entry
  services.displayManager.gdm.enable = true;

  # Nautilus + terminal integration for file management
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  # Hide GNOME apps that don't belong in a niri session
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    yelp
    totem
    geary
    seahorse
    snapshot
    gnome-tour
    gnome-contacts
    gnome-maps
    gnome-weather
    gnome-music
    gnome-characters
    gnome-software
    gnome-connections
  ];

  environment.systemPackages = with pkgs; [
    kitty
    nautilus
    gnome-tweaks
    gnome-extension-manager
    file-roller
  ];
}
