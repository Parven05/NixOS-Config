{ ... }: {
  imports = [
    ../../hardware-configuration.nix
    ./boot.nix
    ./networking.nix
    ./desktop/gnome.nix
    ./hardware/nvidia.nix
    ./hardware/power.nix
    ./audio.nix
    ./services.nix
    ./packages.nix
    ./users.nix
    ./stylix.nix
    ./cli-tools.nix
    ./virtualization.nix
    ./gaming.nix
    ./obs.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";

}
