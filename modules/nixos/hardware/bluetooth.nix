{ pkgs, ... }: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "dual";
        Experimental = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  boot.kernelModules = [ "btusb" ];

  systemd.services.bluetooth = {
    postStart = ''
      ${pkgs.util-linux}/bin/rfkill unblock bluetooth
    '';
  };
}
