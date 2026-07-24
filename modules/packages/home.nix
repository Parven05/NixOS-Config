# Home Manager user packages

{
  config,
  pkgs,
  inputs,
  ...
}:
let
  user = config.user.name;
in
{
  home-manager.users.${user}.home.packages = with pkgs; [
    # security
    sops
    libsecret

    # development
    nix-tree
    nodejs
    netscanner

    # coding agent
    pi-coding-agent

    # wayland / niri
    grim
    slurp
    sway-contrib.grimshot
    wl-clipboard
    brightnessctl
    pavucontrol
    playerctl
    awww
    fuzzel
    imagemagick

    # theming / icons
    bibata-cursors
    fluent-icon-theme

    # quickshell
    (inputs.qml-niri.packages.${pkgs.stdenv.hostPlatform.system}.quickshell-niri)

    # local packages
    pkgs.local.niri-fuzzel
  ];
}
