# SSH client — Home Manager

{ config, pkgs, ... }:
let
  user = config.user.name;
in
{
  home-manager.users.${user} = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "*".AddKeysToAgent = "yes";
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };
      };
    };

    services.ssh-agent.enable = true;

    systemd.user.services.ssh-add-key = {
      Unit = {
        Description = "Add SSH key to agent on login";
        After = [ "ssh-agent.service" "sops-nix.service" ];
        Requires = [ "ssh-agent.service" "sops-nix.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.openssh}/bin/ssh-add /home/${user}/.ssh/id_ed25519";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
