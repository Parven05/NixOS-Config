# Nix settings — GC, experimental features, nixPath

{
  lib,
  inputs,
  ...
}:
{
  nix = {
    gc.automatic = false;  # NH manages GC
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      connect-timeout = 5;
      fallback = true;
      log-lines = 50;
      tarball-ttl = 86400;
      use-xdg-base-directories = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    channel.enable = false;
    nixPath = lib.mapAttrsToList (n: v: "${n}=flake:${n}") (
      lib.filterAttrs (_: lib.isType "flake") inputs
    );
  };
}
