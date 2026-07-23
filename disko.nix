{ ... }:
{
  # Ensure critical mounts are ready early during stage 1 boot
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "size=50%"
        "mode=755"
      ];
    };

    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNW512G8L_BTNH04850Z4N512E";

      content = {
        type = "gpt";
        partitions = {
          # Legacy BIOS boot partition (for MBR/BIOS compatibility)
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };

          # EFI System Partition (ESP)
          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };

          # Dedicated Swap Partition
          swap = {
            size = "16G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };

          # Btrfs Root Partition holding Nix store & Persistent storage
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
