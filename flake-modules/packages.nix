# Package management — pkgs-by-name overlay + perSystem package directory

{ inputs, ... }:
{
  flake.overlays.default = final: prev: {
    local = inputs.self.legacyPackages.${final.stdenv.hostPlatform.system} or { };
  };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs { inherit system; };
      pkgsDirectory = ../pkgs/by-name;
    };
}
