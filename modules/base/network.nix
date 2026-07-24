# Networking — NetworkManager, resolved

{ ... }:
{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.dhcpcd.enable = false;
  services.resolved.enable = true;
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;
}
