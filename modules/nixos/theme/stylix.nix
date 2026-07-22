{ pkgs, lib, ... }: {
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.targets.qt.platform = lib.mkForce "qtct";
  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };
    sansSerif = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
    };
    serif = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };
    sizes = {
      applications = 12;
      terminal = 12;
      desktop = 12;
      popups = 10;
    };
  };
  stylix.icons = {
    enable = true;
    dark = "Fluent";
    light = "Fluent";
  };

  stylix.base16Scheme = {
    base00 = "111418";
    base01 = "181c22";
    base02 = "1f242b";
    base03 = "6e7681";
    base04 = "8b97a3";
    base05 = "c9d1d9";
    base06 = "e6e9ed";
    base07 = "f0f2f5";
    base08 = "be5a55";
    base09 = "be825a";
    base0A = "c8aa5a";
    base0B = "6eaa82";
    base0C = "5aaaaf";
    base0D = "6ea8e0";
    base0E = "aa82aa";
    base0F = "a892b8";
  };
}
