{ pkgs, ... }: {
  programs.fish.enable = true;

  users.users.parven = {
    isNormalUser = true;
    shell = pkgs.fish;
      extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "bluetooth"
    ];
    packages = with pkgs; [
      tree
    ];
  };
}
