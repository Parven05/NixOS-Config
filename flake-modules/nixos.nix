{ inputs, ... }: {
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ../disko.nix
      ../modules/nixos
      inputs.disko.nixosModules.disko
      inputs.preservation.nixosModules.preservation
      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
      inputs.sops.nixosModules.sops
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.parven = import ../modules/home;
          backupFileExtension = "backup";
        };
      }
    ];
  };
}
