{ lib, ... }:
with lib;
{
  options.my.home = {
    browser = mkOption {
      type = types.enum [ "helium" ];
      default = "helium";
      description = "Browser selection";
    };
    editor = mkOption {
      type = types.enum [
        "vscode"
      ];
      default = "vscode";
      description = "Primary editor";
    };
    shell = mkOption {
      type = types.enum [ "fish" ];
      default = "fish";
      description = "Login shell";
    };
    launcher = mkOption {
      type = types.enum [ "fuzzel" ];
      default = "fuzzel";
      description = "Application launcher";
    };
  };
}
