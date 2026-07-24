# SOPS secrets — NixOS + Home Manager

{
  config,
  inputs,
  ...
}:
let
  user = config.user.name;
in
{
  imports = [ inputs.sops.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/${user}/.config/sops/age/keys.txt";
  };

  home-manager.users.${user} = {
    imports = [ inputs.sops.homeManagerModules.sops ];

    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      age.keyFile = "/home/${user}/.config/sops/age/keys.txt";

      secrets."ssh_private_key" = {
        path = "/home/${user}/.ssh/id_ed25519";
        mode = "0600";
      };
    };
  };
}
