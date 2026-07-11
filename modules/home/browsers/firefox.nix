{ config, pkgs, lib, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
in
{
  programs.firefox = {
    enable = true;

    profiles.default = {
      extensions.force = true;

      search = {
        force = true;
        default = "Brave Search";
        engines = {
          "Brave Search" = {
            urls = [
              {
                template = "https://search.brave.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "https://cdn.search.brave.com/serp/v3/static/brand/6a35a988a9c2d9d5c5b8/favicon-32x32.png";
            definedAliases = [ "@brave" ];
          };
        };
      };
    };

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      DisablePocket = true;
      DisplayBookmarksToolbar = "always";

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };

        "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
          installation_mode = "force_installed";
        };

        "default-zoom@jamielinux.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/default-zoom/latest.xpi";
          installation_mode = "force_installed";
        };

        "FirefoxColor@mozilla.com" = {
          installation_mode = "force_installed";
        };
      };

      Preferences = {
        "browser.newtabpage.activity-stream.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
      };
    };
  };

  stylix.targets.firefox = {
    profileNames = [ "default" ];
    colorTheme.enable = true;
    colors.enable = true;
  };
}
