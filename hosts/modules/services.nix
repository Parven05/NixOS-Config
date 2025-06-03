{config, lib, pkgs, ... }:
{

  services = {
    openssh.enable = true;
    printing.enable = true;
    flatpak.enable = true;
  };
}
