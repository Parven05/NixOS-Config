{ config, lib, inputs, ... }:
with lib;
{
  options.my.desktop = mkOption {
    type = types.enum [ "niri" "gnome" "both" ];
    default = "niri";
    description = "Desktop environment: niri, gnome, or both";
  };

  imports = [
    ../../hardware-configuration.nix
    (inputs.import-tree ./desktop)
    (inputs.import-tree ./hardware)
    (inputs.import-tree ./core)
    (inputs.import-tree ./services)
    (inputs.import-tree ./shell)
    (inputs.import-tree ./virtualization)
    (inputs.import-tree ./gaming)
    (inputs.import-tree ./theme)
    (inputs.import-tree ./media)
  ];

  config = {
    my.desktop = mkDefault "niri";
    system.stateVersion = "26.05";
  };
}
