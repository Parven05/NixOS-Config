{
  config,
  lib,
  inputs,
  ...
}:
with lib;
{
  options.my.desktop = mkOption {
    type = types.enum [ "niri" ];
    default = "niri";
    description = "Desktop environment: niri";
  };

  imports = [
    (inputs.import-tree ./desktop)
    (inputs.import-tree ./browser)
    (inputs.import-tree ./editor)
    (inputs.import-tree ./shell)
    (inputs.import-tree ./security)
    (inputs.import-tree ./others)
    (inputs.import-tree ./core)
  ];

  config = {
    my.desktop = "niri";
    home = {
      username = "parven";
      homeDirectory = "/home/parven";
      stateVersion = "26.05";
    };
  };
}
