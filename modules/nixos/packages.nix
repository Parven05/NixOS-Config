{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    # system
    git
    wget
    fastfetch

    # cli
    kitty
    btop
    eza
    bat
    zoxide
    tmux
    nixfmt
    lazygit

    # development
    vscode
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

    # media
    firefox
    discord
    vlc
    onlyoffice-desktopeditors
    pear-desktop
    davinci-resolve

    # gnome
    gnome-tweaks
    gnome-extension-manager
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
