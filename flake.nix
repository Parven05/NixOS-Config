 {
  description = "A very basic flake";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";

    #stylix.url = "github:danth/stylix";
    #stylix.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, home-manager, /*stylix,*/ ... }@inputs: let
    system = "x86_64-linux";

    pkgsStable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    defaultPackage.x86_64-linux = pkgsStable.hello;

    defaultApp.x86_64-linux = {
      type = "app";
      program = "${pkgsStable.hello}/bin/hello";
    };

    nixosConfigurations = {
      nixos = nixpkgs-stable.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/configuration.nix          
          #stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager

          {
            nixpkgs.overlays = [
              (final: prev: {
                unstable = pkgsUnstable;
              })
            ];

            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;
            home-manager.users.parven = import ./user/home.nix;
          }
        ];
      };
    };
  };
}
