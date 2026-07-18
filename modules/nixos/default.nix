{ ... }: {
  imports = [
    ../../hardware-configuration.nix
    ./boot.nix
    ./networking.nix
    ./desktop/gnome.nix
    ./hardware/nvidia.nix
    ./hardware/power.nix
    ./services.nix
    ./packages.nix
    ./users.nix
    ./stylix.nix
    ./cli-tools.nix
    ./virtualization.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";

}
