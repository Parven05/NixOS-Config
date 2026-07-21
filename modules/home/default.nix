{ inputs, ... }: {
  imports = [
    (inputs.import-tree ./desktop/gnome)
    (inputs.import-tree ./desktop/niri)
    (inputs.import-tree ./browser)
    (inputs.import-tree ./editor)
    (inputs.import-tree ./shell)
    (inputs.import-tree ./security)
    (inputs.import-tree ./others)
    (inputs.import-tree ./core)
  ];

  home.username = "parven";
  home.homeDirectory = "/home/parven";
  home.stateVersion = "26.05";
}
