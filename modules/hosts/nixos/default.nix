# Host: "nixos" — hardware, disko, overlays

{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ../../../disko.nix
    ../../../hardware-configuration.nix
  ];

  nixpkgs.overlays = [ inputs.self.overlays.default ];
}
