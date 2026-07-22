{ lib, pkgs, ... }: {
  services.upower.enable = true;
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  services.thermald.enable = lib.mkDefault true;
}
