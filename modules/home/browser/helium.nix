{ config, lib, pkgs, inputs, ... }:
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
      # Privacy & security
      BrowserSignin = 0;
      PasswordManagerEnabled = false;
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName = "Brave Search";
      DefaultSearchProviderSearchURL = "https://search.brave.com/search?q={searchTerms}";
      MetricsReportingEnabled = false;
      SafeBrowsingEnabled = true;
      SpellCheckServiceEnabled = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      TranslateEnabled = false;

      # UI
      HomepageLocation = "https://search.brave.com";
      RestoreOnStartup = 1;
      ShowHomeButton = true;
      BookmarkBarEnabled = true;

      # Privacy features
      DefaultGeolocationSetting = 3; # Block
      DefaultNotificationsSetting = 2; # Block
      BlockThirdPartyCookies = true;
      AutoplayAllowed = false;
      BackgroundModeEnabled = false;

      # Extensions
      ExtensionInstallForcelist = [
        # uBlock Origin
        "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx"
      ];
    };
  };
}
