{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    firefox
    kitty
    discord
    vlc
    obs-studio
    fastfetch
    gnome-tweaks
    gnome-extension-manager
    btop
    nixfmt
    eza
    bat
    zoxide
    tmux
    distrobox
    podman
    wget
    git
    vscode
    cmake
    gnumake
    glib.dev
    zig
    devenv
    gitui
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
