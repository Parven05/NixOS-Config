{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.my.helium;
in
{
  imports = [
    inputs.helium-flake.homeModules.default
  ];

  config = lib.mkIf cfg.enable {
    programs.helium = {
      enable = true;

      flags = [
        "--ozone-platform-hint=auto"
        "--enable-features=TouchpadOverscrollHistoryNavigation"
        "--start-maximized"
      ];

      policies = {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "MetricsReportingEnabled" = false;

        "ExtensionInstallForcelist" = [
          # uBlock Origin
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"
          # Proton Pass
          "ghmbeldphafepmbegfdlkpapadhbakde"
          # Dark Reader
          "eimadpbcbfnmbkopoojfekhnkhdbieeh"
          # I don't care about cookies
          "fihnjjcciajhdojfnbdddfaoknhalnja"
        ];
      };
    };
  };
}
