{ ... }: {
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/parven/dotfiles";
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
    };
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
