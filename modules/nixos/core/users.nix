{ pkgs, ... }: {
  programs.fish.enable = true;

  users.users.parven = {
    isNormalUser = true;
    hashedPassword = "$6$RT/7FQTBmmHlZrKv$MZn6JbilTgyrBwH7bqPpO8BgOUkf5K8Wg9/zoGQC0JcWRghWFhzYEGLJMpJTYz6Vr.pwsgjsURgnJi.cRKfip0";
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
