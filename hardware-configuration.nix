{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ------------------------------------------------------------------
  # Boot & kernel
  # ------------------------------------------------------------------
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # ------------------------------------------------------------------
  # Filesystems
  # ------------------------------------------------------------------
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/be189333-910d-49c7-aa51-08c3e0384191";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8873-2FE1";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  # ------------------------------------------------------------------
  # Platform & firmware
  # ------------------------------------------------------------------
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # ------------------------------------------------------------------
  # Networking
  # ------------------------------------------------------------------
  networking.useDHCP = lib.mkDefault true;
}
