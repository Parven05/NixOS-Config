# Virtualisation — Podman & containers

{ config, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  home-manager.users.${config.user.name}.services.podman.enable = true;
}
