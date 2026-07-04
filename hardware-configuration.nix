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
  # Graphics — Intel/NVIDIA Prime offload
  # ------------------------------------------------------------------
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false; # proprietary driver
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  services.switcherooControl.enable = true;

  # ------------------------------------------------------------------
  # Power management
  # ------------------------------------------------------------------
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  services.thermald.enable = lib.mkDefault true;
  powerManagement.powertop.enable = true;

  # ------------------------------------------------------------------
  # Networking
  # ------------------------------------------------------------------
  networking.useDHCP = lib.mkDefault true;
}