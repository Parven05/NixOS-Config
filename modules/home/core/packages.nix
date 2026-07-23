{ pkgs, lib, ... }: {
  home.packages = [
    # security
    pkgs.sops
    pkgs.libsecret

    # development
    pkgs.nodejs
    pkgs.pi-coding-agent

    # theming
    pkgs.fluent-icon-theme

    # tools
    pkgs.nix-tree
  ];

  home.file.".config/fastfetch".source = ../../../config/fastfetch;
}
