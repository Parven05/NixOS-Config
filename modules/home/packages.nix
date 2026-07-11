{ pkgs, ... }: {
  home.packages = [
    # security
    pkgs.sops
    pkgs.libsecret

    # development
    pkgs.nodejs
    pkgs.pi-coding-agent
    pkgs.git-credential-manager
  ]
  ++ (with pkgs.gnomeExtensions; [
    # dock / workspace
    dash2dock-lite
    workspace-indicator
    auto-move-windows

    # animations / effects
    blur-my-shell
    burn-my-windows
    compiz-alike-magic-lamp-effect
    compiz-windows-effect

    # ui tweaks
    just-perfection
    user-themes
    search-light
    tray-icons-reloaded

    # hardware
    ideapad
  ]);

  home.file.".config/kitty".source = ../../config/kitty;
  home.file.".config/fastfetch".source = ../../config/fastfetch;
}
