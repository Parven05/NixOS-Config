# Nautilus file manager — NixOS

{ ... }:
{
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  programs.niri.useNautilus = false;
}
