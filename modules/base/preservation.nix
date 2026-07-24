# Impermanence — preservation at /persist

{
  config,
  inputs,
  ...
}:
let
  user = config.user.name;
in
{
  imports = [ inputs.preservation.nixosModules.preservation ];

  preservation.enable = true;
  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
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
      {
        file = "/var/lib/systemd/random-seed";
        how = "symlink";
        inInitrd = true;
      }
    ];
    users.${user} = {
      directories = [
        ".cache"
        ".local/share"
        ".local/state"
        ".config"
        ".steam"
        ".ssh"
        ".local/share/fonts"
        "Pi-Nix"
        "Documents"
        "Pictures"
        "Music"
        "Videos"
      ];
      files = [
        ".local/share/fish/fish_history"
        ".pi/agent/auth.json"
      ];
    };
  };

  systemd.tmpfiles.settings.impermanence-base = {
    "/var/lib/NetworkManager".d.mode = "0700";
    "/var/lib/colord".d.mode = "0755";
    "/etc/NetworkManager".d.mode = "0755";
  };
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
