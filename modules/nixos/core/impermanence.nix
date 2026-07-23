{ ... }:
{
  boot.tmp.cleanOnBoot = true;
  preservation.enable = true;

  # Required for initrd-based preservation (machine-id, random-seed)
  boot.initrd.systemd.enable = true;

  # System-wide preserved state
  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log"
      "/etc/NetworkManager/system-connections"
    ];

    files = [
      # Needs to be available very early
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }

      # SSH host keys - symlink so sshd creates them on /persist directly
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        how = "symlink";
        configureParent = true;
        parent.mode = "0700";
      }
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        how = "symlink";
        configureParent = true;
        parent.mode = "0700";
      }

      # random-seed - must not exist before first boot, symlink achieves this
      {
        file = "/var/lib/systemd/random-seed";
        how = "symlink";
        inInitrd = true;
      }
    ];

    users.parven = {
      directories = [
        # Full cache directory — many apps (Electron, fontconfig, mesa,
        # Chromium, GTK, etc.) need to write here. Missing cache causes
        # apps to fail initialization, resulting in floating windows in niri.
        ".cache"

        # app data
        ".local/share"
        ".local/state"
        ".config"
        ".mozilla"
        ".steam"
        ".ssh"

        # Fonts persist across reboots
        ".local/share/fonts"

        "dotfiles"
        "Documents"
        "Pictures"
        "Music"
        "Videos"
      ];

      files = [
        ".local/share/fish/fish_history"
      ];
    };
  };

  # Directories needed on tmpfs that preservation doesn't manage
  systemd.tmpfiles.settings.impermanence-base = {
    "/var/lib/NetworkManager".d = {
      mode = "0700";
    };
    "/var/lib/colord".d = {
      mode = "0755";
    };
    "/etc/NetworkManager".d = {
      mode = "0755";
    };
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

}
