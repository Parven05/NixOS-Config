# Helium browser — Home Manager

{
  config,
  inputs,
  ...
}:
let
  user = config.user.name;
in
{
  home-manager.users.${user} = {
    imports = [ inputs.helium-flake.homeModules.default ];

    programs.helium = {
      enable = true;
      flags = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform-hint=auto"
        "--force-dark-mode"
        "--enable-features=WebUIDarkMode"
      ];
      policies.ExtensionInstallForcelist = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx"
      ];
    };
  };
}
