{ lib, ... }:
with lib;
{
  options.my.features = {
    desktop = mkOption {
      type = types.bool;
      default = true;
      description = "Enable niri desktop + wayland session";
    };
    gaming = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Steam, gamemode, gamescope";
    };
    media = mkOption {
      type = types.bool;
      default = true;
      description = "Enable OBS Studio";
    };
    virtualization = mkOption {
      type = types.bool;
      default = true;
      description = "Enable podman, distrobox";
    };
    bluetooth = mkOption {
      type = types.bool;
      default = true;
    };
    printing = mkOption {
      type = types.bool;
      default = true;
    };
    nvidia = mkOption {
      type = types.bool;
      default = true;
      description = "NVIDIA GPU support (PRIME offload)";
    };
  };

  options.my.home = {
    browser = mkOption {
      type = types.enum [ "helium" ];
      default = "helium";
      description = "Browser: helium";
    };
    editor = mkOption {
      type = types.enum [
        "emacs"
        "vscode"
      ];
      default = "emacs";
      description = "Primary editor";
    };
    shell = mkOption {
      type = types.enum [ "fish" ];
      default = "fish";
    };
  };
}
