# Tmux — Home Manager

{ config, pkgs, ... }:
let
  user = config.user.name;
in
{
  home-manager.users.${user}.programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    historyLimit = 10000;
    prefix = "C-a";
    mouse = true;
    baseIndex = 1;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];
    extraConfig = ''
      set -g terminal-overrides ",xterm-256color:Tc"
    '';
  };
}
