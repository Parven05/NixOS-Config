{ inputs, ... }: {
  imports = [ inputs.sops.homeManagerModules.sops ];
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    age.keyFile = "/home/parven/.config/sops/age/keys.txt";

    secrets."ssh_private_key" = {
      path = "/home/parven/.ssh/id_ed25519";
      mode = "0600";
    };
  };
}
