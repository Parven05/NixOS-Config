{config, lib, pkgs, ...}:

{
 services.xserver = {
  enable = true;

  # GNOME desktop
   desktopManager.gnome.enable = true;

   # GDM display manager
   displayManager.gdm.enable = true;

   xkb = {
     layout = "us";
     variant = "";
    };
  };

}
