{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    # system
    git
    wget
    fastfetch

    # cli
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
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
