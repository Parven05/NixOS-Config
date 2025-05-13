# Edit this configuration file to define what should be installed on your system.
# Help: `man configuration.nix` or run `nixos-help`.

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in
{
  ##############################################
  # Imports
  ##############################################
  imports = [
    ./hardware-configuration.nix
  ];

  ##############################################
  # System Settings
  ##############################################
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Kuala_Lumpur";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.firmware = with pkgs; [ linux-firmware ];

  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";

  ##############################################
  # Networking & Bluetooth
  ##############################################
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  ##############################################
  # User Setup
  ##############################################
  users.users.parven = {
    isNormalUser = true;
    description = "Parven";
    initialPassword = "parven5102003"; # Change to hashedPassword in production
    extraGroups = [ "wheel" "networkmanager" "video" "bluetooth" ];
    packages = with pkgs; [ ];
  };

  security.sudo.enable = true;

  ##############################################
  # Display & Desktop
  ##############################################
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "parven";
  };

  # GNOME bloat cleanup
  environment.gnome.excludePackages = with pkgs; [
    epiphany yelp totem geary seahorse snapshot gnome-console
    gnome-tour gnome-contacts gnome-maps gnome-weather gnome-music
    gnome-connections gnome-characters gnome-software
  ];

  # Workaround for GNOME autologin bug
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  ##############################################
  # Audio
  ##############################################
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  ##############################################
  # Applications & Gaming
  ##############################################
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    wget git github-desktop vscode bitwarden-desktop brave
    discord spotify bleachbit vlc gimp audacity obs-studio
    cheese lutris prismlauncher gnome-tweaks gnome-extension-manager
    podman distrobox telegram-desktop gnome-menus gobject-introspection
    neofetch gnome-terminal corefonts powertop unstable.godot
  ];

  environment.variables.GI_TYPELIB_PATH = "${pkgs.gnome-menus}/lib/girepository-1.0";

  ##############################################
  # Extra Services
  ##############################################
  services = {
    openssh.enable = true;
    printing.enable = true;
    flatpak.enable = true;
    # xserver.libinput.enable = true; # Enable touchpad if not already by desktopManager
  };
}
