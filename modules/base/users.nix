# System user definition

{ config, pkgs, ... }:
let
  user = config.user.name;
in
{
  programs.fish.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    hashedPassword = "$6$RT/7FQTBmmHlZrKv$MZn6JbilTgyrBwH7bqPpO8BgOUkf5K8Wg9/zoGQC0JcWRghWFhzYEGLJMpJTYz6Vr.pwsgjsURgnJi.cRKfip0";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "bluetooth"
      "input"
      "audio"
      "sound"
      "tty"
    ];
  };
}
