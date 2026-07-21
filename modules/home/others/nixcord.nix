{ inputs, ... }: {
  imports = [ inputs.nixcord.homeModules.nixcord ];
  programs.nixcord = {
    enable = true;
    discord.equicord.enable = true;

    config.plugins = {
      hideMedia.enable = true;
    };
  };

  stylix.targets.nixcord = {
    enable = true;
    colors.enable = true;
  };
}
