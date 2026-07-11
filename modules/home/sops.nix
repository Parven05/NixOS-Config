{ ... }: {
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/parven/.config/sops/age/keys.txt";

    secrets."ssh_private_key" = {
      path = "/home/parven/.ssh/id_ed25519";
      mode = "0600";
    };

    secrets."deepseek_api_key" = {
      path = "/home/parven/.config/deepseek/env";
      mode = "0644";
    };
  };
}
