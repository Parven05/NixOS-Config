{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.helium-flake.homeModules.default ];

  programs.helium = {
    enable = true;

    flags = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform-hint=auto"
      "--force-dark-mode"
      "--enable-features=WebUIDarkMode"
    ];

    policies = {
      # Extensions
      ExtensionInstallForcelist = [
        # uBlock Origin
        "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx"
      ];
    };
  };
}
