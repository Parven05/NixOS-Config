{config, lib, pkgs, ...}:

{

  users.users.parven = {
    isNormalUser = true;
    description = "Parven";
    initialPassword = "parven5102003"; # Change to hashedPassword in production
    extraGroups = [ "wheel" "networkmanager" "video" "bluetooth" ];
  };

  security.sudo.enable = true;
   
}
