{ pkgs, ... }: {
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
    zig
    devenv

    # containers
    distrobox
    podman

    # media
    firefox
    discord
    vlc
    obs-studio
    onlyoffice-desktopeditors

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
