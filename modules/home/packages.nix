{ pkgs, ... }: {
  home.packages = [
    pkgs.sops
    pkgs.libsecret
    pkgs.git-credential-manager
    pkgs.nodejs
    pkgs.pi-coding-agent
  ]
  ++ (with pkgs.gnomeExtensions; [
    dash2dock-lite
    auto-move-windows
    ideapad
    just-perfection
    workspace-indicator
    blur-my-shell
    burn-my-windows
    compiz-alike-magic-lamp-effect
    compiz-windows-effect
    search-light
    tray-icons-reloaded
    user-themes
  ]);

  home.file.".config/kitty".source = ../../config/kitty;
  home.file.".config/fastfetch".source = ../../config/fastfetch;
}
