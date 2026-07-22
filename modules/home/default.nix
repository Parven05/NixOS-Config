{
  config,
  lib,
  inputs,
  ...
}:
with lib;
{
  options.my.desktop = mkOption {
    type = types.enum [
      "niri"
      "gnome"
      "both"
    ];
    default = "niri";
    description = "Desktop environment: niri, gnome, or both";
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
    my.desktop = mkDefault "niri";
    home = {
      username = "parven";
      homeDirectory = "/home/parven";
      stateVersion = "26.05";
    };
  };
}
