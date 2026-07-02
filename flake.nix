{
	description = "NixOS";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		stylix.url = "github:danth/stylix";
	};

	outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs: {
		nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./configuration.nix
				home-manager.nixosModules.home-manager
				stylix.nixosModules.stylix
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						users.parven = import ./home.nix;
						backupFileExtension = "backup";
					};
				}
			];
		};
	};
}