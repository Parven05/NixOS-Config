# System-wide packages & nixpkgs settings

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # essentials
    git
    wget
    tree

    # shell / terminal
    fastfetch
    btop
    eza
    bat
    zoxide
    tmux
    lazygit
    yazi
    kitty

    # nix tooling
    nixfmt

    # development
    cmake
    gnumake
    glib.dev
    devenv

    # languages
    zig
    odin
    ols

    # containers
    distrobox
    podman

    # desktop / GUI
    nautilus
    file-roller
    vlc
    libreoffice
    qt6.qtwayland

    # media
    sioyek
    vesktop
    pear-desktop
    davinci-resolve
  ];

  nixpkgs.config = {
    permittedInsecurePackages = [
      "electron-33.4.11"
      "pnpm-10.29.2"
    ];
    allowUnfree = true;
  };
}
