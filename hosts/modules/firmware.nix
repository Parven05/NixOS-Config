{config, lib, pkgs, ...}:

{
  hardware.firmware = with pkgs; [ linux-firmware ];
  hardware.enableRedistributableFirmware = true;
}
