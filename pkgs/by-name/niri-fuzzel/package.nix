# Niri fuzzel helper scripts — appdrawer, bgselector, colorwaybar, powermenu

{
  symlinkJoin,
  writeShellScriptBin,
}:

symlinkJoin {
  name = "niri-fuzzel";
  paths = [
    (writeShellScriptBin "appdrawer" (builtins.readFile ./appdrawer.sh))
    (writeShellScriptBin "bgselector" (builtins.readFile ./bgselector.sh))
    (writeShellScriptBin "colorwaybar" (builtins.readFile ./colorwaybar.sh))
    (writeShellScriptBin "powermenu" (builtins.readFile ./powermenu.sh))
  ];
}
