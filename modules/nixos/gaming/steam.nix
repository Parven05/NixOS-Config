{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;
  };

  programs.gamemode.enable = true;
}
