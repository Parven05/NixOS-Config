{ inputs, ... }: {
  imports = [
    ../../hardware-configuration.nix
    (inputs.import-tree ./desktop/gnome)
    (inputs.import-tree ./desktop/niri)
    (inputs.import-tree ./hardware)
    (inputs.import-tree ./core)
    (inputs.import-tree ./services)
    (inputs.import-tree ./shell)
    (inputs.import-tree ./virtualization)
    (inputs.import-tree ./gaming)
    (inputs.import-tree ./theme)
    (inputs.import-tree ./media)
  ];

  system.stateVersion = "26.05";
}
