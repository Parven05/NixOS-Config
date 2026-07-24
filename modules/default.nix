{
  config,
  lib,
  inputs,
  ...
}:
with lib;
{
  # ── Feature flags ────────────────────────────────────────────
  options.features = {
    desktop = mkEnableOption "Niri desktop + Wayland session";
    gaming = mkEnableOption "Steam, gamemode, gamescope";
    media = mkEnableOption "OBS Studio";
    virtualization = mkEnableOption "Podman & containers";
    bluetooth = mkEnableOption "Bluetooth support";
    nvidia = mkEnableOption "NVIDIA GPU (PRIME offload)";
  };

  options.user = {
    name = mkOption {
      type = types.str;
      default = "parven";
      description = "Primary username";
    };
    fullName = mkOption {
      type = types.str;
      default = "Parven";
      description = "Full display name";
    };
    email = mkOption {
      type = types.str;
      default = "parven5@proton.me";
      description = "User email address";
    };
  };

  # ── Import all aspect modules ────────────────────────────────
  imports = [
    (inputs.import-tree ./base)
    (inputs.import-tree ./packages)
    (inputs.import-tree ./shell)
    (inputs.import-tree ./desktop)
    (inputs.import-tree ./dev)
    (inputs.import-tree ./browser)
    (inputs.import-tree ./hardware)
    (inputs.import-tree ./bluetooth)
    (inputs.import-tree ./virtualisation)
    (inputs.import-tree ./gaming)
    (inputs.import-tree ./media)
    (inputs.import-tree ./services)
    (inputs.import-tree ./theme)
    (inputs.import-tree ./security)
    (inputs.import-tree ./hosts)
  ];

  # ── Global defaults ──────────────────────────────────────────
  config = {
    features = {
      desktop = true;
      gaming = true;
      media = true;
      virtualization = true;
      bluetooth = true;
      nvidia = true;
    };

    system.stateVersion = "26.05";
  };
}
