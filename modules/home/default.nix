{ inputs, ... }: {
  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.sops-nix.homeManagerModules.sops
    ./sops.nix
    ./ssh.nix
    ./git.nix
    ./shell/fish.nix
    ./tmux.nix
    ./desktop/gnome.nix
    ./editors/vscode.nix
    ./browsers/firefox.nix
    ./nixcord.nix
    ./packages.nix
  ];

  home.username = "parven";
  home.homeDirectory = "/home/parven";
  home.stateVersion = "26.05";
}
